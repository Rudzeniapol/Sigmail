import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart';
import 'package:sigmail_client/domain/repositories/user_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'user_search_event.dart';
part 'user_search_state.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserRepository _userRepository;

  UserSearchBloc({required UserRepository userRepository}) 
      : _userRepository = userRepository,
        super(UserSearchInitial()) {
    on<SearchTermChanged>(
      _onSearchTermChanged,
      // Применяем debounce для события SearchTermChanged
      // Это означает, что событие будет обработано только если 
      // не было других событий SearchTermChanged в течение 500 мс.
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).asyncExpand(mapper),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchTermChanged(
    SearchTermChanged event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.term.isEmpty) {
      emit(UserSearchInitial());
      return;
    }

    emit(UserSearchLoading());
    final failureOrUsers = await _userRepository.searchUsers(event.term);
    failureOrUsers.fold(
      (failure) => emit(UserSearchError(failure.message)),
      (users) => emit(UserSearchLoaded(users)),
    );
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<UserSearchState> emit,
  ) {
    emit(UserSearchInitial());
  }
} 