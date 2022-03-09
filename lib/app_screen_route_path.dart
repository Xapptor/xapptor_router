// AppScreenRoutePath model.

class AppScreenRoutePath {
  final String? name;
  final bool is_unknown;

  AppScreenRoutePath.landing()
      : name = null,
        is_unknown = false;

  AppScreenRoutePath.details(
    this.name,
  ) : is_unknown = false;

  AppScreenRoutePath.unknown()
      : name = null,
        is_unknown = true;

  bool get is_landing_page => name == null;

  bool get is_details_page => name != null;
}
