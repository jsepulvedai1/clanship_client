import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class TabChanged extends NavigationEvent {
  final int index;
  const TabChanged(this.index);

  @override
  List<Object> get props => [index];
}
