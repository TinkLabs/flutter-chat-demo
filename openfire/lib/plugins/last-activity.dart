import 'package:openfire/core.dart';
import 'package:openfire/enums.dart';
import 'package:openfire/plugins/plugins.dart';

class LastActivity extends PluginClass {
  init(ChatConnection conn) {
    this.connection = conn;
    ChatUtil.addNamespace('LAST_ACTIVITY', "jabber:iq:last");
  }

  getLastActivity(String jid, Function success, [Function error]) {
    String id = this.connection.getUniqueId('last1');
    this.connection.sendIQ(
        ChatUtil.$iq({'id': id, 'type': 'get', 'to': jid}).c(
            'query', {'xmlns': ChatUtil.NS['LAST_ACTIVITY']}).tree(),
        success,
        error);
  }
}
