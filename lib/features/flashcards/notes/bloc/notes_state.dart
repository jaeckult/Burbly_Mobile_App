import 'package:equatable/equatable.dart';
import '../../../../core/models/note.dart';

enum NotesStatus {
  initial,
  loading,
  success,
  failure,
}

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final List<Note> filteredNotes;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String searchQuery;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.filteredNotes = const [],
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.searchQuery = '',
  });

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    List<Note>? filteredNotes,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? searchQuery,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      errorMessage: errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notes,
        filteredNotes,
        errorMessage,
        isCreating,
        isUpdating,
        isDeleting,
        searchQuery,
      ];
}

