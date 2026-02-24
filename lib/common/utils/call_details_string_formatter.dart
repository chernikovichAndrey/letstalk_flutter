import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/calls_history/data/model/call_history_model.dart';

String formatDate(DateTime? date) {
  if (date == null) return '-';
  final localDate = date.toLocal();
  return DateFormat('dd.MM.yy HH:mm').format(localDate);
}

String getDirectionText(BuildContext context, String direction) {
  if (direction == 'incoming') return context.s.callDirectionIncoming;
  if (direction == 'outgoing') return context.s.callDirectionOutgoing;
  return direction;
}

String getTypeText(BuildContext context, String type) {
  if (type == 'audio') return context.s.audioCall;
  if (type == 'video') return context.s.videoCall;
  return type;
}

String getMessageTypeText(BuildContext context, String messageType) {
  if (messageType == 'image') return context.s.messageTypeImage;
  if (messageType == 'document') return context.s.messageTypeDocument;
  if (messageType == 'video') return context.s.video;
  return context.s.video;
}

String getStatusText(BuildContext context, String status) {
  if (status == 'missed') return context.s.missedCalls;
  if (status == 'ended') return context.s.endedCall;
  if (status == 'rejected') return context.s.rejected;
  if (status == 'failed') return context.s.failed;
  return status;
}

String getCallDuration(BuildContext context, CallHistory call) {
  if (call.durationFormatted != null && call.durationFormatted!.isNotEmpty) {
    return call.durationFormatted!;
  }

  if (call.duration != null) {
    return _formatDuration(context, call.duration!);
  }

  if (call.answeredAt != null && call.endedAt != null) {
    final duration = call.endedAt!.difference(call.answeredAt!);
    return _formatDuration(context, duration.inSeconds);
  }

  return '-';
}

String _formatDuration(BuildContext context, int seconds) {
  if (seconds < 0) return '-';

  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  final h = context.s.hourShort;
  final m = context.s.minuteShort;
  final s = context.s.secondShort;

  if (hours > 0) {
    return '$hours$h $minutes$m $secs$s';
  } else if (minutes > 0) {
    return '$minutes$m $secs$s';
  } else {
    return '$secs$s';
  }
}