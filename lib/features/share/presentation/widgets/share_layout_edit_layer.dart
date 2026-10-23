import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../domain/share_models.dart';
import 'share_layout_snap.dart';

typedef ShareCardHitKeyFor = GlobalKey Function(ShareTextElementId id);

/// Lapisan gesture editor posisi.
///
/// Hit-test teks memakai kotak visual (termasuk translate/rotate), jadi ketukan
/// pada teks tidak jatuh ke gesture gambar di belakangnya. Garis putus-putus
/// muncul saat elemen terpilih berada di tengah horizontal atau vertikal.
class ShareLayoutEditLayer extends StatefulWidget {
  const ShareLayoutEditLayer({
    super.key,
    required this.width,
    required this.height,
    required this.selected,
    required this.mediaSelected,
    required this.mediaAlignment,
    required this.cardBuilder,
    this.onSelectElement,
    this.onPanElement,
    this.onSelectMedia,
    this.onPanMedia,
    this.contentFloor = 0,
  });

  final double width;
  final double height;
  final ShareTextElementId? selected;
  final bool mediaSelected;
  final Offset mediaAlignment;
  final Widget Function(ShareCardHitKeyFor hitKeyFor) cardBuilder;
  final ValueChanged<ShareTextElementId>? onSelectElement;
  final void Function(ShareTextElementId id, Offset canvasDelta)? onPanElement;
  final VoidCallback? onSelectMedia;
  final void Function(Offset canvasDelta)? onPanMedia;

  /// Pita dari tepi bawah kartu yang tidak boleh dimasuki teks (watermark).
  final double contentFloor;

  @override
  State<ShareLayoutEditLayer> createState() => _ShareLayoutEditLayerState();
}

class _ShareLayoutEditLayerState extends State<ShareLayoutEditLayer> {
  final GlobalKey _canvasKey = GlobalKey();
  late final Map<ShareTextElementId, GlobalKey> _keys = {
    for (final id in ShareTextElementId.values) id: GlobalKey(),
  };

  ShareTextElementId? _dragText;
  bool _dragMedia = false;
  bool _guideVertical = false;
  bool _guideHorizontal = false;

  bool _stickyTextX = false;
  bool _stickyTextY = false;
  double _accumTextX = 0;
  double _accumTextY = 0;
  bool _stickyMediaX = false;
  bool _stickyMediaY = false;
  double _accumMediaX = 0;
  double _accumMediaY = 0;

  GlobalKey _hitKeyFor(ShareTextElementId id) => _keys[id]!;

