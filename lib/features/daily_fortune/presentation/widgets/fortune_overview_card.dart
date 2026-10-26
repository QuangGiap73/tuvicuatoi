import 'package:flutter/material.dart';
import '../../domain/daily_fortune.dart';

class FortuneOverviewCard extends StatelessWidget {
  const FortuneOverviewCard({
    required this.fortune,
    required this.loading,
    this.errorMessage,
    super.key,
  });
  final DailyFortune fortune;
  final bool loading;
  final String? errorMessage;
  @override
  Widget build(BuildContext context) {
    final score = (fortune.fortuneScore * 20).round();
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xE9071A29),
        border: Border.all(color: const Color(0xFFD5A443)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '✦  TỔNG QUAN VẬN HẠN HÔM NAY',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    color: Color(0xFFFFD77C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD77C),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0x33FF8A65),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x88FF8A65)),
              ),
              child: Text(
                'Nhật vận chưa tải được. Đang hiển thị luận giải tổng quan từ lá số.',
                style: const TextStyle(color: Color(0xFFFFC1A8), fontSize: 10),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Cung lâm hạn',
                  value: fortune.dailyPalace ?? 'Chưa chọn lá số',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(label: 'Điểm vận thế ngày', value: '$score/100'),
              ),
            ],
          ),
          if (fortune.summary.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              fortune.summary,
              style: const TextStyle(
                color: Color(0xFFE9DBBC),
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _Area(icon: Icons.work, title: 'Công việc', text: fortune.career),
              _Area(
                icon: Icons.monetization_on,
                title: 'Tài lộc',
                text: fortune.wealth,
              ),
              _Area(
                icon: Icons.favorite,
                title: 'Tình cảm',
                text: fortune.love,
              ),
              _Area(icon: Icons.eco, title: 'Sức khỏe', text: fortune.health),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF0B2639),
      border: Border.all(color: const Color(0xFF8B6A2C)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFCAB98F), fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFD77C),
            fontFamily: 'serif',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _Area extends StatelessWidget {
  const _Area({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String? text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: const Color(0xFF10283A),
      border: Border.all(color: const Color(0xFF785D2B)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFFFFD77C)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFD77C),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Text(
            text ?? 'Đang cập nhật luận giải',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD8CCB4),
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}
