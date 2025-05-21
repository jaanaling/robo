import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neuro_robot/src/feature/rituals/bloc/user_bloc.dart';

import '../../../../routes/go_router_config.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(const UserLoadData()),
      child: CupertinoApp.router(
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFFF135FF),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'F',
              fontWeight: FontWeight.w600,
              letterSpacing: 1.50,
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: buildGoRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
