// Export Update Path Function dynamically for each platform.

export 'update_path_unsupported.dart'
    if (dart.library.html) 'update_path_web.dart'
    if (dart.library.io) 'update_path_mobile.dart';
