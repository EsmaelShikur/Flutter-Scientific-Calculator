// lib/core/constants/calculator_constants.dart
import 'dart:math' as math;

class MathConstants {
  static const double pi = math.pi;
  static const double e = math.e;
  static const double phi = 1.6180339887498948482; // Golden ratio
  static const double sqrt2 = math.sqrt2;
  static const double ln2 = math.ln2;
  static const double ln10 = math.ln10;
  static const double log2e = math.log2e;
  static const double log10e = math.log10e;

  static const Map<String, Map<String, dynamic>> scientificConstants = {
    'π (Pi)': {'value': math.pi, 'symbol': 'π', 'description': 'Ratio of circumference to diameter'},
    'e (Euler)': {'value': math.e, 'symbol': 'e', 'description': "Euler's number"},
    'φ (Phi)': {'value': 1.6180339887498948482, 'symbol': 'φ', 'description': 'Golden ratio'},
    '√2': {'value': math.sqrt2, 'symbol': '√2', 'description': 'Square root of 2'},
    'c (Speed of Light)': {'value': 299792458.0, 'symbol': 'c', 'description': 'Speed of light (m/s)'},
    'g (Gravity)': {'value': 9.80665, 'symbol': 'g', 'description': 'Standard gravity (m/s²)'},
    'h (Planck)': {'value': 6.62607015e-34, 'symbol': 'h', 'description': "Planck's constant (J·s)"},
    'N_A (Avogadro)': {'value': 6.02214076e23, 'symbol': 'Nₐ', 'description': "Avogadro's number (mol⁻¹)"},
  };
}

class ButtonConfig {
  final String label;
  final String? sublabel;
  final ButtonType type;
  final String action;
  final int flex;

  const ButtonConfig({
    required this.label,
    this.sublabel,
    required this.type,
    required this.action,
    this.flex = 1,
  });
}

enum ButtonType {
  number,
  operator,
  scientific,
  equals,
  clear,
  clearEntry,
  memory,
  toggle,
  special,
}
