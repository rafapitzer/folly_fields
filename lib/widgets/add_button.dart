import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  ///
  ///
  ///
  const AddButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
    Key? key,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
        ),
        icon: const FaIcon(
          FontAwesomeIcons.plus,
        ),
        label: Text(
          label.toUpperCase(),
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
