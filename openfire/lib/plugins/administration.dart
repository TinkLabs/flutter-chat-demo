import 'package:openfire/core.dart';
import 'package:openfire/enums.dart';
import 'package:openfire/plugins/plugins.dart';

class AdministrationPlugin extends PluginClass {
  @override
  init(ChatConnection conn) {
    this.connection = conn;
    if (ChatUtil.NS['COMMANDS'] == null)
      ChatUtil.addNamespace('COMMANDS', 'http://jabber.org/protocol/commands');
    ChatUtil.addNamespace('REGISTERED_USERS_NUM',
        'http://jabber.org/protocol/admin#get-registered-users-num');
    ChatUtil.addNamespace('ONLINE_USERS_NUM',
        'http://jabber.org/protocol/admin#get-online-users-num');
  }

  getRegisteredUsersNum(Function success, [Function error]) {
    String id = this.connection.getUniqueId('get-registered-users-num');
    this.connection.sendIQ(
        ChatUtil.$iq({
          'type': 'set',
          'id': id,
          'xml:lang': 'en',
          'to': this.connection.domain
        }).c('command', {
          'xmlns': ChatUtil.NS['COMMANDS'],
          'action': 'execute',
          'node': ChatUtil.NS['REGISTERED_USERS_NUM']
        }).tree(),
        success,
        error);
    return id;
  }

  getOnlineUsersNum(Function success, [Function error]) {
    String id = this.connection.getUniqueId('get-registered-users-num');
    this.connection.sendIQ(
        ChatUtil.$iq({
          'type': 'set',
          'id': id,
          'xml:lang': 'en',
          'to': this.connection.domain
        }).c('command', {
          'xmlns': ChatUtil.NS['COMMANDS'],
          'action': 'execute',
          'node': ChatUtil.NS['ONLINE_USERS_NUM']
        }).tree(),
        success,
        error);
    return id;
  }
}
