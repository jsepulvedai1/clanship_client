import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clanship_cliente/core/navigation/bloc/navigation_event.dart';

@lazySingleton
class NavigationBloc extends Bloc<NavigationEvent, int> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? targetJobTab;

  NavigationBloc() : super(0) {
    on<TabChanged>((event, emit) {
      targetJobTab = event.targetJobTab;
      emit(event.index);
    });
  }
}
