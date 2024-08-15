import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_test/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  int _currentPage = 1;

  PostBloc(this._postRepository) : super(PostInitial()) {
    on<FetchPosts>(_handleFetchPost, transformer: droppable());
    on<ToggleFavorite>(_onToggleFavorite);
  }

  bool get isInitialContent => _postRepository.cachedPosts.posts.isEmpty;

  Future<void> _handleFetchPost(
      FetchPosts event, Emitter<PostState> emit) async {
    if (state is! PostLoaded) {
      emit(PostLoading(isInitialContent: isInitialContent));
    }

    try {
      await _postRepository.fetchPosts(_currentPage);
      _currentPage++;

      return emit(const PostLoaded());
    } catch (_) {
      return emit(PostError(isInitialContent: isInitialContent));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<PostState> emit) async {
    emit(const PostLoading());

    try {
      await _postRepository.toggleFavorite(event.post);

      emit(const PostLoaded());
    } catch (e) {
      emit(
        PostError(message: e.toString(), isInitialContent: isInitialContent),
      );
    }
  }
}
