class AllConversationModel {
  final bool status;
  final Conversation? conversation;
  final String message;
  final BlockStatus blockStatus;
  final bool activeNow;

  AllConversationModel({
    required this.status,
    required this.conversation,
    required this.message,
    required this.blockStatus,
    required this.activeNow,
  });

  factory AllConversationModel.fromJson(Map<String, dynamic> json) =>
      AllConversationModel(
        status: json["status"] ?? false,
        conversation: json["conversation"] == null
            ? null
            : Conversation.fromJson(
                json["conversation"] as Map<String, dynamic>,
              ),
        message: json["message"] ?? '',
        blockStatus: json["blockStatus"] == null
            ? BlockStatus(
                isBlockedByYou: false,
                isBlockedByPartner: false,
                isBlocked: false,
              )
            : BlockStatus.fromJson(json["blockStatus"] as Map<String, dynamic>),

        activeNow: json["activeNow"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "conversation": conversation?.toJson(),
    "message": message,
    "blockStatus": blockStatus.toJson(),
    "activeNow": activeNow,
  };
}

class BlockStatus {
  final bool isBlockedByYou;
  final bool isBlockedByPartner;
  final bool isBlocked;

  BlockStatus({
    required this.isBlockedByYou,
    required this.isBlockedByPartner,
    required this.isBlocked,
  });

  factory BlockStatus.fromJson(Map<String, dynamic> json) => BlockStatus(
    isBlockedByYou: json["isBlockedByYou"],
    isBlockedByPartner: json["isBlockedByPartner"],
    isBlocked: json["isBlocked"],
  );

  Map<String, dynamic> toJson() => {
    "isBlockedByYou": isBlockedByYou,
    "isBlockedByPartner": isBlockedByPartner,
    "isBlocked": isBlocked,
  };
}

class Conversation {
  final String id;
  final List<Participant> participants;
  final List<Message> messages;
  final List<dynamic> blockedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Conversation({
    required this.id,
    required this.participants,
    required this.messages,
    required this.blockedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json["_id"],
    participants: List<Participant>.from(
      json["participants"].map((x) => Participant.fromJson(x)),
    ),
    messages: List<Message>.from(
      json["messages"].map((x) => Message.fromJson(x)),
    ),
    blockedBy: List<dynamic>.from(json["blockedBy"].map((x) => x)),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "blockedBy": List<dynamic>.from(blockedBy.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class Message {
  final String id;
  final String conversationId;
  final Participant sender;
  final Participant receiver;
  final String text;
  final List<dynamic> images;
  final String video;
  final String videoCover;
  final bool seen;
  final dynamic deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.images,
    required this.video,
    required this.videoCover,
    required this.seen,
    required this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["_id"],
    conversationId: json["conversationId"],
    sender: Participant.fromJson(json["sender"]),
    receiver: Participant.fromJson(json["receiver"]),
    text: json["text"],
    images: List<dynamic>.from(json["images"].map((x) => x)),
    video: json["video"],
    videoCover: json["videoCover"],
    seen: json["seen"],
    deliveredAt: json["deliveredAt"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "conversationId": conversationId,
    "sender": sender.toJson(),
    "receiver": receiver.toJson(),
    "text": text,
    "images": List<dynamic>.from(images.map((x) => x)),
    "video": video,
    "videoCover": videoCover,
    "seen": seen,
    "deliveredAt": deliveredAt,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class Participant {
  final String id;
  final String role;
  final String name;
  final String email;
  final String? profileImage;

  Participant({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"],
    role: json["role"],
    name: json["name"],
    email: json["email"],
    profileImage: json["profileImage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role": role,
    "name": name,
    "email": email,
    "profileImage": profileImage,
  };
}
