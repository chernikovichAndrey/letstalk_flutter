import 'dart:convert';
import 'dart:io';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/arg/forward_message_args.dart';
import 'package:lets_talk/app/router/arg/member_info_args.dart';
import 'package:lets_talk/app/router/arg/profile_edit_photo_args.dart';
import 'package:lets_talk/app/router/arg/media_perview_args.dart';
import 'package:lets_talk/app/router/arg/media_viewer_args.dart';
import 'package:lets_talk/feature/chats/data/model/chat_model.dart';

class RouterArgsCodec extends Codec<Object?, Object?> {
  const RouterArgsCodec();

  @override
  Converter<Object?, Object?> get decoder => const _RouterArgsDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _RouterArgsEncoder();
}

class _RouterArgsEncoder extends Converter<Object?, Object?> {
  const _RouterArgsEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    if (input is ChatDetailsArgs) {
      return {
        '_type': 'ChatDetailsArgs',
        'chatId': input.chatId,
      };
    }

    if (input is MemberInfoArgs) {
      return {
        '_type': 'MemberInfoArgs',
        'memberInfo': {
          'id': input.memberInfo.id,
          'phone': input.memberInfo.phone,
          'first_name': input.memberInfo.firstName,
          'last_name': input.memberInfo.lastName,
          'full_name': input.memberInfo.fullName,
          'avatar': input.memberInfo.avatar,
        },
      };
    }

    if (input is ForwardMessageArgs) {
      return {
        '_type': 'ForwardMessageArgs',
        'messageId': input.messageId,
        'chatId': input.chatId,
      };
    }

    if (input is ProfileEditPhotoArgs) {
      return {
        '_type': 'ProfileEditPhotoArgs',
        'filePath': input.file.path,
      };
    }

    if (input is MediaPreviewArgs) {
      return {
        '_type': 'MediaPreviewArgs',
        'filePath': input.file.path
      };
    }

    if (input is MediaViewerArgs) {
      return {
        '_type': 'MediaViewerArgs',
        'videoUrl': input.videoUrl,
        'mediaType': input.mediaType,
        'thumbnailUrl': input.thumbnailUrl,
      };
    }

    return input;
  }
}

class _RouterArgsDecoder extends Converter<Object?, Object?> {
  const _RouterArgsDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    if (input is! Map<String, dynamic>) return input;

    final type = input['_type'] as String?;

    switch (type) {
      case 'ChatDetailsArgs':
        return ChatDetailsArgs(
          chatId: input['chatId'] as int,
        );

      case 'MemberInfoArgs':
        final memberInfoMap = input['memberInfo'] as Map<String, dynamic>?;
        if (memberInfoMap == null) return null;
        return MemberInfoArgs(
          memberInfo: MemberInfo.fromJson(memberInfoMap),
        );

      case 'ForwardMessageArgs':
        return ForwardMessageArgs(
          messageId: input['messageId'] as int,
          chatId: input['chatId'] as int,
        );

      case 'ProfileEditPhotoArgs':
        final filePath = input['filePath'] as String?;
        if (filePath == null) return null;
        return ProfileEditPhotoArgs(
          file: File(filePath),
        );

      case 'MediaPreviewArgs':
        final filePath = input['filePath'] as String?;
        if (filePath == null) return null;
        return MediaPreviewArgs(
          file: File(filePath),
        );

      case 'MediaViewerArgs':
        return MediaViewerArgs(
          videoUrl: input['videoUrl'] as String,
          mediaType: input['mediaType'] as String,
          thumbnailUrl: input['thumbnailUrl'] as String?,
        );

      default:
        return input;
    }
  }
}