import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PrimaryRaisedButton extends StatelessWidget {
  const PrimaryRaisedButton({this.onPressed, required this.label, Key? key})
      : super(key: key);

  final Widget label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onPressed,
        label: label,
        icon: const Icon(Icons.add),
      );
}
