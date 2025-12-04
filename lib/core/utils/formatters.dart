
/// Formateadores de datos para la aplicación.
/// 
/// Proporciona métodos estáticos para formatear diferentes tipos de datos.
/// 
/// Ejemplo de uso:
/// ```dart
/// Text(Formatters.formatCurrency(250.00, 'PEN')) // "S/ 250.00"
/// Text(Formatters.formatDate(DateTime.now())) // "02 Dic 2025"
/// Text(Formatters.formatPhone('999888777')) // "+51 999 888 777"
/// ```
class Formatters {
  Formatters._();

  // === Currency Formatting ===
  
  /// Formatea un monto como moneda
  /// 
  /// [amount] - Monto a formatear
  /// [currency] - Código de moneda (PEN, USD, etc.)
  static String formatCurrency(double amount, [String currency = 'PEN']) {
    final symbol = switch (currency.toUpperCase()) {
      'PEN' => 'S/',
      'USD' => '\$',
      'EUR' => '€',
      _ => currency,
    };
    
    // Formatear sin locale para evitar errores de inicialización
    final formattedAmount = amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$symbol $formattedAmount';
  }

  /// Formatea un monto con símbolo corto
  static String formatCurrencyShort(double amount, [String currency = 'PEN']) {
    final symbol = switch (currency.toUpperCase()) {
      'PEN' => 'S/',
      'USD' => '\$',
      'EUR' => '€',
      _ => currency,
    };
    
    if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  // === Date Formatting ===
  
  /// Formatea una fecha en formato corto (02 Dic 2025)
  static String formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// Formatea una fecha en formato largo (02 de Diciembre de 2025)
  static String formatDateLong(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Formatea fecha y hora
  static String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date, $time';
  }

  /// Formatea solo la hora
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea fecha ISO 8601
  static String formatIsoDate(DateTime date) {
    return date.toIso8601String();
  }

  /// Parsea una fecha ISO 8601
  static DateTime? parseIsoDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Formatea fecha relativa (hace 2 horas, ayer, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return formatDate(date);
    }
  }

  // === Phone Formatting ===
  
  /// Formatea un número de teléfono
  /// 
  /// [phone] - Número de teléfono (solo dígitos)
  /// [countryCode] - Código de país (default: +51 para Perú)
  static String formatPhone(String phone, [String countryCode = '+51']) {
    // Remover caracteres no numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 9) {
      // Formato peruano: XXX XXX XXX
      return '$countryCode ${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 10) {
      // Formato con código de área: XX XXXX XXXX
      return '$countryCode ${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 6)} ${cleanPhone.substring(6)}';
    }
    
    return '$countryCode $cleanPhone';
  }

  /// Oculta parte del número de teléfono
  static String maskPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length >= 4) {
      return '***${cleanPhone.substring(cleanPhone.length - 4)}';
    }
    return '****';
  }

  // === Vehicle Formatting ===
  
  /// Formatea el kilometraje
  static String formatMileage(int mileage) {
    // Formatear sin locale para evitar errores de inicialización
    final formattedMileage = mileage.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formattedMileage km';
  }

  /// Formatea el kilometraje de forma corta
  static String formatMileageShort(int mileage) {
    if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}k km';
    }
    return '$mileage km';
  }

  /// Formatea una placa de vehículo
  static String formatLicensePlate(String plate) {
    // Convertir a mayúsculas y agregar guión si no tiene
    final cleanPlate = plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanPlate.length == 6) {
      return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
    }
    return plate.toUpperCase();
  }

  // === Text Formatting ===
  
  /// Capitaliza la primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Trunca el texto con ellipsis
  static String truncate(String text, int maxLength, [String ellipsis = '...']) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // === Number Formatting ===
  
  /// Formatea un número con separadores de miles
  static String formatNumber(num number) {
    // Formatear sin locale para evitar errores de inicialización
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formatea un decimal con precisión
  static String formatDecimal(double number, [int decimals = 2]) {
    return number.toStringAsFixed(decimals);
  }

  /// Formatea un porcentaje
  static String formatPercentage(double value, [int decimals = 0]) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // === Rating Formatting ===
  
  /// Formatea un rating (4.5 ⭐)
  static String formatRating(double rating, [bool showStar = true]) {
    final formatted = rating.toStringAsFixed(1);
    return showStar ? '$formatted ⭐' : formatted;
  }
}

