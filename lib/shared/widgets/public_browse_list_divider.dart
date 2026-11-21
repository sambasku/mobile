import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Garis tipis antar baris list browse publik (ensiklopedia, layanan).
class PublicBrowseListDivider extends StatelessWidget {
  const PublicBrowseListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return FDivider(
      style: FDividerStyleDelta.delta(
        padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      ),
    );
  }
}