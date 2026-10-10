import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeToConfirm extends StatefulWidget {
  final String text;
  final VoidCallback onConfirm;
  final Color activeColor;

  const SwipeToConfirm({
    super.key,
    required this.text,
    required this.onConfirm,
    this.activeColor = Colors.redAccent,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _confirmed = false;
  final double _height = 60.0;
  final double _knobSize = 52.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - _knobSize - 8;
        
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn,
            width: _confirmed ? _height : constraints.maxWidth,
            height: _height,
            decoration: BoxDecoration(
              color: _confirmed ? Colors.green.shade500 : widget.activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_height / 2),
              border: Border.all(
                color: _confirmed ? Colors.green.shade500 : widget.activeColor.withOpacity(0.3),
              ),
              boxShadow: _confirmed
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Text (Fades out on confirm)
                AnimatedOpacity(
                  opacity: _confirmed ? 0 : 1.0 - (_dragPosition / maxDrag),
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.activeColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                // Success Checkmark (Pops in on confirm)
                AnimatedScale(
                  scale: _confirmed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                // Draggable Knob (Fades out on confirm)
                if (!_confirmed)
                  AnimatedPositioned(
                    duration: _dragPosition == 0 ? const Duration(milliseconds: 300) : Duration.zero,
                    left: _dragPosition + 4,
                    curve: Curves.easeOutBack,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (_confirmed) return;
                        setState(() {
                          _dragPosition += details.delta.dx;
                          if (_dragPosition < 0) _dragPosition = 0;
                          if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        if (_confirmed) return;
                        if (_dragPosition > maxDrag * 0.8) {
                          // Confirmed!
                          HapticFeedback.heavyImpact(); // Apple Pay style heavy click
                          setState(() {
                            _dragPosition = maxDrag;
                            _confirmed = true;
                          });
                          widget.onConfirm();
                        } else {
                          // Snap back
                          HapticFeedback.lightImpact();
                          setState(() {
                            _dragPosition = 0;
                          });
                        }
                      },
                      child: Container(
                        width: _knobSize,
                        height: _knobSize,
                        decoration: BoxDecoration(
                          color: widget.activeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
