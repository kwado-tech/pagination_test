import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final bool isFavorite;

  const Post({
    required this.id,
    required this.title,
    this.isFavorite = false,
  });

  Post copyWith({bool? isFavorite}) {
    return Post(
      id: id,
      title: title,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object> get props => [id, title, isFavorite];
}

class PostList extends Equatable {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostList({required this.posts, required this.hasReachedMax});

  PostList.empty() : this(posts: [], hasReachedMax: false);

  PostList copyWith({List<Post>? posts, bool? hasReachedMax}) {
    return PostList(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax];
}
