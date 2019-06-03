import 'package:flutter/material.dart';
import 'package:flutter_chat/util/adapt.dart';

const Color txtBlack = Color(0xFF1F1F1F);
const Color txtGray  = Color(0xFF858585);
const Color txtGold     = Color(0xFFC19A53);
const Color txtWhite = Colors.white;

class TextStyles {
  TextStyles._();
  static final headLine = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(20),
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: txtBlack
  );
  static final subtitle1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(16),
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: txtGray
  );
  static final subtitle2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(14),
    fontWeight: FontWeight.w600,
    height: 1.29,
    color: txtBlack
  );
  static final body1 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(16),
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: txtGray
  );
  static final body2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(14),
    fontWeight: FontWeight.normal,
    height: 1.43,
    color: txtBlack
  );
  static final caption = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(12),
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: txtBlack
  );
  static final bartext = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: px(10),
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: txtBlack
  );
}

const Color pink50 = Color(0xFFFEEAE6);
const Color pink100 = Color(0xFFFEDBD0);
const Color pink300 = Color(0xFFFBB8AC);
const Color pink400 = Color(0xFFEAA4A4);

const Color brown900 = Color(0xFF442B2D);
const Color brown600 = Color(0xFF7D4F52);

const Color errorRed = Color(0xFFC5032B);

const Color surfaceWhite = Color(0xFFFFFBFA);
const Color backgroundWhite = Colors.white;