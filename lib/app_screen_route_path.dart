class AppScreenRoutePath {
  final String? name;
  final bool is_unknown;

  AppScreenRoutePath.home()
      : name = null,
        is_unknown = false;

  AppScreenRoutePath.details(
    this.name,
  ) : is_unknown = false;

  AppScreenRoutePath.unknown()
      : name = null,
        is_unknown = true;

  bool get is_home_page => name == null;

  bool get is_details_page => name != null;
}
