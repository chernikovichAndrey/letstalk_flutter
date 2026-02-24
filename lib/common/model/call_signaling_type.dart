enum CallSignalingType {
  callOffered('call_offered'),
  callIncoming('call_incoming'),
  callAnswered('call_answered'),
  iceCandidate('ice_candidate'),
  callEnded('call_ended'),
  callRejected('call_rejected'),
  callFailed('call_failed'),
  callOffer('call_offer'),
  callAnswer('call_answer'),
  callHangup('call_hangup'),
  callReject('call_reject'),
  callCameraToggle('call_camera_toggle');

  final String value;
  const CallSignalingType(this.value);

  static CallSignalingType? fromString(String value) {
    for (final type in CallSignalingType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}
