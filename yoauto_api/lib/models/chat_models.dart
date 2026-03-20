/// Chat list item (summary)
class ChatListResponse {
  final String id;
  final String? listingId;
  final String? listingTitle;
  final String? listingImage;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final String? otherUserName;
  final String? otherUserAvatar;

  ChatListResponse({required this.id, this.listingId, this.listingTitle, this.listingImage, this.lastMessageText, this.lastMessageAt, required this.unreadCount, this.otherUserName, this.otherUserAvatar});

  factory ChatListResponse.fromJson(Map<String, dynamic> json) => ChatListResponse(
    id: json['id'],
    listingId: json['listing_id'],
    listingTitle: json['listing_title'],
    listingImage: json['listing_image'],
    lastMessageText: json['last_message_text'],
    lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at']) : null,
    unreadCount: json['unread_count'] ?? 0,
    otherUserName: json['other_user_name'],
    otherUserAvatar: json['other_user_avatar'],
  );
}

/// Full message response
class MessageResponse {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String status;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageResponse({required this.id, required this.chatId, required this.senderId, required this.content, required this.messageType, required this.status, required this.isEdited, required this.createdAt, required this.updatedAt});

  factory MessageResponse.fromJson(Map<String, dynamic> json) => MessageResponse(
    id: json['id'],
    chatId: json['chat_id'],
    senderId: json['sender_id'],
    content: json['content'],
    messageType: json['message_type'],
    status: json['status'],
    isEdited: json['is_edited'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
}

/// Send message request
class MessageCreate {
  final String content;
  final String messageType;

  MessageCreate({required this.content, this.messageType = 'text'});
  Map<String, dynamic> toJson() => {'content': content, 'message_type': messageType};
}
