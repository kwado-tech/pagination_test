import 'package:equatable/equatable.dart';
import 'package:pagination_test/post.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class FetchPosts extends PostEvent {}

class ToggleFavorite extends PostEvent {
  final Post post;

  const ToggleFavorite(this.post);

  @override
  List<Object> get props => [post];
}
