/// Validadores para formularios.
/// 
/// Proporciona métodos estáticos para validar campos de formulario.
/// Retornan null si el valor es válido, o un mensaje de error si no lo es.
/// 
/// Ejemplo de uso:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
///   // ...
/// )
/// 
/// TextFormField(
///   validator: (value) => Validators.required(value, 'Nombre'),
///   // ...
/// )
/// ```
class Validators {
  Validators._();

  /// Expresiones regulares
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^[0-9]{9,15}$');
  static final RegExp _licensePlateRegex = RegExp(r'^[A-Za-z0-9]{1,3}[-\s]?[A-Za-z0-9]{2,4}$');
  static final RegExp _vinRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  /// Valida que el campo no esté vacío
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email es requerido';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida formato de contraseña
  /// Mínimo 8 caracteres
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  /// Valida que la contraseña de confirmación coincida
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida formato de teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Teléfono es requerido';
    }
    // Remover espacios y guiones para validar
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-+()]'), '');
    if (!_phoneRegex.hasMatch(cleanPhone)) {
      return 'Ingresa un teléfono válido (9-15 dígitos)';
    }
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName no puede exceder $max caracteres';
    }
    return null;
  }

  /// Valida rango de longitud
  static String? lengthRange(String? value, int min, int max, String fieldName) {
    if (value == null || value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    if (value.length > max) {
      return '$fieldName no puede exceder $max caracteres';
    }
    return null;
  }

  /// Valida formato de placa de vehículo
  static String? licensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Placa es requerida';
    }
    if (!_licensePlateRegex.hasMatch(value.trim())) {
      return 'Ingresa una placa válida (ej: ABC-123)';
    }
    return null;
  }

  /// Valida formato de VIN (Vehicle Identification Number)
  /// 17 caracteres alfanuméricos (sin I, O, Q)
  static String? vin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // VIN es opcional
    }
    if (value.length != 17) {
      return 'El VIN debe tener exactamente 17 caracteres';
    }
    if (!_vinRegex.hasMatch(value.toUpperCase())) {
      return 'VIN inválido (no puede contener I, O, Q)';
    }
    return null;
  }

  /// Valida que sea un número
  static String? number(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName debe ser un número';
    }
    return null;
  }

  /// Valida que sea un número positivo
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número';
    }
    if (number < 0) {
      return '$fieldName no puede ser negativo';
    }
    return null;
  }

  /// Valida que sea un año válido (1900 - año actual + 1)
  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Año es requerido';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Ingresa un año válido';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Año debe estar entre 1900 y ${currentYear + 1}';
    }
    return null;
  }

  /// Valida nombre (solo letras y espacios)
  static String? name(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    if (value.length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }
    if (value.length > 50) {
      return '$fieldName no puede exceder 50 caracteres';
    }
    return null;
  }

  /// Valida código OTP (6 dígitos)
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Código es requerido';
    }
    if (value.length != 6 || int.tryParse(value) == null) {
      return 'Ingresa un código de 6 dígitos';
    }
    return null;
  }

  /// Combina múltiples validadores
  /// Retorna el primer error encontrado
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}

