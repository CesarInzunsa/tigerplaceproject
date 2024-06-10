class CalificacionModel {
  String id;
  String usuarioId;
  int puntuacion;

  CalificacionModel.empty()
      : id = '',
        usuarioId = '',
        puntuacion = 0;

  CalificacionModel({
    this.id = '',
    required this.usuarioId,
    required this.puntuacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'puntuacion': puntuacion,
    };
  }
}
