import 'package:flutter/material.dart';
import 'dart:ui';

class Adapt {
    static Adapt adapt320 = Adapt(320); 
    static Adapt adapt360 = Adapt(360);
    static Adapt adapt375 = Adapt(375);

    static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
    static double _screenWidth = mediaQuery.size.width;
    static double _screenHeight = mediaQuery.size.height;
    static double _topBarHeight = mediaQuery.padding.top;
    static double _bottomBarHeight = mediaQuery.padding.bottom;
    static double _pixelRatio = mediaQuery.devicePixelRatio;
    static double _textScaleFactor = mediaQuery.textScaleFactor;

    /// 每个逻辑像素的字体像素数，字体的缩放比例
    static double get textScaleFactory => _textScaleFactor;

    /// 设备的像素密度
    static double get pixelRatio       => _pixelRatio;

    /// 当前设备宽度 dp
    static double get screenWidthDp    => _screenWidth;

    /// 当前设备高度 dp
    static double get screenHeightDp   => _screenHeight;

    /// 当前设备宽度 px
    static double get screenWidth      => _screenWidth * _pixelRatio;

    /// 当前设备高度 px
    static double get screenHeight     => _screenHeight * _pixelRatio;

    /// 状态栏高度 刘海屏会更高
    static double get statusBarHeight  => _topBarHeight * _pixelRatio;

    /// 底部安全区距离
    static double get bottomBarHeight  => _bottomBarHeight * _pixelRatio;

    /// 1px
    static double get onepx            => 1 / _pixelRatio;
    
    double width;     //设计稿宽度
    double height;    //设计稿高度
    double ratio;     //缩放比例
    bool   textScale; //文本缩放
    
    /// 屏幕适配
    /// @width 设计稿高度
    /// @textScale 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false
    Adapt (double width, {bool textScale = false}){
      this.width = width;
      this.textScale = textScale;
      this.ratio = _screenWidth / width;
    }

    /// 计算像素大小
    double px(double number) => number * ratio;

    /// 计算字体大小
    double font(double size) => px(size) / (textScale ? _textScaleFactor : 1);
}

final adapt = Adapt.adapt360;
final px   = Adapt.adapt360.px;
final font = Adapt.adapt360.font;