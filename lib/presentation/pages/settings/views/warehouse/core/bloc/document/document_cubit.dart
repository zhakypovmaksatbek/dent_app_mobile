import 'package:dent_app_mobile/core/repo/warehouse/warehouse_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/warehouse/create_document_model.dart';
import 'package:dent_app_mobile/models/warehouse/document_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'document_state.dart';

/// A Cubit for managing document-related operations and state
class DocumentCubit extends Cubit<DocumentState> {
  final IWarehouseRepo _warehouseRepo;

  /// Constructor with dependency injection for the repository
  DocumentCubit({IWarehouseRepo? warehouseRepo})
    : _warehouseRepo = warehouseRepo ?? WarehouseRepo(),
      super(DocumentInitial());

  /// Fetches all documents from the repository
  Future<void> getDocuments({String? search}) async {
    emit(DocumentLoading());

    try {
      final documents = await _warehouseRepo.getDocuments(search: search);

      if (documents.isEmpty) {
        emit(const DocumentLoaded([]));
      } else {
        emit(DocumentLoaded(documents));
      }
    } on DioException catch (e) {
      emit(DocumentError(_formatErrorMessage(e)));
    }
  }

  /// Creates a new document
  Future<void> createDocument(CreateDocumentModel document) async {
    emit(DocumentLoading());

    try {
      await _warehouseRepo.createDocument(document);
      emit(DocumentCreated());
      // Refresh documents list after creation
      await getDocuments();
    } on DioException catch (e) {
      emit(DocumentError(_formatErrorMessage(e)));
    }
  }

  /// Updates an existing document
  Future<void> updateDocument(int id, CreateDocumentModel document) async {
    emit(DocumentLoading());

    try {
      await _warehouseRepo.updateDocument(id, document);
      emit(DocumentUpdated());
      // Refresh documents list after update
      await getDocuments();
    } on DioException catch (e) {
      emit(DocumentError(_formatErrorMessage(e)));
    }
  }

  /// Deletes a document by ID
  Future<void> deleteDocument(int id) async {
    emit(DocumentLoading());

    try {
      await _warehouseRepo.deleteDocument(id);
      emit(DocumentDeleted());
      // Refresh documents list after deletion
      await getDocuments();
    } on DioException catch (e) {
      emit(DocumentError(_formatErrorMessage(e)));
    }
  }

  /// Helper method to format error messages
  String _formatErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return FormatUtils.formatErrorMessage(error);
  }
}
