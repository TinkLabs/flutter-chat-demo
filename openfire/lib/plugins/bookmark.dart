import 'package:openfire/core.dart';
import 'package:openfire/enums.dart';
import 'package:openfire/plugins/plugins.dart';
import 'package:xml/xml.dart' as xml;

class BookMarkPlugin extends PluginClass {
  init(ChatConnection connection) {
    this.connection = connection;
    ChatUtil.addNamespace('PRIVATE', 'jabber:iq:private');
    ChatUtil.addNamespace('BOOKMARKS', 'storage:bookmarks');
    ChatUtil.addNamespace('PRIVACY', 'jabber:iq:privacy');
    ChatUtil.addNamespace('DELAY', 'jabber:x:delay');
    ChatUtil.addNamespace('PUBSUB', 'http://jabber.org/protocol/pubsub');
  }

  ///
  /// Create private bookmark node.
  ///
  /// @param {function} [success] - Callback after success
  /// @param {function} [error] - Callback after error
  ///
  bool createBookmarksNode([Function success, Function error]) {
    // We do this instead of using publish-options because this is not
    // mandatory to implement according to XEP-0060
    this.connection.sendIQ(
        ChatUtil.$iq({'type': 'set'})
            .c('pubsub', {'xmlns': ChatUtil.NS['PUBSUB']})
            .c('create', {'node': ChatUtil.NS['BOOKMARKS']})
            .up()
            .c('configure')
            .c('x', {'xmlns': 'jabber:x:data', 'type': 'submit'})
            .c('field', {'var': 'FORM_TYPE', 'type': 'hidden'})
            .c('value')
            .t('http://jabber.org/protocol/pubsub#node_config')
            .up()
            .up()
            .c('field', {'var': 'pubsub#persist_items'})
            .c('value')
            .t('1')
            .up()
            .up()
            .c('field', {'var': 'pubsub#access_model'})
            .c('value')
            .t('whitelist')
            .tree(),
        success,
        error);

    return true;
  }

  /* *
	 * Add bookmark to storage or update it.
	 *
	 * The specified room is bookmarked into the remote bookmark storage. If the room is
	 * already bookmarked, then it is updated with the specified arguments.
	 *
	 * @param {string} roomJid - The JabberID of the chat roomJid
	 * @param {string} [alias] - A friendly name for the bookmark
	 * @param {string} [nick] - The users's preferred roomnick for the chatroom
	 * @param {boolean} [autojoin=false] - Whether the client should automatically join
	 * the conference room on login.
	 * @param {function} [success] - Callback after success
	 * @param {function} [error] - Callback after error
	 */
  add(String roomJid, String alias,
      [String nick, bool autojoin = true, Function success, Function error]) {
    StanzaBuilder stanza = ChatUtil.$iq({'type': 'set'})
        .c('pubsub', {'xmlns': ChatUtil.NS['PUBSUB']}).c('publish', {
      'node': ChatUtil.NS['BOOKMARKS']
    }).c('item', {'id': 'current'}).c(
            'storage', {'xmlns': ChatUtil.NS['BOOKMARKS']});

    Function _bookmarkGroupChat = (bool bookmarkit) {
      if (bookmarkit) {
        Map<String, Object> conferenceAttr = {
          'jid': roomJid,
          'autojoin': autojoin || false
        };

        if (alias != null && alias.isNotEmpty) {
          conferenceAttr['name'] = alias;
        }

        stanza.c('conference', conferenceAttr);
        if (nick != null && nick.isNotEmpty) {
          stanza.c('nick').t(nick);
        }
      }

      this.connection.sendIQ(stanza.tree(), success, error);
    };

    this.get((xml.XmlElement s) {
      List<xml.XmlElement> confs = s.findAllElements('conference').toList();
      bool bookmarked = false;
      for (int i = 0; i < confs.length; i++) {
        Map<String, dynamic> conferenceAttr = {
          'jid': confs[i].getAttribute('jid'),
          'autojoin': confs[i].getAttribute('autojoin') ?? false
        };
        String roomName = confs[i].getAttribute('name');
        List<xml.XmlElement> nickname =
            confs[i].findAllElements('nick').toList();

        if (conferenceAttr['jid'] == roomJid) {
          // the room is already bookmarked, then update it
          bookmarked = true;

          conferenceAttr['autojoin'] = autojoin || false;

          if (alias != null && alias.isNotEmpty) {
            conferenceAttr['name'] = alias;
          }
          stanza.c('conference', conferenceAttr);

          if (nick != null && nick.isNotEmpty) {
            stanza.c('nick').t(nick).up();
          }
        } else {
          if (roomName != null && roomName.isNotEmpty) {
            conferenceAttr['name'] = roomName;
          }
          stanza.c('conference', conferenceAttr);

          if (nickname.length == 1) {
            stanza.c('nick').t(nickname[0].text).up();
          }
        }

        stanza.up();
      }

      _bookmarkGroupChat(!bookmarked);
    }, (xml.XmlElement s) {
      if (s.findAllElements('item-not-found').length > 0) {
        _bookmarkGroupChat(true);
      } else {
        error(s);
      }
    });
  }

