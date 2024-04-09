// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDbjAtIm-tX--sPmJi3oQzmQ2CLEdQItjk',
    appId: '1:34111451170:web:f903b733f1ddbb386e5a7b',
    messagingSenderId: '34111451170',
    projectId: 'advbasics-2c56d',
    authDomain: 'advbasics-2c56d.firebaseapp.com',
    storageBucket: 'advbasics-2c56d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALO7azGsGygSUA6v_6mAUlkN2BYHhOnsc',
    appId: '1:34111451170:android:999d03e26e903ef06e5a7b',
    messagingSenderId: '34111451170',
    projectId: 'advbasics-2c56d',
    storageBucket: 'advbasics-2c56d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5AK4o9n1HKuKcHC3e2YasYQLPOUBVlY0',
    appId: '1:34111451170:ios:9f5b082b7feda6726e5a7b',
    messagingSenderId: '34111451170',
    projectId: 'advbasics-2c56d',
    storageBucket: 'advbasics-2c56d.appspot.com',
    iosBundleId: 'com.example.advBasics',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5AK4o9n1HKuKcHC3e2YasYQLPOUBVlY0',
    appId: '1:34111451170:ios:6934b72fd58ca13d6e5a7b',
    messagingSenderId: '34111451170',
    projectId: 'advbasics-2c56d',
    storageBucket: 'advbasics-2c56d.appspot.com',
    iosBundleId: 'com.example.advBasics.RunnerTests',
  );
}
