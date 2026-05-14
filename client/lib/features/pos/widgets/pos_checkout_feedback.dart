import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Enter / exit animation for POS modal routes (fade + light scale).
/// Exit is slightly longer so fade + scale can ease out without feeling rushed.
const Duration posModalTransitionDuration = Duration(milliseconds: 420);

Widget posModalTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Enter: easeOutCubic. Exit (reverse): easeInOutCubic — avoids a harsh snap
  // at the end of dismiss compared to easeInCubic alone.
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInOutCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
      child: child,
    ),
  );
}

/// Loading → success in one route so the scrim stays put and content cross-fades.
Future<void> showPOSCheckoutFeedback(
  BuildContext context, {
  required Future<void> Function() run,
  required bool isPayLater,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: posModalTransitionDuration,
    transitionBuilder: posModalTransitionBuilder,
    pageBuilder: (ctx, _, _) {
      return Center(
        child: _CheckoutFeedbackFlow(
          run: run,
          isPayLater: isPayLater,
        ),
      );
    },
  );
}

class _CheckoutFeedbackFlow extends StatefulWidget {
  final Future<void> Function() run;
  final bool isPayLater;

  const _CheckoutFeedbackFlow({
    required this.run,
    required this.isPayLater,
  });

  @override
  State<_CheckoutFeedbackFlow> createState() => _CheckoutFeedbackFlowState();
}

class _CheckoutFeedbackFlowState extends State<_CheckoutFeedbackFlow> {
  var _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSale());
  }

  Future<void> _runSale() async {
    try {
      await widget.run();
    } catch (e, st) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      debugPrint('POS checkout error: $e\n$st');
      if (mounted) Navigator.of(context).pop();
      final msg = e is Exception ? e.toString() : 'Checkout failed.';
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            msg.length > 160 ? '${msg.substring(0, 160)}…' : msg,
          ),
        ),
      );
      return;
    }
    if (mounted) setState(() => _loading = false);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.of(context).pop();
  }

  static const _switchDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.richGold, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, minWidth: 280),
        child: AnimatedSwitcher(
          duration: _switchDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          child: _loading
              ? KeyedSubtree(
                  key: const ValueKey('checkout-loading'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: _LoadingBody(),
                  ),
                )
              : KeyedSubtree(
                  key: ValueKey('checkout-success-${widget.isPayLater}'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                    child: _SuccessBody(isPayLater: widget.isPayLater),
                  ),
                ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            color: AppColors.richGold,
            strokeWidth: 3,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Processing checkout',
          textAlign: TextAlign.center,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.deepBlack,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Updating inventory and saving this sale. Please wait…',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  final bool isPayLater;

  const _SuccessBody({required this.isPayLater});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.richGold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPayLater
                ? Icons.receipt_long_outlined
                : Icons.check_circle_outline,
            color: AppColors.richGold,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isPayLater ? 'Pay-Later recorded!' : 'Payment successful!',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.deepBlack,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isPayLater
              ? 'Sale saved as collectible (utang).'
              : 'Receipt is being printed...',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
