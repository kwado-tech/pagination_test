import 'package:equatable/equatable.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  final bool initialPage;

  const PostLoading({this.initialPage = false});

  @override
  List<Object> get props => [initialPage];
}

class PostLoaded extends PostState {
  const PostLoaded();

  @override
  List<Object> get props => [];
}

class PostError extends PostState {
  final String message;
  final bool initialPage;

  const PostError({this.message = '', this.initialPage = false});

  @override
  List<Object> get props => [message, initialPage];
}
