import 'dart:async';

class ProfileUpdateEvent {
  final Map<String, dynamic> userData;
  ProfileUpdateEvent(this.userData);
}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _controller = StreamController<ProfileUpdateEvent>.broadcast();
  Stream<ProfileUpdateEvent> get onProfileUpdate => _controller.stream;
  void updateProfile(Map<String, dynamic> userData) {
    _controller.add(ProfileUpdateEvent(userData));
  }
}

final eventBus = EventBus(); 