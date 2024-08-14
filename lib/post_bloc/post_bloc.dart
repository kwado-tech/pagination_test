import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_test/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;
  int _currentPage = 1;

  PostBloc(this._postRepository) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts, transformer: droppable());
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _fetchPosts() async {
    await _postRepository.fetchPosts(_currentPage);
    _currentPage++;
  }

  bool get isInitialContent => _postRepository.cachedPosts.posts.isEmpty;

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    if (state is PostInitial) {
      try {
        emit(PostLoading(isInitialContent: isInitialContent));

        await _fetchPosts();

        return emit(const PostLoaded());
      } catch (_) {
        return emit(PostError(isInitialContent: isInitialContent));
      }
    }

    if (state is PostLoaded) {
      try {
        await _fetchPosts();

        return emit(const PostLoaded());
      } catch (error) {
        return emit(PostError(isInitialContent: isInitialContent));
      }
    }

    if (state is PostError) {
      emit(PostLoading(isInitialContent: isInitialContent));

      try {
        await _fetchPosts();

        return emit(const PostLoaded());
      } catch (error) {
        return emit(PostError(isInitialContent: isInitialContent));
      }
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
