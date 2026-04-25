import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ad_provider.dart';

class AdBannerWidget extends ConsumerWidget {
  final bool isTop;

  const AdBannerWidget({
    super.key,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(adProvider);

    if (isTop) {
      if (adState.topBanner == null || adState.topBannerState != AdLoadState.loaded) {
        return const SizedBox(height: 50);
      }
      return SizedBox(
        height: 50,
        child: AdWidget(ad: adState.topBanner!),
      );
    } else {
      if (adState.bottomBanner == null || adState.bottomBannerState != AdLoadState.loaded) {
        return const SizedBox(height: 50);
      }
      return SizedBox(
        height: 50,
        child: AdWidget(ad: adState.bottomBanner!),
      );
    }
  }
}