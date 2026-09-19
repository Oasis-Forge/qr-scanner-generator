import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:qrscanner/services/photo_picker.dart';

/// The real [PhotoPicker], over `image_picker` from the gallery (SCAN-11).
///
/// On Android 13 and later it opens the system photo picker
/// ([ImagePickerAndroid.useAndroidPhotoPicker]; without it the plugin falls
/// back to the document picker on 13 to 15). The picker's own confirm step,
/// where a version shows one, is the system's: the app decodes as soon as the
/// picker returns, with no tap of its own in between (SCAN-11). The app is
/// only given the one photo the user chose, so it asks for no media or
/// storage permission (SCAN-11, RUN-2, RUN-3). Location metadata isn't asked
/// for either.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker() {
    final ImagePickerPlatform platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }
  }

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImagePath() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      return photo?.path;
    } on PlatformException {
      // The picker couldn't open (one already showing, say): nothing chosen.
      return null;
    }
  }
}
