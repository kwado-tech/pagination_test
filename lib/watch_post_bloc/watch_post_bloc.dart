import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_test/post_repository.dart';
import 'package:pagination_test/watch_post_bloc/watch_post_event.dart';
import 'package:pagination_test/watch_post_bloc/watch_post_state.dart';

class WatchPostBloc extends Bloc<WatchPostEvent, WatchPostState> {
  final PostRepository _postRepository;

  WatchPostBloc(this._postRepository) : super(WatchPostState.empty()) {
    on<WatchPostEvent>(_onWatchPost);
  }

  Future<void> _onWatchPost(
      WatchPostEvent event, Emitter<WatchPostState> emit) async {
    await emit.onEach(
      _postRepository.postsStream,
      onData: (data) {
        emit(state.copyWith(postList: data));
      },
      onError: (error, stackTrace) {
        print('$error');
      },
    );
  }
}
