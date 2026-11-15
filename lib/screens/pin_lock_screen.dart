import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_template.dart';
import '../widgets/smooth_widgets.dart';

class PinLockScreen extends StatefulWidget {
  final String pinBenar;
  final AppTemplate template;
  final VoidCallback onBerhasil;

  const PinLockScreen({
    super.key,
    required this.pinBenar,
    required this.template,
    required this.onBerhasil,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _input = '';
  bool _salah = false;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: const SineCurve(count: 3)),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _tekanAngka(String angka) {
    if (_input.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _salah = false;
      _input += angka;
    });
    if (_input.length == 4) {
      if (_input == widget.pinBenar) {
        HapticFeedback.mediumImpact();
        widget.onBerhasil();
      } else {
        HapticFeedback.heavyImpact();
        _shakeCtrl.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 280), () {
          if (mounted) {
            setState(() {
              _input = '';
              _salah = true;
            });
          }
        });
      }
    }
  }

  void _hapusAngka() {
    if (_input.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _salah = false;
      _input = _input.substring(0, _input.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: t.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Masukkan PIN DompetKu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  _salah
                      ? 'PIN salah, silakan coba lagi'
                      : 'Masukkan 4 digit PIN keamanan kamu',
                  key: ValueKey(_salah),
                  style: TextStyle(
                    fontSize: 13,
                    color: _salah ? const Color(0xFFF43F5E) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final terisi = i < _input.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: terisi ? 18 : 15,
                      height: terisi ? 18 : 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: terisi
                            ? (_salah
                                ? const Color(0xFFF43F5E)
                                : t.primaryColor)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                    (n) => _TombolKeypad(
                      label: n,
                      cardColor: t.cardColor,
                      borderColor: t.borderColor,
                      radius: t.cardRadius,
                      onTap: () => _tekanAngka(n),
                    ),
                  ),
                  const SizedBox.shrink(),
                  _TombolKeypad(
                    label: '0',
                    cardColor: t.cardColor,
                    borderColor: t.borderColor,
                    radius: t.cardRadius,
                    onTap: () => _tekanAngka('0'),
                  ),
                  SmoothTap(
                    scaleDown: 0.92,
                    enableHaptic: false,
                    onTap: _hapusAngka,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.cardColor,
                        borderRadius: BorderRadius.circular(t.cardRadius),
                        border: Border.all(color: t.borderColor),
                      ),
                      child: const Icon(Icons.backspace_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TombolKeypad extends StatelessWidget {
  final String label;
  final Color cardColor;
  final Color borderColor;
  final double radius;
  final VoidCallback onTap;

  const _TombolKeypad({
    required this.label,
    required this.cardColor,
    required this.borderColor,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothTap(
      scaleDown: 0.92,
      enableHaptic: false,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
