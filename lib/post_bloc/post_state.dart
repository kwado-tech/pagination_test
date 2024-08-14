import 'package:equatable/equatable.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {
  final bool isInitialContent;

  const PostLoading({this.isInitialContent = false});

  @override
  List<Object> get props => [isInitialContent];
}

class PostLoaded extends PostState {
  const PostLoaded();

  @override
  List<Object> get props => [];
}

class PostError extends PostState {
  final String message;
  final bool isInitialContent;

  const PostError({this.message = '', this.isInitialContent = false});

  @override
  List<Object> get props => [message, isInitialContent];
}
