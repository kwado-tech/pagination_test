import 'package:equatable/equatable.dart';
import 'package:pagination_test/post.dart';

final class WatchPostState extends Equatable {
  final PostList postList;

  const WatchPostState({required this.postList});

  WatchPostState.empty() : this(postList: PostList.empty());

  WatchPostState copyWith({PostList? postList}) {
    return WatchPostState(postList: postList ?? this.postList);
  }

  @override
  List<Object?> get props => [postList];
}
