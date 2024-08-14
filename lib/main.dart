import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pagination_test/post_bloc/post_bloc.dart';
import 'package:pagination_test/post_bloc/post_event.dart';
import 'package:pagination_test/post_bloc/post_state.dart';
import 'package:pagination_test/watch_post_bloc/watch_post_bloc.dart';
import 'package:pagination_test/watch_post_bloc/watch_post_event.dart';
import 'package:pagination_test/watch_post_bloc/watch_post_state.dart';

import 'post_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLoC Pagination & Cache Example',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PostBloc(PostRepository())..add(FetchPosts()),
          ),
          BlocProvider(
            create: (context) =>
                WatchPostBloc(PostRepository())..add(WatchPostEvent()),
          ),
        ],
        child: const PostListScreen(),
      ),
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      BlocProvider.of<PostBloc>(context).add(FetchPosts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildBottomActionIndicator() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostError) {
          return TextButton(
            onPressed: () => context.read<PostBloc>().add(FetchPosts()),
            child: const Text('Load More Data'),
          );
        }

        return const Center(
          child: SizedBox(
            height: 30,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  // Widget _buildPostList(WatchPostState state) {
  Widget _buildPostList() {
    return BlocBuilder<WatchPostBloc, WatchPostState>(
      builder: (context, state) {
        if (state.postList.posts.isEmpty) {
          return Column(
            children: [
              const Text('Sorry! There are no posts to view at this time'),
              TextButton(
                onPressed: () => context.read<PostBloc>().add(FetchPosts()),
                child: const Text('Try again!'),
              ),
            ],
          );
        }

        final posts = state.postList.posts;

        return ListView.separated(
          cacheExtent: double.maxFinite,
          controller: _scrollController,
          itemCount:
              state.postList.hasReachedMax ? posts.length : posts.length + 1,
          padding: const EdgeInsets.symmetric(vertical: 10),
          separatorBuilder: (_, __) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            if (index >= posts.length) {
              return _buildBottomActionIndicator();
            }

            final post = posts[index];

            return ListTile(
              leading: Text(post.id.toString()),
              title: Text(post.title),
              trailing: IconButton(
                icon: Icon(
                  post.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: post.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  BlocProvider.of<PostBloc>(context).add(ToggleFavorite(post));
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<WatchPostBloc, WatchPostState>(
    //   builder: (context, watchState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          if (state is PostError && !state.isInitialContent) {
            Fluttertoast.showToast(msg: 'Something went wrong!');
          }
        },
        builder: (context, state) {
          if (state is PostLoading) {
            if (state.isInitialContent) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildPostList();
            // return _buildPostList(watchState);
          }

          // if (state is PostLoaded) return _buildPostList(watchState);
          if (state is PostLoaded) return _buildPostList();

          if (state is PostError) {
            // if (!state.isInitialContent) return _buildPostList(watchState);
            if (!state.isInitialContent) return _buildPostList();

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong!'),
                  TextButton(
                    onPressed: () => context.read<PostBloc>().add(FetchPosts()),
                    child: const Text('Try again!'),
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
    //   },
    // );
  }
}
