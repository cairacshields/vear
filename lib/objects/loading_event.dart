import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';


class LoadingEvent {
  bool isLoading;
  LoadingEvent(this.isLoading);
}