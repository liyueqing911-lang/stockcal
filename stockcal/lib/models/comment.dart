/// 评论模型（支持楼中楼回复）
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? replyToId; // 回复的父评论ID（null = 一级评论）
  final String? replyToAuthorName; // 被回复者昵称
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.replyToId,
    this.replyToAuthorName,
    required this.createdAt,
  });

  /// 是否为一级评论
  bool get isTopLevel => replyToId == null;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String? ?? '匿名用户',
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String,
      replyToId: json['replyToId'] as String?,
      replyToAuthorName: json['replyToAuthorName'] as String?,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'content': content,
        'replyToId': replyToId,
        'replyToAuthorName': replyToAuthorName,
        'createdAt': createdAt.toIso8601String(),
      };
}
