import '../../../core/utils/app_storage.dart';
import '../../../core/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../../../widgets/common_appbar.dart';
import '../controller/chat_controller.dart';

class ChatScreenMobile extends StatelessWidget {
  ChatScreenMobile({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    final myId = AppStorage.userId;

    return Scaffold(
      appBar: CommonAppbar(title: "Chat"),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: CustomColors.primary),
            );
          }

          /// 🔥 FILTER: Hide chats where only I am the participant
          final filteredChats = controller.chatList.where((chat) {
            final others = controller
                .getAllParticipants(chat)
                .where((p) => p.id != myId)
                .toList();
            return others.isNotEmpty; // Only show chats with other users
          }).toList();

          if (filteredChats.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: CustomColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 72,
                        color: CustomColors.primary,
                      ),
                    ),
                    SizedBox(height: Dimensions.verticalSize * 2.5),
                    Text(
                      "No Conversations Yet",
                      style: TextStyle(
                        fontSize: Dimensions.titleLarge,
                        fontWeight: FontWeight.w700,
                        color: CustomColors.blackColor,
                      ),
                    ),
                    SizedBox(height: Dimensions.verticalSize * 0.8),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.widthSize * 4,
                      ),
                      child: Text(
                        "Your messages and conversations with service providers will appear here. Start a chat to get things moving!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Dimensions.bodyMedium,
                          fontWeight: FontWeight.w400,
                          color: CustomColors.grayShade,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];

              /// Find participants except myself
              final participants = controller
                  .getAllParticipants(chat)
                  .where((p) => p.id != myId)
                  .toList();

              if (participants.isEmpty) return const SizedBox.shrink();

              // For 1-to-1 chat, take the last participant
              final participant = participants.last;
              return ListTile(
                onTap: () {
                  Get.toNamed(
                    Routes.inboxScreen,
                    parameters: {
                      'receiverId': participant.id,
                      'avatar': participant.profileImage ?? '',
                      'name': participant.name,
                    },
                  );
                },

                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: CustomColors.primary,
                  backgroundImage: participant.profileImage != null
                      ? CachedNetworkImageProvider(
                          "${ApiEndPoints.mainDomain}/${participant.profileImage}",
                        )
                      : null,
                  child: participant.profileImage == null
                      ? Text(
                          participant.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                title: Text(participant.name),
                // subtitle: Text(participant.email ?? ""),
              );
            },
          );
        }),
      ),
    );
  }
}
