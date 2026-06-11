/// Canonical path constants for GoRouter.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const records = '/records';
  static const upload = '/upload';
  static const settings = '/settings';

  /// Record detail nested under the records tab.
  static String recordDetail(String documentId) => '/records/$documentId';

  /// Tab branch index for [StatefulNavigationShell.goBranch].
  static const shellBranches = <String, int>{
    home: 0,
    records: 1,
    upload: 2,
    settings: 3,
  };

  static int branchIndexForPath(String path) {
    return shellBranches[path] ?? 0;
  }
}
