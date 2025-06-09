import 'package:hive/hive.dart';

Future<void> saveLastRoute(String route, [Map<String, String>? params]) async {
  final box = await Hive.openBox('app_box');
  await box.put('last_route', route);
  if (params != null) {
    await box.put('last_route_params', params);
  }
}

Future<String?> getLastRoute() async {
  final box = await Hive.openBox('app_box');
  return box.get('last_route');
}

Future<Map<String, String>> getLastRouteParams([List<String>? keys]) async {
  final box = await Hive.openBox('app_box');
  Map? params = box.get('last_route_params');
  if (params == null) return {};
  if (keys == null) {
    return Map<String, String>.from(params);
  } else {
    return {
      for (var k in keys) k: (params[k] ?? '').toString(),
    };
  }
}

Future<String?> getRouteParam(String key) async {
  final box = await Hive.openBox('app_box');
  Map? params = box.get('last_route_params');
  if (params == null) return null;
  return params[key]?.toString();
}

Future<void> clearLastRoute() async {
  final box = await Hive.openBox('app_box');
  await box.delete('last_route');
  await box.delete('last_route_params');
}
