package com.unact.yandexmapkitexample;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

import com.yandex.mapkit.MapKitFactory;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    MapKitFactory.setLocale("YOUR_LOCALE");
    MapKitFactory.setApiKey("9b598cce-8311-4ae5-8fc5-b536013023f2");
    super.configureFlutterEngine(flutterEngine);
  }
}
