import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASa21PXb05UCEtqVvDwNC0uk_UxDqsne0',
    appId: '1:874341145921:web:5c01bfb046f16dc500d5c0',
    messagingSenderId: '874341145921',
    projectId: 'braintumorapplication',
    authDomain: 'braintumorapplication.firebaseapp.com',
    storageBucket: 'braintumorapplication.firebasestorage.app',
    measurementId: 'G-YDNTM3411Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqBH2ZiSeU0DztnETOG1xd4VjlJNrII80',
    appId: '1:963653337448:android:1e6f3ff5e57dcd8cbb56dd',
    messagingSenderId: '963653337448',
    projectId: 'furkanalp-brainup',
    storageBucket: 'furkanalp-brainup.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUFaVW2j5an7fIGc4vvCp4COF6m18Tcg8',
    appId: '1:874341145921:ios:4061c4e98c109bc500d5c0',
    messagingSenderId: '874341145921',
    projectId: 'braintumorapplication',
    storageBucket: 'braintumorapplication.firebasestorage.app',
    iosBundleId: 'com.example.deneme',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUFaVW2j5an7fIGc4vvCp4COF6m18Tcg8',
    appId: '1:874341145921:ios:4061c4e98c109bc500d5c0',
    messagingSenderId: '874341145921',
    projectId: 'braintumorapplication',
    storageBucket: 'braintumorapplication.firebasestorage.app',
    iosBundleId: 'com.example.deneme',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyASa21PXb05UCEtqVvDwNC0uk_UxDqsne0',
    appId: '1:874341145921:web:17872a1879b41f3400d5c0',
    messagingSenderId: '874341145921',
    projectId: 'braintumorapplication',
    authDomain: 'braintumorapplication.firebaseapp.com',
    storageBucket: 'braintumorapplication.firebasestorage.app',
    measurementId: 'G-SBSSZYEGVB',
  );
}
