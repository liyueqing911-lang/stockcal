/// 帖子类型
enum PostType {
  /// 📊 财报解读
  analysis,

  /// 💬 讨论
  discussion,

  /// ❓ 提问
  question,

  /// 📰 资讯分享
  news,

  /// 🎯 预测
  prediction,
}

extension PostTypeMeta on PostType {
  String get label {
    switch (this) {
      case PostType.analysis:
        return '财报解读';
      case PostType.discussion:
        return '讨论';
      case PostType.question:
        return '提问';
      case PostType.news:
        return '资讯分享';
      case PostType.prediction:
        return '预测';
    }
  }

  String get icon {
    switch (this) {
      case PostType.analysis:
        return '📊';
      case PostType.discussion:
        return '💬';
      case PostType.question:
        return '❓';
      case PostType.news:
        return '📰';
      case PostType.prediction:
        return '🎯';
    }
  }

  static PostType fromString(String value) {
    return PostType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => PostType.discussion,
    );
  }
}

/// 社区帖子模型
class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final PostType type;
  final String title;
  final String content;
  final List<String> images;
  final List<String> linkedStocks; // 关联股票symbol
  final int? linkedEventId; // 关联事件ID（可选）
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isPinned;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.type,
    required this.title,
    required this.content,
    this.images = const [],
    this.linkedStocks = const [],
    this.linkedEventId,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.isPinned = false,
  });

  /// 用于本地展示的工厂方法
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String? ?? '匿名用户',
      authorAvatar: json['authorAvatar'] as String?,
      type: PostTypeMeta.fromString(json['type'] as String? ?? 'discussion'),
      title: json['title'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] ?? []),
      linkedStocks: List<String>.from(json['linkedStocks'] ?? []),
      linkedEventId: json['linkedEventId'] as int?,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'type': type.name,
        'title': title,
        'content': content,
        'images': images,
        'linkedStocks': linkedStocks,
        'linkedEventId': linkedEventId,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'createdAt': createdAt.toIso8601String(),
        'isPinned': isPinned,
      };

  Post copyWith({
    int? likeCount,
    int? commentCount,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      type: type,
      title: title,
      content: content,
      images: images,
      linkedStocks: linkedStocks,
      linkedEventId: linkedEventId,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      isPinned: isPinned,
    );
  }
}
