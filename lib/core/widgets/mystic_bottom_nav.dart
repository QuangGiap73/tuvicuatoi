import 'package:flutter/material.dart';

class MysticNavItem {
  const MysticNavItem(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class MysticBottomNav extends StatelessWidget {
  const MysticBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<MysticNavItem> items;
  final ValueChanged<int> onTap;

  static const Color _background = Color(0xFF080F1D);
  static const Color _active = Color(0xFFFFD46F);
  static const Color _inactive = Color(0xFFAAA89E);
  static const Color _border = Color(0xFF8D6B2B);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(7, 4, 7, bottomInset + 6),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF101925), _background, Color(0xFF050A12)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
              BoxShadow(color: Color(0x228D6B2B), blurRadius: 8),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 3,
                left: 18,
                right: 18,
                child: Container(
                  height: .6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFB58B39),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = currentIndex == index;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: item.label,
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 6, 2, 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                width: 30,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: selected
                                      ? const RadialGradient(
                                          colors: [
                                            Color(0x558E6816),
                                            Color(0x008E6816),
                                          ],
                                        )
                                      : null,
                                ),
                                child: Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 20,
                                  color: selected ? _active : _inactive,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: selected ? _active : _inactive,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
