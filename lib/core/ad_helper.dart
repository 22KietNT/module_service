import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/web.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  static Logger logger = Logger();
  static SharedPreferences? sharedPreferences;
  static final AdHelper _instance = AdHelper._();
  factory AdHelper() {
    return _instance;
  }
  AdHelper._() {
    _initialize();
    unawaited(MobileAds.instance.initialize());
  }

  Future<void> _initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/7049598008';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3964253750';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/8673189370';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/7552160883';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get returnAppAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9257395921';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/5575463023';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static void loadInterstitialAd(context, {required Function() onAdClose}) {
    dialogLoading(context);
    InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) async {
            Navigator.of(context).pop();
            ad.show();
            hideStatusBar();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                logger.e('Interstitial onAdDismissedFullScreenContent');
                showStatusBar();
                onAdClose();
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                logger.e("Interstitial onAdFailedToShowFullScreenContent");
                showStatusBar();
                ad.dispose();
              },
              onAdShowedFullScreenContent: (ad) =>
                  logger.e("Interstitial onAdShowedFullScreenContent"),
              onAdWillDismissFullScreenContent: (ad) =>
                  logger.e("Interstitial onAdWillDismissFullScreenContent"),
            );
          },
          onAdFailedToLoad: (err) {
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
            Navigator.of(context).pop();
          },
        ));
  }

  static Future<dynamic> dialogLoading(context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    ScreenUtil.init(context, designSize: const Size(390, 867));
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          backgroundColor: isDarkMode == true ? Colors.black : Colors.white,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 55.h,
                  width: 64.w,
                  child: LottieBuilder.asset(
                    "assets/others/loading.json",
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                height: 30.h,
              ),
              Text(
                "An ad will appear...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode == false
                      ? const Color(0xFF4F4F4F)
                      : Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void loadBannerAd({
    required Function(BannerAd) adLoaded,
  }) async {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          adLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, err) {
          logger.e('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  static Future<void> loadNativeAd(
      {required Function(NativeAd) adLoaded,
      required TemplateType templateType}) async {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          adLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          logger.e('Failed to load a banner ad: ${error.message}');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
    ).load();
  }

  static void loadRewardAd(context, {required Function() onAdClose}) async {
    dialogLoading(context);
    return RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.show(
              onUserEarnedReward: (ad, reward) {},
            );
            hideStatusBar();
            Navigator.of(context).pop();
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {},
                onAdImpression: (ad) {},
                onAdFailedToShowFullScreenContent: (ad, err) {
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: SystemUiOverlay.values,
                  );
                  ad.dispose();
                },
                onAdDismissedFullScreenContent: (ad) {
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: SystemUiOverlay.values,
                  );
                  onAdClose();
                  ad.dispose();
                },
                onAdClicked: (ad) {});
          },
          onAdFailedToLoad: (LoadAdError error) {
            Navigator.of(context).pop();
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
            logger.e('RewardedAd failed to load: $error');
          },
        ));
  }

  static void hideStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[],
    );
  }

  static void showStatusBar() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void loadAd() {
    AppOpenAd.load(
      request: const AdRequest(),
      adUnitId: returnAppAdUnitId,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}
