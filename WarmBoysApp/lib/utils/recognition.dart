import 'dart:ui';

class Recognition {
  String name;
  String username;
  String memberType;
  Rect location;
  List<double> embeddings;
  double distance;

  /// Constructs a Category.
  Recognition(this.name, this.username, this.memberType, this.location,
      this.embeddings, this.distance);
}
