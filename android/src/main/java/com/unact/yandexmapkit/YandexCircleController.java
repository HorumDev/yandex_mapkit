package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.CircleMapObject;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;

import java.lang.ref.WeakReference;
import java.util.Map;

public class YandexCircleController extends YandexMapObjectController implements MapObjectTapListener {
  private final boolean internallyControlled;
  public final CircleMapObject circle;
  private boolean consumeTapEvents = false;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"ConstantConditions"})
  public YandexCircleController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    CircleMapObject circle = parent.addCircle(
      Utils.circleFromJson(params),
      ((Number) params.get("strokeColor")).intValue(),
      ((Double) params.get("strokeWidth")).floatValue(),
      ((Number) params.get("fillColor")).intValue()
    );

    this.circle = circle;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.internallyControlled = false;

    circle.setUserData(this.id);
    circle.addTapListener(this);
    update(params);
  }

  public YandexCircleController(
    CircleMapObject circle,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    this.circle = circle;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.internallyControlled = true;

    circle.setUserData(id);
    circle.addTapListener(this);
    update(params);
  }

  @SuppressWarnings({"ConstantConditions"})
  public void update(Map<String, Object> params) {
    if (!internallyControlled) {
      circle.setGeometry(Utils.circleFromJson(params));
      circle.setVisible((Boolean) params.get("isVisible"));
    }

    circle.setGeodesic((Boolean) params.get("isGeodesic"));
    circle.setZIndex(((Double) params.get("zIndex")).floatValue());
    circle.setStrokeColor(((Number) params.get("strokeColor")).intValue());
    circle.setStrokeWidth(((Double) params.get("strokeWidth")).floatValue());
    circle.setFillColor(((Number) params.get("fillColor")).intValue());

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    if (internallyControlled) {
      return;
    }

    circle.getParent().remove(circle);
  }

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
