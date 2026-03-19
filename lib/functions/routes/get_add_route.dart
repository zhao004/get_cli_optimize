import 'dart:io';

import 'package:recase/recase.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../core/structure.dart';
import '../../extensions.dart';
import '../../samples/impl/get_route.dart';
import '../find_file/find_file_by_name.dart';
import 'get_app_pages.dart';
import 'get_support_children.dart';

/// This command will create the route to the new page
void addRoute(String nameRoute, String bindingDir, String viewDir) {
  var routesFile = findFileByName('app_routes.dart');
  // var content = '';

  if (routesFile.path.isEmpty) {
    RouteSample().create();
    routesFile = File(RouteSample().path);
    // content = routesFile.readAsStringSync();
  }
  final pathSplit = Structure.routePathSegments(
    viewDir,
    removeLeafFolder: PubspecUtils.extraFolder ?? true,
  );

  for (var i = 0; i < pathSplit.length; i++) {
    pathSplit[i] =
        pathSplit[i].snakeCase.snakeCase.toLowerCase().replaceAll('_', '-');
  }
  var route = pathSplit.join('/');

  var declareRoute = 'static const ${nameRoute.snakeCase.toUpperCase()} =';
  var line = "$declareRoute '/$route';";
  if (supportChildrenRoutes) {
    final routePath =
        pathSplit.isEmpty ? nameRoute.snakeCase : _pathsToRoute(pathSplit);
    line = '$declareRoute $routePath;';
    final currentPath =
        pathSplit.isEmpty ? nameRoute.snakeCase : pathSplit.last;
    var linePath = "$declareRoute '/$currentPath';";
    routesFile.appendClassContent('_Paths', linePath);
  }
  routesFile.appendClassContent('Routes', line);

  addAppPage(nameRoute, bindingDir, viewDir);

  LogService.success(
      Translation(LocaleKeys.sucess_route_created).trArgs([nameRoute]));
}

/// Create routes from the path
String _pathsToRoute(List<String> pathSplit) {
  var sb = StringBuffer();
  for (var e in pathSplit) {
    sb.write('_Paths.');
    sb.write(e.snakeCase.toUpperCase());
    if (e != pathSplit.last) {
      sb.write(' + ');
    }
  }
  return sb.toString();
}
