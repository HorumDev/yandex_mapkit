part of yandex_mapkit;


/// Information about driving route metadata.
class PedastrianSectionMetadata extends Equatable {

  /// Route "weight".
  final PedastrianWeight weight;

  PedastrianSectionMetadata._(this.weight);

  factory PedastrianSectionMetadata._fromJson(Map<dynamic, dynamic> json) {
    return PedastrianSectionMetadata._(PedastrianWeight._fromJson(json['weight']));
  }

  @override
  List<Object> get props => <Object>[
    weight,
  ];

  @override
  bool get stringify => true;
}

/// Quantitative characteristics of any segment of the route.
class PedastrianWeight extends Equatable {

  /// Time to travel, not considering traffic.
  final LocalizedValue time;



  /// Distance to travel.
  final LocalizedValue distance;

  PedastrianWeight._(this.time, this.distance);

  factory PedastrianWeight._fromJson(Map<dynamic, dynamic> json) {
    return PedastrianWeight._(
      LocalizedValue._fromJson(json['time']),
      LocalizedValue._fromJson(json['distance']),
    );
  }

  @override
  List<Object> get props => <Object>[
    time,
    distance,
  ];

  @override
  bool get stringify => true;
}
