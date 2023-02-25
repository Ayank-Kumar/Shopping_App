import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final int value;

  const Badge({Key? key,
    required this.child,
    required this.value,
  }) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: value <= 0 ? null : Theme.of(context).colorScheme.tertiary,
            ),
            constraints: const BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
          ),
        )
      ],
    );
  }
}
