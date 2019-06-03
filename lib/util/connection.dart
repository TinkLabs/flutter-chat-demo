import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:xml2json/xml2json.dart'; // add this line

class XmppConnection {
  static const String _service = 'ws://10.0.2.71:7070/ws';
  static const String _domain = 'jiangzm-macbookpro.local';
  static const String _group = 'conference.jiangzm-macbookpro.local';
  static XmppConnection _instance;

  static XmppConnection getInstance() {
    if (_instance == null) {
      _instance = new XmppConnection(_service, _domain, _group);
    }
    return _instance;
  }


  String service;
  String domain;
  String group;
  String jid;
  String user;
  String pass;
  String resource;
  String openId;
  WebSocket socket;
  StreamSubscription socketListen;

  Function _onConnected;
  Function _onMessage;

  XmppConnection(String service, String domain, [String group]) {
    this.service = service;
    this.domain = domain;
    this.group = group;
  }

  void connect(String user, String password, Function onConnected) {
    this.user = user;
    this.pass = password;
    this.jid = "$user@${this.domain}";
    this.resource = "flutterClient";
    this._onConnected = onConnected;
    this._connect();
  }
  
  void onMessage(Function callback) {
    this._onMessage = callback;
  } 

  void _connect() {
    WebSocket.connect(this.service, protocols: ['xmpp'])
        .then((WebSocket socket) {
      this.socket = socket;
      this.socketListen = this.socket.listen(
          this._onData,
          onError: this._onError,
          onDone: this._onClose,
          cancelOnError: false
      );
      this.sendOpenMessage(null);
    }).catchError((e) {
      print(e);
    });
  }

  _onData(dynamic message) {
    print('receive:'+message);

    Xml2Json xml2json = new Xml2Json();
    xml2json.parse(message);

    var jsondata = json.decode(xml2json.toGData());


    if (jsondata['message'] != null) {
      if (jsondata['message']['body'] != null) {
        print("收到的消息："+ jsondata['message']['body']['\$t']);
        if (this._onMessage != null) {
          Map<String,String> msg = Map<String,String>();
          msg["formChatId"] = jsondata['message']['stanza-id']['by'];
          msg["messageId"] =  jsondata['message']['id'];
          msg["from"] =  jsondata['message']['from'];
          msg["to"] =  jsondata['message']['to'];
          msg["body"] =  jsondata['message']['body']['\$t'];
          msg["type"] = '0';
          msg["time"] =  '';
          msg["from"] = msg["from"].substring(msg["from"].indexOf('/')+1);
          this._onMessage(msg);
        }

      } else if (jsondata['message']['composing'] != null) {
        print("对方正在输入");

      } else if (jsondata['message']['gone'] != null) {
        print("对方已关闭和您的聊天");

      } else if (jsondata['message']['file'] != null) {
        print("收到的文件："+ jsondata.message);

      } else {

      }
    } else if (jsondata['open'] != null) {
      this.openId = jsondata['open']['id'];

    } else if (jsondata["stream\$features"] != null) {
      if (jsondata["stream\$features"]['mechanisms'] != null) {
        this.sendAuthMessage();

      } else if (jsondata["stream\$features"]['bind'] != null) {
        this.sendIqBindMessage();

      } else {
        //Do-nothing
      }
    } else if (jsondata['failure'] != null) {
      print('登录失败，用户名或者密码错误;');

    } else if (jsondata['success'] != null) {
      this.sendOpenMessage(this.openId);

    } else if (jsondata['iq'] != null) {
      if (jsondata['iq']['bind'] != null) {
        this.sendIqSessionMessage();

      } else {
        this.sendPresenceOnlineMessage();
        if (this._onConnected != null) {
          this._onConnected(true);
        }
      }
    } else {
      //Do-nothing
    }
  }

  _onError(Object error) {
    print(error);
  }

  _onClose() {
    print('websocket closed');
  }

  _send(xmlMessage) {
    if (xmlMessage != null && xmlMessage != "") {
      this.socket.add(xmlMessage);
      print('send:'+xmlMessage);
    }
  }

  sendOpenMessage(String id) {
    String openMessage = '<open to="${this.domain}" from="${this.jid}" id="$id" xmlns="urn:ietf:params:xml:ns:xmpp-framing" xml:lang="zh" version="1.0" />';
    this._send(openMessage);
  }

  sendAuthMessage() {
    String token = base64.encode(utf8.encode('${this.jid}\u0000${this.user}\u0000${this.pass}'));
    String authMessage = '<auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="PLAIN">$token</auth>';
    this._send(authMessage);
  }

  sendIqBindMessage() {
    String iqMessage = '<iq id="${this.openId}" type="set"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><resource>${this.resource}</resource></bind></iq>';
    this._send(iqMessage);
  }

  sendIqSessionMessage() {
    String iqMessage = '<iq xmlns="jabber:client" id="${this.openId}" type="set"><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /></iq>';
    this._send(iqMessage);
  }

  sendPresenceOnlineMessage() {
    String presenceMessage = '<presence id="${this.openId}"><status>online</status><priority>1</priority></presence>';
    this._send(presenceMessage);
  }

  sendJoinRoomMessage(roomId) {
    String joinMessage = '<presence from="${this.jid}/${this.resource}"  to="$roomId@${this.group}/${this.user}" />';
    this._send(joinMessage);
  }

  sendGroupMessage(roomId, content) {
    String msg = '<message from ="${this.jid}/${this.resource}"  to="$roomId@${this.group}"  type="groupchat"><body>${content}</body></message>';
    this._send(msg);
  }
}