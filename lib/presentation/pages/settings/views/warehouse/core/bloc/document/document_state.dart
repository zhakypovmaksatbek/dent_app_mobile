part of 'document_cubit.dart';

/// Base state class for document operations
sealed class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object> get props => [];
}

/// Initial state
final class DocumentInitial extends DocumentState {}

/// Loading state during operations
final class DocumentLoading extends DocumentState {}

/// State when documents are successfully loaded
final class DocumentLoaded extends DocumentState {
  final List<DocumentModel> documents;

  const DocumentLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

/// State when an error occurs
final class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object> get props => [message];
}

/// State when a document is successfully created
final class DocumentCreated extends DocumentState {}

/// State when a document is successfully updated
final class DocumentUpdated extends DocumentState {}

/// State when a document is successfully deleted
final class DocumentDeleted extends DocumentState {}
