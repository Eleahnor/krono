// lib/models/amistad.dart

enum EstadoAmistad { pendiente, aceptada, rechazada }

class Amistad {
  final String id;
  final String deAlumnoId;
  final String paraAlumnoId;
  final EstadoAmistad estado;

  const Amistad({
    required this.id,
    required this.deAlumnoId,
    required this.paraAlumnoId,
    this.estado = EstadoAmistad.pendiente,
  });

  Amistad copyWith({EstadoAmistad? estado}) => Amistad(
        id: id,
        deAlumnoId: deAlumnoId,
        paraAlumnoId: paraAlumnoId,
        estado: estado ?? this.estado,
      );
}
