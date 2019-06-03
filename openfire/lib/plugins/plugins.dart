import 'package:openfire/enums.dart';

abstract class PluginClass {
  ChatConnection connection;
  Function statusChanged;
  PluginClass();
  init(ChatConnection conn);
}
