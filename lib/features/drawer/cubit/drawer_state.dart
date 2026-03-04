part of 'drawer_cubit.dart';

sealed class DrawerState {}

final class DrawerInitial extends DrawerState {}

final class DrawerSelectedCardChanged extends DrawerState {}