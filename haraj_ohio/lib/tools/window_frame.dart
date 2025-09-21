// window_frame.dart

import 'package:flutter/material.dart';
import 'package:haraj/tools/Palette/gradients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class CustomWindowFrame extends StatefulWidget {
  final Widget child;

  const CustomWindowFrame({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<CustomWindowFrame> createState() => _CustomWindowFrameState();
}

class _CustomWindowFrameState extends State<CustomWindowFrame>
    with WindowListener {
  // SharedPreferences
  late SharedPreferences _prefs;
  // Maximize
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadMaximizedState();
    _checkMaximizedState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _loadMaximizedState() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isMaximized = _prefs.getBool('isMaximized') ?? false;
      });
    }
  }

  Future<void> _saveMaximizedState(bool value) async {
    await _prefs.setBool('isMaximized', value);
  }

  void _checkMaximizedState() {
    windowManager.isMaximized().then((value) {
      if (mounted && value != _isMaximized) {
        setState(() {
          _isMaximized = value;
        });
        _saveMaximizedState(value);
      }
    });
  }

  @override
  void onWindowMaximize() {
    if (mounted && !_isMaximized) {
      setState(() {
        _isMaximized = true;
      });
      _saveMaximizedState(true);
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted && _isMaximized) {
      setState(() {
        _isMaximized = false;
      });
      _saveMaximizedState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom window title bar
        _buildWindowTitleBar(),
        // Main content
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildWindowTitleBar() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.light
            ? LightGradient.main
            : DarkGradient.main,
      ),
      // Draggable area
      child: Container(
        height: 32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.35),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.rtl,
          children: [
            // Window Cntrols
            Row(
              textDirection: TextDirection.rtl,
              children: [
                _WindowControlButton(
                  icon: Icons.close,
                  isClose: true,
                  onPressed: () => windowManager.close(),
                ),
                _WindowControlButton(
                  icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
                  onPressed: () => _isMaximized
                      ? windowManager.unmaximize()
                      : windowManager.maximize(),
                ),
                _WindowControlButton(
                  icon: Icons.remove,
                  onPressed: () => windowManager.minimize(),
                ),
              ],
            ),
            // title
            Expanded(
              child: GestureDetector(
                onPanStart: (_) => windowManager.startDragging(),
                onDoubleTap: () {
                  _isMaximized
                      ? windowManager.unmaximize()
                      : windowManager.maximize();
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 3),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  child: const Text(
                    'Haraj Ohio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            // Logo
            Padding(
              padding: const EdgeInsets.all(3),
              child: Hero(
                tag: 'logo',
                child: Container(
                  padding: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo/haraj_logo.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate
class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  }) : super(key: key);

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!_isHovering) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (_) {
        if (_isHovering) {
          setState(() => _isHovering = false);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: widget.onPressed,
          child: Ink(
            width: 46,
            color: _isHovering
                ? widget.isClose
                    ? Colors.red
                    : Colors.white.withOpacity(0.2)
                : Colors.transparent,
            child: Center(
              child: Icon(
                widget.icon,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
