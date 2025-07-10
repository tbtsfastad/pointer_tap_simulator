import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PointerTapSimulator extends StatefulWidget {
  const PointerTapSimulator({
    super.key,
    required this.child,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.behavior,
  });

  final Widget child;
  final PointerDownEventListener? onPointerDown;
  final PointerMoveEventListener? onPointerMove;
  final PointerUpEventListener? onPointerUp;
  final HitTestBehavior? behavior;

  @override
  State<PointerTapSimulator> createState() => _PointerTapSimulatorState();
}

class _PointerTapSimulatorState extends State<PointerTapSimulator> {
  bool _is = false;
  Offset? _lastPosition;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: _is,
    child: Listener(
      behavior: widget.behavior ?? HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        widget.onPointerDown?.call(event);
        _lastPosition = event.position;
      },
      onPointerMove: (event) {
        _lastPosition = null;
        widget.onPointerMove?.call(event);
      },
      onPointerUp: (event) {
        widget.onPointerUp?.call(event);
        if (_lastPosition != null && !_is) {
          _simulate(_lastPosition!);
        }
      },
      onPointerCancel: (event) {
        _lastPosition = null;
      },
      child: widget.child,
    ),
  );

  void _simulate(Offset offset) async {
    setState(() {
      _is = true;
    });
    final position = Offset(offset.dx, offset.dy);
    await Future.delayed(const Duration(milliseconds: 300));
    final add = PointerAddedEvent(pointer: 0, position: position);
    final down = PointerDownEvent(pointer: 0, position: position);
    final up = PointerUpEvent(pointer: 0, position: position);
    GestureBinding.instance.handlePointerEvent(add);
    GestureBinding.instance.handlePointerEvent(down);
    GestureBinding.instance.handlePointerEvent(up);
    if (!mounted) return;
    setState(() {
      _is = false;
    });
  }
}
