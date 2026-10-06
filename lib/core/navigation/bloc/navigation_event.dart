import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class TabChanged extends NavigationEvent {
  final int index;
  final String? targetJobTab;
  const TabChanged(this.index, {this.targetJobTab});

  @override
  List<Object?> get props => [index, targetJobTab];
}