  @override
  Widget build(BuildContext context) {
    _scheduleGuides();
    return SizedBox(
      key: _canvasKey,
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.cardBuilder(_hitKeyFor),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ShareCenterGuidePainter(
                  showVertical: _guideVertical,
                  showHorizontal: _guideHorizontal,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => _arm(event.position),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (_) => _endDrag(),
                onPanCancel: _endDrag,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleGuides() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncGuides());
  }

  void _syncGuides() {
    if (!mounted) return;
    final vertical = _axisCentered(horizontal: true);
    final horizontal = _axisCentered(horizontal: false);
    if (vertical == _guideVertical && horizontal == _guideHorizontal) return;
    setState(() {
      _guideVertical = vertical;
      _guideHorizontal = horizontal;
    });
  }

  bool _axisCentered({required bool horizontal}) {
    if (widget.mediaSelected) {
      final value = horizontal
          ? widget.mediaAlignment.dx
          : widget.mediaAlignment.dy;
      return value.abs() < 0.001;
    }
    final id = widget.selected;
    if (id == null) return false;
    final canvas = _box(_canvasKey);
    final element = _box(_keys[id]!);
    if (canvas == null || element == null || element.size.isEmpty) {
      return false;
    }
    final center = canvas.globalToLocal(
      element.localToGlobal(element.size.center(Offset.zero)),
    );
    final target = horizontal ? canvas.size.width / 2 : canvas.size.height / 2;
    final value = horizontal ? center.dx : center.dy;
    return (value - target).abs() <= 2;
  }

  void _arm(Offset global) {
    final id = _hitText(global);
    if (id != null) {
      _dragText = id;
      _dragMedia = false;
      _resetSticky();
      widget.onSelectElement?.call(id);
      return;
    }
    _dragText = null;
    if (widget.onSelectMedia != null) {
      _dragMedia = true;
      _resetSticky();
      widget.onSelectMedia!.call();
      return;
    }
    _dragMedia = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final id = _dragText;
    if (id != null) {
      widget.onPanElement?.call(id, _adjustTextDelta(id, details.delta));
      return;
    }
    if (_dragMedia) {
      widget.onPanMedia?.call(_adjustMediaDelta(details.delta));
    }
  }

  void _endDrag() {
    _dragText = null;
    _dragMedia = false;
    _resetSticky();
  }

  void _resetSticky() {
    _stickyTextX = false;
    _stickyTextY = false;
    _accumTextX = 0;
    _accumTextY = 0;
    _stickyMediaX = false;
    _stickyMediaY = false;
    _accumMediaX = 0;
    _accumMediaY = 0;
  }

  Offset _adjustTextDelta(ShareTextElementId id, Offset delta) {
    final canvas = _box(_canvasKey);
    final element = _box(_keys[id]!);
    if (canvas == null || element == null) return delta;
    final center = canvas.globalToLocal(
      element.localToGlobal(element.size.center(Offset.zero)),
    );
    final target = Offset(canvas.size.width / 2, canvas.size.height / 2);
    final threshold = _snapThreshold(canvas.size);
    final x = snapAxis(
      center: center.dx,
      target: target.dx,
      delta: delta.dx,
      threshold: threshold,
      stuck: _stickyTextX,
      accum: _accumTextX,
    );
    final y = snapAxis(
      center: center.dy,
      target: target.dy,
      delta: delta.dy,
      threshold: threshold,
      stuck: _stickyTextY,
      accum: _accumTextY,
    );
    _stickyTextX = x.stuck;
    _accumTextX = x.accum;
    _stickyTextY = y.stuck;
    _accumTextY = y.accum;
    return _keepAboveFloor(Offset(x.delta, y.delta), canvas, element);
  }

  Offset _keepAboveFloor(Offset delta, RenderBox canvas, RenderBox element) {
    if (widget.contentFloor <= 0) return delta;
    final bottom = _visualBottom(canvas, element);
    final limit = canvas.size.height - widget.contentFloor;
    final room = limit - bottom;
    if (delta.dy <= room) return delta;
    return Offset(delta.dx, room);
  }

  double _visualBottom(RenderBox canvas, RenderBox element) {
    final size = element.size;
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxY = double.negativeInfinity;
    for (final corner in corners) {
      final y = canvas.globalToLocal(element.localToGlobal(corner)).dy;
      if (y > maxY) maxY = y;
    }
    return maxY;
  }

  Offset _adjustMediaDelta(Offset delta) {
    final halfW = widget.width / 2;
    final halfH = widget.height / 2;
    if (halfW == 0 || halfH == 0) return delta;
    final align = widget.mediaAlignment;
    final threshold = _snapThreshold(Size(widget.width, widget.height));
    final rawNx = (align.dx - delta.dx / halfW).clamp(-1.0, 1.0);
    final rawNy = (align.dy - delta.dy / halfH).clamp(-1.0, 1.0);
    final x = snapAxis(
      center: align.dx,
      target: 0,
      delta: rawNx - align.dx,
      threshold: threshold / halfW,
      stuck: _stickyMediaX,
      accum: _accumMediaX,
    );
    final y = snapAxis(
      center: align.dy,
      target: 0,
      delta: rawNy - align.dy,
      threshold: threshold / halfH,
      stuck: _stickyMediaY,
      accum: _accumMediaY,
    );
    _stickyMediaX = x.stuck;
    _accumMediaX = x.accum;
    _stickyMediaY = y.stuck;
    _accumMediaY = y.accum;
    return Offset(-x.delta * halfW, -y.delta * halfH);
  }

  ShareTextElementId? _hitText(Offset global) {
    final canvas = _box(_canvasKey);
    final slop = canvas == null ? 32.0 : _snapThreshold(canvas.size);
    ShareTextElementId? exact;
    var exactArea = double.infinity;
    ShareTextElementId? near;
    var nearArea = double.infinity;
    for (final id in ShareTextElementId.values) {
      final box = _box(_keys[id]!);
      if (box == null || box.size.isEmpty) continue;
      final local = box.globalToLocal(global);
      final area = box.size.width * box.size.height;
      if (_contains(local, box.size, 0) && area < exactArea) {
        exact = id;
        exactArea = area;
        continue;
      }
      if (_contains(local, box.size, slop) && area < nearArea) {
        near = id;
        nearArea = area;
      }
    }
    return exact ?? near;
  }

  bool _contains(Offset local, Size size, double slop) {
    return local.dx >= -slop &&
        local.dy >= -slop &&
        local.dx <= size.width + slop &&
        local.dy <= size.height + slop;
  }

  double _snapThreshold(Size size) => math.max(size.shortestSide * 0.03, 24);

  RenderBox? _box(GlobalKey key) {
    final object = key.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.attached || !object.hasSize) {
      return null;
    }
    return object;
  }
}

class ShareCenterGuidePainter extends CustomPainter {
  const ShareCenterGuidePainter({
    required this.showVertical,
    required this.showHorizontal,
  });

  final bool showVertical;
  final bool showHorizontal;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showVertical && !showHorizontal) return;
    // Kanvas 1080px lalu di-scale ke layar, jadi stroke harus kecil
    // supaya di preview tetap setipis garis bantu (~1px).
    final stroke = math.max(size.shortestSide * 0.0028, 2.5);
    final dash = math.max(size.shortestSide * 0.022, 16.0);
    final gap = dash * 0.7;
    final shadow = Paint()
      ..color = const Color(0x99000000)
      ..strokeWidth = stroke + 1.5
      ..strokeCap = StrokeCap.butt;
    final line = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    final midX = size.width / 2;
    final midY = size.height / 2;
    if (showVertical) {
      _dash(
        canvas,
        Offset(midX, 0),
        Offset(midX, size.height),
        shadow,
        dash,
        gap,
      );
      _dash(
        canvas,
        Offset(midX, 0),
        Offset(midX, size.height),
        line,
        dash,
        gap,
      );
    }
    if (showHorizontal) {
      _dash(
        canvas,
        Offset(0, midY),
        Offset(size.width, midY),
        shadow,
        dash,
        gap,
      );
      _dash(canvas, Offset(0, midY), Offset(size.width, midY), line, dash, gap);
    }
  }

  void _dash(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint,
    double dash,
    double gap,
  ) {
    final delta = b - a;
    final length = delta.distance;
    if (length == 0) return;
    final dir = delta / length;
    var t = 0.0;
    while (t < length) {
      final end = math.min(t + dash, length);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant ShareCenterGuidePainter oldDelegate) {
    return oldDelegate.showVertical != showVertical ||
        oldDelegate.showHorizontal != showHorizontal;
  }
}
