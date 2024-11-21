import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_test/post.dart';
import 'package:pagination_test/post_repository.dart';

final class WatchSinglePostEvent {
  final int postId;

  WatchSinglePostEvent({required this.postId});
}

abstract class WatchSinglePostState extends Equatable {
  const WatchSinglePostState();

  @override
  List<Object> get props => [];
}

class WatchSinglePostInitial extends WatchSinglePostState {}

class WatchSinglePostLoading extends WatchSinglePostState {
  const WatchSinglePostLoading();

  @override
  List<Object> get props => [];
}

class WatchSinglePostLoaded extends WatchSinglePostState {
  final Post post;
  const WatchSinglePostLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

class WatchSinglePostError extends WatchSinglePostState {
  final String message;

  const WatchSinglePostError({this.message = ''});

  @override
  List<Object> get props => [message];
}

class WatchSinglePostBloc
    extends Bloc<WatchSinglePostEvent, WatchSinglePostState> {
  final PostRepository _postRepository;

  WatchSinglePostBloc(this._postRepository) : super(WatchSinglePostInitial()) {
    on<WatchSinglePostEvent>(_onWatchPost, transformer: droppable());
  }

  Future<void> _onWatchPost(
      WatchSinglePostEvent event, Emitter<WatchSinglePostState> emit) async {
    await emit.onEach(
      _postRepository.postsStream,
      onData: (data) {
        final post = data.posts.firstWhere((e) => e.id == event.postId);

        emit(WatchSinglePostLoaded(post: post));
      },
      onError: (error, stackTrace) {
        print('$error');
      },
    );
  }
}
