part of 'user_search_bloc.dart';

sealed class UserSearchEvent extends Equatable {
  const UserSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchTermChanged extends UserSearchEvent {
  final String term;

  const SearchTermChanged(this.term);

  @override
  List<Object> get props => [term];
}

class ClearSearch extends UserSearchEvent {} 