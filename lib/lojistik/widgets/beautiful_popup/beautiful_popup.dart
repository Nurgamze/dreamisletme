library beautiful_popup;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'templates/Common.dart';
import 'templates/Term.dart';
import 'templates/Thumb.dart';

export 'templates/Common.dart';
export 'templates/Term.dart';
export 'templates/Thumb.dart';

class BeautifulPopup {
  BuildContext _context;
  BuildContext get context => _context;

  Type? _template;
  Type? get template => _template;

  BeautifulPopupTemplate Function(BeautifulPopup options)? _build;
  BeautifulPopupTemplate get instance {
    final build = _build;
    if (build != null) return build(this);
    switch (template) {
      case TemplateThumb:
        return TemplateThumb(this);
      case TemplateTerm:
        return TemplateTerm(this);
      default:
        return TemplateThumb(this);
    }
  }

  ui.Image? _illustration;
  ui.Image? get illustration => _illustration;

  dynamic title = '';
  dynamic content = '';
  List<Widget>? actions;
  Widget? close;
  bool? barrierDismissible;

  Color? primaryColor;

  BeautifulPopup({
    required BuildContext context,
    required Type? template,
  })   : _context = context,
        _template = template {
    primaryColor = instance.primaryColor; // Get the default primary color.
  }

  static BeautifulPopup customize({
    required BuildContext context,
    required BeautifulPopupTemplate Function(BeautifulPopup options) build,
  }) {
    final popup = BeautifulPopup(
      context: context,
      template: null,
    );
    popup._build = build;
    return popup;
  }

  /// Recolor the BeautifulPopup.
  /// This method is  kind of slow.R
  Future<BeautifulPopup> recolor(Color color) async {
    this.primaryColor = color;
    final illustrationData = await rootBundle.load(instance.illustrationKey);
    final buffer = illustrationData.buffer.asUint8List();
    img.Image? asset;
    asset = img.decodeImage(buffer);
    if (asset != null) {
      img.adjustColor(
        asset,
        saturation: 0,
        // hue: 0,
      );
      img.colorOffset(
        asset,
        red: color.red,
        // I don't know why the effect is nicer with the number ╮(╯▽╰)╭
        green: color.green ~/ 3,
        blue: color.blue ~/ 2,
        alpha: 0,
      );
    }
    final paint = await PaintingBinding.instance.instantiateImageCodec(
        asset != null ? Uint8List.fromList(img.encodePng(asset)) : buffer);
    final nextFrame = await paint.getNextFrame();
    _illustration = nextFrame.image;
    return this;
  }

  Future<T?> show<T>({
    dynamic title,
    dynamic content,
    List<Widget>? actions,
    bool barrierDismissible = false,
    Widget? close,
  }) {
    this.title = title;
    this.content = content;
    this.actions = actions;
    this.barrierDismissible = barrierDismissible;
    this.close = close ?? instance.close;
    final child = WillPopScope(
      onWillPop: () {
        return Future.value(barrierDismissible);
      },
      child: instance,
    );
    return showGeneralDialog<T>(
      barrierColor: Colors.black38,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierDismissible ? 'beautiful_popup' : null,
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return child;
      },
      transitionDuration: Duration(milliseconds: 150),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: child,
          ),
        );
      },
    );
  }

  BeautifulPopupButton get button => instance.button;
}
