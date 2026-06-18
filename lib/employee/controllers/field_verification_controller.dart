import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tryzx_workfoce_mangment/core/utils/helpers.dart';
import 'package:tryzx_workfoce_mangment/employee/controllers/task_controller.dart';

class FieldVerificationController extends GetxController {
  final _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var imagePath = ''.obs;
  
  final notesController = TextEditingController();

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // compress image
      );
      if (image != null) {
        imagePath.value = image.path;
      }
    } catch (e) {
      Helpers.showSnackbar('Error', 'Failed to open camera: $e', isError: true);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Helpers.showSnackbar('Location Error', 'Location services are disabled.', isError: true);
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Helpers.showSnackbar('Location Error', 'Location permissions are denied', isError: true);
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      Helpers.showSnackbar('Location Error', 'Location permissions are permanently denied', isError: true);
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  Future<void> submitVerification(String taskId) async {
    if (imagePath.value.isEmpty) {
      Helpers.showSnackbar('Error', 'Please capture a site photo as proof.', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Get Location
      final position = await _getCurrentLocation();
      if (position == null) {
        isLoading.value = false;
        return;
      }

      // 2. Insert into field_verifications
      final verificationRes = await _supabase.from('field_verifications').insert({
        'task_id': taskId,
        'employee_id': user.id,
        'notes': notesController.text.trim(),
        'gps_lat': position.latitude,
        'gps_lng': position.longitude,
        'location_verified': true,
      }).select('id').single();

      final verificationId = verificationRes['id'];

      // 3. Upload Image to task_proofs bucket
      final file = File(imagePath.value);
      final fileExt = file.path.split('.').last;
      final fileName = '${verificationId}_proof.$fileExt';

      await _supabase.storage.from('task_proofs').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final mediaUrl = _supabase.storage.from('task_proofs').getPublicUrl(fileName);

      // 4. Insert into verification_media
      await _supabase.from('verification_media').insert({
        'verification_id': verificationId,
        'media_url': mediaUrl,
        'file_type': 'image',
      });

      // 5. Update tasks table status
      await _supabase.from('tasks').update({
        'status': 'Completed',
        'progress_percentage': 100,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', taskId);

      // 6. Notify Manager (Optional, depending on structure)
      
      // Refresh task list
      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskController>().onInit();
      }

      isLoading.value = false;
      Helpers.showSnackbar('Success', 'Verification submitted successfully!');
      
      // Navigate back to Home
      Get.back(); // close verification screen
      Get.back(); // close task detail screen

    } catch (e) {
      isLoading.value = false;
      Helpers.showSnackbar('Submission Failed', e.toString(), isError: true);
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
