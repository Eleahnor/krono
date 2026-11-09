// lib/models/usuario.dart
enum Rol { alumno, profesor }

enum Turno { matutino, vespertino, mixto }

enum Genero { masculino, femenino, noEspecificado }

class Usuario {
  final String id;
  final String nombre; // sin título (p. ej. "Ramírez")
  final String? apodo;
  final String boleta; // 10 dígitos numéricos (alumno o nº empleado)
  final Rol rol;
  final Turno turno;
  final bool trabaja;
  final String? horarioLaboral;
  final String? correo;
  final String? fotoUrl;
  final Genero genero;

  Usuario({
    required this.id,
    required this.nombre,
    this.apodo,
    required this.boleta,
    required this.rol,
    required this.turno,
    this.trabaja = false,
    this.horarioLaboral,
    this.correo,
    this.fotoUrl,
    this.genero = Genero.noEspecificado,
  });

  /// Para alumnos: apodo si existe, si no nombre.
  /// Para profesores: "Prof. {nombre}" o "Profa. {nombre}" según género.
  String get nombreMostrar {
    if (rol == Rol.profesor) {
      final titulo = genero == Genero.femenino ? 'Profa.' : 'Prof.';
      return '$titulo $nombre';
    }
    return (apodo != null && apodo!.isNotEmpty) ? apodo! : nombre;
  }

  /// Solo el nombre sin título (útil en formularios).
  String get nombreSinTitulo => nombre;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'apodo': apodo,
        'boleta': boleta,
        'rol': rol.name,
        'turno': turno.name,
        'trabaja': trabaja,
        'horarioLaboral': horarioLaboral,
        'correo': correo,
        'fotoUrl': fotoUrl,
        'genero': genero.name,
      };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        id: m['id'],
        nombre: m['nombre'],
        apodo: m['apodo'],
        boleta: m['boleta'],
        rol: Rol.values.byName(m['rol']),
        turno: Turno.values.byName(m['turno']),
        trabaja: m['trabaja'] ?? false,
        horarioLaboral: m['horarioLaboral'],
        correo: m['correo'],
        fotoUrl: m['fotoUrl'],
        genero: Genero.values.byName(m['genero'] ?? Genero.noEspecificado.name),
      );
}
