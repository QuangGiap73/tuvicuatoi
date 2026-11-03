import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';
import '../../domain/fortune_hour.dart';

class AuspiciousHoursCard extends StatefulWidget {
  const AuspiciousHoursCard({required this.fortune, super.key});

  final DailyFortune fortune;

  @override
  State<AuspiciousHoursCard> createState() => _AuspiciousHoursCardState();
}

class _AuspiciousHoursCardState extends State<AuspiciousHoursCard> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final allHours = widget.fortune.calendar.hours;
    final auspiciousHours = allHours
        .where((hour) => hour.isAuspicious)
        .toList(growable: false);
    final hours = _showAll ? allHours : auspiciousHours;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 12, 11, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2638), Color(0xFF071B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFC99839), width: 1.2),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SunEmblem(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showAll ? '12 KHUNG GIỜ TRONG NGÀY' : 'GIỜ HOÀNG ĐẠO',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Color(0xFFFFD77C),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _showAll
                          ? 'Hoàng Đạo và Hắc Đạo theo từng khung giờ'
                          : '${auspiciousHours.length} khung giờ cát lành trong ngày',
                      style: const TextStyle(
                        color: Color(0xFFBCA980),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          if (hours.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Chưa có dữ liệu giờ Hoàng Đạo.',
                style: TextStyle(color: Color(0xFFCAB98F), fontSize: 10.5),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  key: ValueKey(_showAll),
                  spacing: gap,
                  runSpacing: 8,
                  children: hours
                      .map(
                        (hour) => SizedBox(
                          width: itemWidth,
                          child: _HourTile(hour: hour),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          if (allHours.length > auspiciousHours.length) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showAll = !_showAll),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD77C),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF80652F)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: Icon(
                  _showAll
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.schedule_rounded,
                  size: 17,
                ),
                label: Text(
                  _showAll ? 'Thu gọn giờ Hoàng Đạo' : 'Xem đủ 12 khung giờ',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SunEmblem extends StatelessWidget {
  const _SunEmblem();

  @override
  Widget build(BuildContext context) => Container(
    width: 37,
    height: 37,
    decoration: BoxDecoration(
      gradient: const RadialGradient(
        colors: [Color(0xFFFFE89B), Color(0xFFE4A52E)],
      ),
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFFFD978)),
    ),
    child: const Icon(
      Icons.wb_sunny_rounded,
      color: Color(0xFF754510),
      size: 21,
    ),
  );
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.hour});

  final FortuneHour hour;

  @override
  Widget build(BuildContext context) {
    final good = hour.isAuspicious;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: good
              ? const [Color(0xFF173449), Color(0xFF0C2436)]
              : const [Color(0xFF172431), Color(0xFF101A24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: good ? const Color(0xFFC99737) : const Color(0xFF536474),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF102A3D),
              shape: BoxShape.circle,
              border: Border.all(
                color: good ? const Color(0xFFD4A13D) : const Color(0xFF71808D),
              ),
            ),
            child: Text(
              hour.branch,
              style: const TextStyle(
                fontFamily: 'serif',
                color: Color(0xFFFFD77C),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE5AD),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: good
                        ? const Color(0x553C802B)
                        : const Color(0x55465767),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: good
                          ? const Color(0xFF759D55)
                          : const Color(0xFF647382),
                      width: .7,
                    ),
                  ),
                  child: Text(
                    hour.starName.isEmpty
                        ? (good ? 'Hoàng Đạo' : 'Hắc Đạo')
                        : hour.starName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: good
                          ? const Color(0xFFC9DDAE)
                          : const Color(0xFFB8C2CB),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
