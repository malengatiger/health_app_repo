import 'dart:math';

import '../util.dart';

class RandomImage {
  static List<String> images = [];
  static Random _random = Random(DateTime.now().millisecondsSinceEpoch);
  RandomImage() {
    p('RandomImage constructor 🔆 🔆 🔆 🔆 ');
    _loadImages();
  }

  static List<String> getImageList(int count) {
    if (count > images.length) {
      throw Exception("Not enough images to satisfy your needs");
    }
    var list = [];
    for (var i = 0; i < count; i++) {
      list.add(images[i]);
    }

    return list as List<String>;
  }

  static _loadImages() {
    for (var index = 0; index < 31; index++) {
      images.add('assets/images/m${index + 1}.jpeg');
    }
  }

  static String getImagePath() {
    if (images.isEmpty) {
      _loadImages();
    }
    int index = _random.nextInt(images.length - 1);
    return images.elementAt(index);
  }
}
