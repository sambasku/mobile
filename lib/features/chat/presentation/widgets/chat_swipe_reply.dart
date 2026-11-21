import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Geser horizontal (kanan) untuk memicu reply - pola ringan ala WhatsApp.
class ChatSwipeReply extends StatefulWidget {
  const ChatSwipeReply({
    super.key,
    required this.enabled,
    required this.onReply,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onReply;
  final Widget child;

  @override
  State<ChatSwipeReply> createState() => _ChatSwipeReplyState();
}

class _ChatSwipeReplyState extends State<ChatSwipeReply>
    with SingleTickerProviderStateMixin {
  static const _triggerDrag = 56.0;
  static const _maxDrag = 72.0;

  late final AnimationController _snapBackCtrl;
  Animation<double>? _snapBackAnim;

  double _drag = 0;
  var _replyLocked = false;

  @override
  void initState() {
    super.initState();
    _snapBackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(_onSnapTick);
  }

  @override
  void dispose() {
    _snapBackCtrl.dispose();
    super.dispose();
  }

  void _onSnapTick() {
    final anim = _snapBackAnim;
    if (anim == null || !mounted) return;
    setState(() => _drag = anim.value);
  }

  void _snapBack({double? from}) {
    final start = from ?? _drag;
    if (start <= 0) {
      if (_drag != 0) setState(() => _drag = 0);
      return;
    }
    _snapBackCtrl.stop();
    _snapBackAnim = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: _snapBackCtrl, curve: Curves.easeOut),
    );
    _snapBackCtrl.forward(from: 0);
  }

  void _finishGesture() {
    _replyLocked = false;
    _snapBack();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _replyLocked) return;
    _snapBackCtrl.stop();
    _snapBackAnim = null;
    final delta = details.delta.dx;
    if (_drag <= 0 && delta < 0) return;
    setState(() {
      _drag = (_drag + delta).clamp(0.0, _maxDrag);
    });
    if (_drag >= _triggerDrag) {
      _replyLocked = true;
      widget.onReply();
      _snapBack(from: _drag);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    _finishGesture();
  }

  void _onDragCancel() {
    if (!widget.enabled) return;
    _finishGesture();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final showIcon = widget.enabled && _drag > 8;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showIcon)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                label: l10n.chatSwipeReplyHint,
                child: Icon(
                  FLucideIcons.reply,
                  size: 16,
                  color: theme.colors.primary.withValues(
                    alpha: (_drag / _maxDrag).clamp(0.35, 1.0),
                  ),
                ),
              ),
            ),
          ),
        Transform.translate(
          offset: Offset(_drag, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: _onDragCancel,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}