import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../flavors.dart';
import 'dev_tool_inspector.dart';
import 'dev_tool_page.dart';

/// Apakah perkakas dev boleh muncul / berpengaruh.
///
/// Debug build (semua flavor): hidup. Profile/release: mati — build
/// profile di-sign release dan bisa dipasang siapa saja, jadi gate-nya
/// mode, bukan flavor (#68). Dipakai overlay ini DAN bootstrap di
/// `main.dart`, supaya override paksa-tier yang tersimpan tidak pernah
/// aktif di build milik pengguna.
@visibleForTesting
bool devToolsEnabledFor({required bool debug, required bool hideDevChrome}) =>
    !hideDevChrome && debug;

bool get devToolsEnabled =>
    devToolsEnabledFor(debug: kDebugMode, hideDevChrome: F.hideDevChrome);

class DevToolOverlay extends StatefulWidget {
  const DevToolOverlay({
    super.key,
    required this.inspectors,
    required this.child,
  });

  final List<DevToolInspector> inspectors;
  final Widget child;

  @override
  State<DevToolOverlay> createState() => _DevToolOverlayState();
}

class _DevToolOverlayState extends State<DevToolOverlay> {
  Offset _offset = Offset.zero;
  bool _initialized = false;
  bool _isDragging = false;
  bool _isDevToolPageOpen = false;
  double _dragDistance = 0;

  static const _size = 48.0;
  // di bawah ini = tap; di atas = drag (jangan buka page)
  static const _tapSlop = 8.0;

  static const _prefKeyX = 'devToolPositionX';
  static const _prefKeyY = 'devToolPositionY';

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_prefKeyX);
    final y = prefs.getDouble(_prefKeyY);
    if (x != null && y != null && mounted) {
      setState(() {
        _offset = Offset(x, y);
        _initialized = true;
      });
    }
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefKeyX, _offset.dx);
    await prefs.setDouble(_prefKeyY, _offset.dy);
  }

  void _openDevToolPage() {
    final nav = AppRouter.rootNavigatorKey.currentState;
    if (nav == null) return;

    setState(() => _isDevToolPageOpen = true);

    nav
        .push(
          MaterialPageRoute(
            builder: (_) => DevToolPage(
              inspectors: widget.inspectors,
              onClose: () => nav.pop(),
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() => _isDevToolPageOpen = false);
        });
  }

  @override
  Widget build(BuildContext context) {
    if (!devToolsEnabled) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialized) {
          _offset = Offset(
            constraints.maxWidth - _size - 16,
            constraints.maxHeight - _size - 100,
          );
          _initialized = true;
        }

        final clamped = Offset(
          _offset.dx.clamp(0, constraints.maxWidth - _size),
          _offset.dy.clamp(0, constraints.maxHeight - _size),
        );

        return Stack(
          children: [
            widget.child,
            if (!_isDevToolPageOpen)
              Positioned(
                left: clamped.dx,
                top: clamped.dy,
                child: GestureDetector(
                  onPanStart: (_) {
                    _dragDistance = 0;
                    setState(() => _isDragging = true);
                  },
                  onPanUpdate: (details) {
                    _dragDistance += details.delta.distance;
                    setState(() {
                      _offset = Offset(
                        (_offset.dx + details.delta.dx).clamp(
                          0,
                          constraints.maxWidth - _size,
                        ),
                        (_offset.dy + details.delta.dy).clamp(
                          0,
                          constraints.maxHeight - _size,
                        ),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    setState(() => _isDragging = false);
                    _savePosition();
                    // hanya buka kalau gerakan kecil (tap), bukan setelah drag
                    if (_dragDistance < _tapSlop) {
                      _openDevToolPage();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _size,
                    height: _size,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53E3E).withValues(alpha: 0.4),
                          blurRadius: _isDragging ? 16 : 8,
                          spreadRadius: _isDragging ? 2 : 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      FLucideIcons.bugPlay,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
