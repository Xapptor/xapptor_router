String remove_last_path_segment(Uri uri) {
  int path_segments_index = int.tryParse(uri.pathSegments.last.substring(uri.pathSegments.last.length - 1)) ?? -1;
  String new_path = "";

  bool path_has_underscore = uri.pathSegments.last.substring(uri.pathSegments.last.length - 2) == "_";

  if (path_segments_index > 0 && path_has_underscore) {
    new_path = uri.path.substring(0, uri.path.length - 1) + (path_segments_index - 1).toString();
  } else {
    int last_path_segment_index = uri.path.lastIndexOf("/");
    new_path = uri.path.substring(0, last_path_segment_index);
  }
  return new_path;
}
