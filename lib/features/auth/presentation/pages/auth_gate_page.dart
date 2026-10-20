import 'package:flutter/material.dart';
import '../../../../core/widgets/mystic_loading.dart';
import '../../../../core/widgets/mystic_scaffold.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});
  @override
  Widget build(BuildContext context) => const MysticScaffold(
    body: MysticLoading(label: 'Đang kiểm tra phiên đăng nhập...'),
  );
}
