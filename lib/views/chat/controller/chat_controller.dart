import 'package:doda_work/core/api/end_point/api_end_points.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/api/services/api.dart';
import '../../../core/utils/app_storage.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;
  var chatList = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  /// Fetch all conversations from API
  void fetchChats() async {
    try {
      isLoading.value = true;

      final result = await ApiRequest.get<Map<String, dynamic>>(
        endPoint: ApiEndPoints.getConversationList,
        isLoading: isLoading,
        fromJson: (json) {
          final data = json['data'] as List;
          return {'chats': data.map((e) => ChatModel.fromJson(e)).toList()};
        },
      );

      chatList.value = (result['chats'] as List<ChatModel>);

      debugPrint('  chatList.value : ${chatList.value} ');
    } catch (e) {
      debugPrint('Error fetching chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the other participant (not current user) in a conversation
  Participant getOtherParticipant(ChatModel chat) {
    final currentUserId = AppStorage.profile?['id']?.toString() ?? '';
    return chat.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => chat.participants.first,
    );
  }

  /// Get all participants in a conversation
  List<Participant> getAllParticipants(ChatModel chat) {
    return chat.participants;
  }
}
