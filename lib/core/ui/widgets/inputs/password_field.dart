import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Campo de contraseña con toggle de visibilidad.
/// 
/// Incluye un icono de ojo para mostrar/ocultar la contraseña.
/// 
/// Ejemplo de uso:
/// ```dart
/// PasswordField(
///   label: 'Contraseña',
///   controller: _passwordController,
///   validator: Validators.password,
/// )
/// ```
class PasswordField extends StatefulWidget {
  /// Etiqueta del campo
  final String label;
  
  /// Controlador del campo
  final TextEditingController? controller;
  
  /// Función de validación
  final String? Function(String?)? validator;
  
  /// Texto de placeholder
  final String? hint;
  
  /// Si el campo está habilitado
  final bool enabled;
  
  /// Callback cuando el texto cambia
  final void Function(String)? onChanged;
  
  /// Callback cuando se envía el formulario
  final void Function(String)? onFieldSubmitted;
  
  /// Acción del teclado
  final TextInputAction? textInputAction;
  
  /// Focus node para control de foco
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.hint,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondarySteelBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.visiblePassword,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textBlack,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? '••••••••',
            hintStyle: const TextStyle(
              color: AppTheme.gray1,
              fontSize: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.gray2,
                size: 22,
              ),
              onPressed: _toggleVisibility,
              splashRadius: 20,
            ),
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.gray1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.gray1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.secondarySteelBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gray1.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

