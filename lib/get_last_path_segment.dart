import 'app_screens.dart';

String get_last_path_segment() {
  return Uri.parse(app_screens.last.name).pathSegments.last;
}
