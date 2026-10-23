import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

/// Satu palet warna forui: label + varian light/dark (dipilih app sesuai brightness).
typedef ForuiPalette = ({
  String label,
  FPlatformThemeData light,
  FPlatformThemeData dark,
});

// FThemes dihapus di forui 0.24; nilai warna shadcn/ui dipindah sini
// (asal: FColors 0.22.3, supaya tampilan user tidak berubah).
FColors _c(
  Color background,
  Color foreground,
  Color primary,
  Color primaryForeground,
  Color secondary,
  Color secondaryForeground,
  Color muted,
  Color mutedForeground,
  Color card,
  Color border, {
  required bool dark,
}) => FColors(
  brightness: dark ? Brightness.dark : Brightness.light,
  systemOverlayStyle: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
  barrier: dark ? const Color(0x7A000000) : const Color(0x33000000),
  background: background,
  foreground: foreground,
  primary: primary,
  primaryForeground: primaryForeground,
  secondary: secondary,
  secondaryForeground: secondaryForeground,
  muted: muted,
  mutedForeground: mutedForeground,
  destructive: dark ? const Color(0xFFFF6467) : const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: dark ? const Color(0xFFFF6467) : const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: card,
  border: border,
);

FPlatformThemeData _p({required FColors c}) => FPlatformThemeData(
  desktop: () => FThemeData(colors: c, touch: false),
  touch: () => FThemeData(colors: c, touch: true),
);

/// Katalog palet warna (nilai shadcn/ui, sama dengan FThemes 0.22).
final Map<String, ForuiPalette> foruiPalettes = {
  'neutral': (
    label: 'Netral',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF0A0A0A), const Color(0xFF171717), const Color(0xFFFAFAFA), const Color(0xFFF5F5F5), const Color(0xFF171717), const Color(0xFFF5F5F5), const Color(0xFF737373), const Color(0xFFFFFFFF), const Color(0xFFE5E5E5), dark: false)),
    dark: _p(c: _c(const Color(0xFF0A0A0A), const Color(0xFFFAFAFA), const Color(0xFFE5E5E5), const Color(0xFF171717), const Color(0xFF262626), const Color(0xFFFAFAFA), const Color(0xFF262626), const Color(0xFFA1A1A1), const Color(0xFF171717), const Color(0x1AFFFFFF), dark: true)),
  ),
  'zinc': (
    label: 'Zinc',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFF18181B), const Color(0xFFFAFAFA), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFFE4E4E7), const Color(0xFF18181B), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'slate': (
    label: 'Slate',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF020618), const Color(0xFF0F172B), const Color(0xFFF8FAFC), const Color(0xFFF1F5F9), const Color(0xFF0F172B), const Color(0xFFF1F5F9), const Color(0xFF62748E), const Color(0xFFFFFFFF), const Color(0xFFE2E8F0), dark: false)),
    dark: _p(c: _c(const Color(0xFF020618), const Color(0xFFF8FAFC), const Color(0xFFE2E8F0), const Color(0xFF0F172B), const Color(0xFF1D293D), const Color(0xFFF8FAFC), const Color(0xFF1D293D), const Color(0xFF90A1B9), const Color(0xFF0F172B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'blue': (
    label: 'Biru',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFF1447E6), const Color(0xFFEFF6FF), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFF1447E6), const Color(0xFFEFF6FF), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'green': (
    label: 'Hijau',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFF5EA500), const Color(0xFFF7FEE7), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFF5EA500), const Color(0xFFF7FEE7), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'orange': (
    label: 'Oranye',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFFF54A00), const Color(0xFFFFF7ED), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFFFF6900), const Color(0xFFFFF7ED), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'red': (
    label: 'Merah',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFFE7000B), const Color(0xFFFEF2F2), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFFFB2C36), const Color(0xFFFEF2F2), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'rose': (
    label: 'Rose',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFFEC003F), const Color(0xFFFFF1F2), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFFFF2056), const Color(0xFFFFF1F2), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'violet': (
    label: 'Violet',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFF7F22FE), const Color(0xFFF5F3FF), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFF8E51FF), const Color(0xFFF5F3FF), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
  'yellow': (
    label: 'Kuning',
    light: _p(c: _c(const Color(0xFFFFFFFF), const Color(0xFF09090B), const Color(0xFFFCC800), const Color(0xFF733E0A), const Color(0xFFF4F4F5), const Color(0xFF18181B), const Color(0xFFF4F4F5), const Color(0xFF71717B), const Color(0xFFFFFFFF), const Color(0xFFE4E4E7), dark: false)),
    dark: _p(c: _c(const Color(0xFF09090B), const Color(0xFFFAFAFA), const Color(0xFFEFB100), const Color(0xFF733E0A), const Color(0xFF27272A), const Color(0xFFFAFAFA), const Color(0xFF27272A), const Color(0xFF9F9FA9), const Color(0xFF18181B), const Color(0x1AFFFFFF), dark: true)),
  ),
};


const defaultPalette = 'zinc';
