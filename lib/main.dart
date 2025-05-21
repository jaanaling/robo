import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/core/dependency_injection.dart';
import 'src/feature/app/presentation/app_root.dart';


void main() {

    WidgetsFlutterBinding.ensureInitialized();



    setupDependencyInjection();

  
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      const AppRoot(),
    
  );
}


