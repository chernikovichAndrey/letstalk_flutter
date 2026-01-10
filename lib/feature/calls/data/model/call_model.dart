import 'package:lets_talk/feature/calls/data/model/call_peer_model.dart';

class Call {
  final int id;
  final String type; // 'audio' or 'video'
  final String status; // 'ended', 'missed'
  final String direction; // 'outgoing', 'incoming'
  final CallPeer peer;
  final DateTime startedAt;
  final DateTime? answeredAt;
  final DateTime endedAt;
  final int? duration;
  final String? durationFormatted;

  Call({
    required this.id,
    required this.type,
    required this.status,
    required this.direction,
    required this.peer,
    required this.startedAt,
    this.answeredAt,
    required this.endedAt,
    this.duration,
    this.durationFormatted,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as int,
      type: json['type'] as String,
      status: json['status'] as String,
      direction: json['direction'] as String,
      peer: CallPeer.fromJson(json['peer'] as Map<String, dynamic>),
      startedAt: DateTime.parse(json['started_at'] as String),
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      endedAt: DateTime.parse(json['ended_at'] as String),
      duration: json['duration'] as int?,
      durationFormatted: json['duration_formatted'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'direction': direction,
      'peer': peer.toJson(),
      'started_at': startedAt.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'duration': duration,
      'duration_formatted': durationFormatted,
    };
  }
}
