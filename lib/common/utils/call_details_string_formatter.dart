import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';

String formatDate(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
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

String getStatusText(BuildContext context, String status) {
  if (status == 'missed') return context.s.missedCalls;
  if (status == 'ended') return context.s.endedCall;
  if (status == 'rejected') return context.s.rejected;
  return status;
}