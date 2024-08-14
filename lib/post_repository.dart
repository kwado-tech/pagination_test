import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'post.dart';

class PostRepository {
  static final BehaviorSubject<PostList> _cachedPosts =
      BehaviorSubject.seeded(PostList.empty());

  Stream<PostList> get postsStream => _cachedPosts.stream.whereNotNull();

  PostList get cachedPosts => _cachedPosts.value;

  Future<void> fetchPosts(int page) async {
    // return-fast for optimization
    if (_cachedPosts.value.hasReachedMax) return;

    final response = await http.get(
      Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?_page=$page&_limit=30'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Post> posts = jsonData
          .map((json) => Post(
                id: json['id'],
                title: json['title'],
              ))
          .toList();

      final updatedPosts = List<Post>.from(_cachedPosts.value.posts)
        ..addAll(posts);

      final hasReachedMax =
          _cachedPosts.value.posts.length == updatedPosts.length;

      _cachedPosts
          .add(PostList(posts: updatedPosts, hasReachedMax: hasReachedMax));
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> toggleFavorite(Post post) async {
    // optimistic update in cache
    final updatedPosts = cachedPosts.posts.map((element) {
      return element.id == post.id
          ? post.copyWith(isFavorite: !post.isFavorite)
          : element;
    }).toList();

    _cachedPosts.add(cachedPosts.copyWith(posts: updatedPosts));

    try {
      // simulate an API call to update the post's favorite status
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      // revert optimistic update to cache on remote-call error
      final revertedPosts = cachedPosts.posts.map((element) {
        return element.id == post.id
            ? post.copyWith(isFavorite: post.isFavorite)
            : element;
      }).toList();

      _cachedPosts.add(cachedPosts.copyWith(posts: revertedPosts));

      throw Exception('Failed to like posts');
    }
  }
}
