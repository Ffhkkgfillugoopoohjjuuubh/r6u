import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

const String kAppId = 'ca-app-pub-4160048627212561~4567059878';
const String kTopBannerAdUnitId = 'ca-app-pub-4160048627212561/8942253301';
const String kBottomBannerAdUnitId = 'ca-app-pub-4160048627212561/3909418474';

enum AdLoadState { idle, loading, loaded, error }

class AdState {
  final AdLoadState topBannerState;
  final AdLoadState bottomBannerState;
  final BannerAd? topBanner;
  final BannerAd? bottomBanner;
  final bool shouldRefresh;
  final String? errorMessage;

  const AdState({
    this.topBannerState = AdLoadState.idle,
    this.bottomBannerState = AdLoadState.idle,
    this.topBanner,
    this.bottomBanner,
    this.shouldRefresh = false,
    this.errorMessage,
  });

  AdState copyWith({
    AdLoadState? topBannerState,
    AdLoadState? bottomBannerState,
    BannerAd? topBanner,
    BannerAd? bottomBanner,
    bool? shouldRefresh,
    String? errorMessage,
  }) {
    return AdState(
      topBannerState: topBannerState ?? this.topBannerState,
      bottomBannerState: bottomBannerState ?? this.bottomBannerState,
      topBanner: topBanner ?? this.topBanner,
      bottomBanner: bottomBanner ?? this.bottomBanner,
      shouldRefresh: shouldRefresh ?? this.shouldRefresh,
      errorMessage: errorMessage,
    );
  }
}

class AdNotifier extends StateNotifier<AdState> {
  AdNotifier() : super(const AdState()) {
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    await _loadTopBanner();
    await _loadBottomBanner();
  }

  Future<void> _loadTopBanner() async {
    state = state.copyWith(topBannerState: AdLoadState.loading);

    final banner = BannerAd(
      adUnitId: kTopBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = state.copyWith(
            topBanner: ad as BannerAd,
            topBannerState: AdLoadState.loaded,
          );
        },
        onAdFailedToLoad: (ad, error) {
          state = state.copyWith(
            topBannerState: AdLoadState.error,
            errorMessage: error.message,
          );
          ad.dispose();
        },
      ),
    );

    await banner.load();
    state = state.copyWith(topBanner: banner, topBannerState: AdLoadState.loaded);
  }

  Future<void> _loadBottomBanner() async {
    state = state.copyWith(bottomBannerState: AdLoadState.loading);

    final banner = BannerAd(
      adUnitId: kBottomBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = state.copyWith(
            bottomBanner: ad as BannerAd,
            bottomBannerState: AdLoadState.loaded,
          );
        },
        onAdFailedToLoad: (ad, error) {
          state = state.copyWith(
            bottomBannerState: AdLoadState.error,
            errorMessage: error.message,
          );
          ad.dispose();
        },
      ),
    );

    await banner.load();
    state = state.copyWith(bottomBanner: banner, bottomBannerState: AdLoadState.loaded);
  }

  Future<void> refreshAds() async {
    state.topBanner?.dispose();
    state.bottomBanner?.dispose();
    
    state = state.copyWith(
      topBanner: null,
      bottomBanner: null,
      shouldRefresh: false,
    );

    await _loadTopBanner();
    await _loadBottomBanner();
  }

  void triggerRefresh() {
    state = state.copyWith(shouldRefresh: true);
  }

  @override
  void dispose() {
    state.topBanner?.dispose();
    state.bottomBanner?.dispose();
    super.dispose();
  }
}

final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier();
});