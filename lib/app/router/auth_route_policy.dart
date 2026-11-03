abstract final class AuthRoutePolicy {
  static const protectedPrefixes = <String>['/ai-chat', '/wallet', '/profile'];

  static bool requiresAuthentication(String location) => protectedPrefixes.any(
    (prefix) => location == prefix || location.startsWith('$prefix/'),
  );

  static String? safeRedirect(String? value) {
    if (value == null || value.isEmpty || !value.startsWith('/')) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.host.isNotEmpty) return null;
    if (uri.path == '/login' ||
        uri.path == '/register' ||
        uri.path == '/welcome' ||
        uri.path == '/auth-gate') {
      return null;
    }
    return uri.toString();
  }

  static String loginLocation(String destination) =>
      '/login?redirect=${Uri.encodeQueryComponent(destination)}';
}