  /* *
	 * Retrieve all stored bookmarks.
	 *
	 * @param {function} [success] - Callback after success
	 * @param {function} [error] - Callback after error
	 */
  get([Function success, Function error]) {
    this.connection.sendIQ(
        ChatUtil.$iq({'type': 'get'})
            .c('pubsub', {'xmlns': ChatUtil.NS['PUBSUB']}).c(
                'items', {'node': ChatUtil.NS['BOOKMARKS']}).tree(),
        success,
        error);
  }

  /* *
	 * Delete the bookmark with the given roomJid in the bookmark storage.
	 *
	 * The whole remote bookmark storage is just updated by removing the
	 * bookmark corresponding to the specified room.
	 *
	 * @param {string} roomJid - The JabberID of the chat roomJid you want to remove
	 * @param {function} [success] - Callback after success
	 * @param {function} [error] - Callback after error
	 */
  delete(String roomJid, [Function success, Function error]) {
    StanzaBuilder stanza = ChatUtil.$iq({'type': 'set'})
        .c('pubsub', {'xmlns': ChatUtil.NS['PUBSUB']}).c('publish', {
      'node': ChatUtil.NS['BOOKMARKS']
    }).c('item', {'id': 'current'}).c(
            'storage', {'xmlns': ChatUtil.NS['BOOKMARKS']});

    this.get((xml.XmlElement s) {
      List<xml.XmlElement> confs = s.findAllElements('conference').toList();
      for (int i = 0; i < confs.length; i++) {
        Map<String, dynamic> conferenceAttr = {
          'jid': confs[i].getAttribute('jid'),
          'autojoin': confs[i].getAttribute('autojoin')
        };
        if (conferenceAttr['jid'] == roomJid) {
          continue;
        }
        String roomName = confs[i].getAttribute('name');
        if (roomName != null && roomName.isNotEmpty) {
          conferenceAttr['name'] = roomName;
        }
        stanza.c('conference', conferenceAttr);
        List<xml.XmlElement> nickname =
            confs[i].findAllElements('nick').toList();
        if (nickname.length == 1) {
          stanza.c('nick').t(nickname[0].text).up();
        }
        stanza.up();
      }
      this.connection.sendIQ(stanza.tree(), success, error);
    }, (s) {
      error(s);
    });
  }

  /* *
	 * Update the bookmark with the given roomJid in the bookmark storage.
	 *
	 * The whole remote bookmark storage is just updated by updating the
	 * bookmark corresponding to the specified room.
	 *
	 * @param {string} roomJid - The JabberID of the chat roomJid you want to remove
	 * @param {function} [success] - Callback after success
	 * @param {function} [error] - Callback after error
	 */
  update(String roomJid, String alias,
      [String nick, bool autojoin = true, Function success, Function error]) {
    StanzaBuilder stanza = ChatUtil.$iq({'type': 'set'})
        .c('pubsub', {'xmlns': ChatUtil.NS['PUBSUB']}).c('publish', {
      'node': ChatUtil.NS['BOOKMARKS']
    }).c('item', {'id': 'current'}).c(
            'storage', {'xmlns': ChatUtil.NS['BOOKMARKS']});

    this.get((xml.XmlElement s) {
      List<xml.XmlElement> confs = s.findAllElements('conference').toList();
      for (int i = 0; i < confs.length; i++) {
        Map<String, dynamic> conferenceAttr = {
          'jid': confs[i].getAttribute('jid'),
          'autojoin': confs[i].getAttribute('autojoin'),
          'name': confs[i].getAttribute('name')
        };
        if (conferenceAttr['jid'] == roomJid) {
          conferenceAttr['autojoin'] = autojoin ?? conferenceAttr['autojoin'];
          String roomName = confs[i].getAttribute('name');
          if (alias != null && alias.isNotEmpty) roomName = alias;
          conferenceAttr['name'] = roomName ?? '';
        }
        stanza.c('conference', conferenceAttr);
        List<xml.XmlElement> nickname =
            confs[i].findAllElements('nick').toList();
        if (nick != null &&
            nick.isNotEmpty &&
            conferenceAttr['jid'] == roomJid) {
          stanza.c('nick').t(nick).up();
        } else if (nickname.length == 1) {
          stanza.c('nick').t(nickname[0].text).up();
        }
        stanza.up();
      }
      this.connection.sendIQ(stanza.tree(), success, error);
    }, (s) {
      error(s);
    });
  }
}
