import 'package:flutter/material.dart';

/// Reusable animated page-indicator (dots / pill).
/// Colour matches the Login button brand colour [kBrandBlue].
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  /// Brand colour shared with [PrimaryButton].
  static const Color kBrandBlue = Color(0xFF6ACFEF);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (i) => _Dot(active: i == currentPage)),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 36 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? PageIndicator.kBrandBlue
            : PageIndicator.kBrandBlue.withOpacity(0.30),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
