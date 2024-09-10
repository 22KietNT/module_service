import 'package:ads_module/core/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class IntroPage extends StatefulWidget {
  IntroPage({super.key, required this.listItemIntro});

  List<Widget> listItemIntro;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController _pageController;
  late int currentIndex;
  NativeAd? _nativeAd;
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    _pageController = PageController(initialPage: currentIndex);
    AdHelper.loadNativeAd(
      adLoaded: (p0) => setState(() {
        AdHelper.logger.e("Loaded");
        _nativeAd = p0;
      }),
      templateType: TemplateType.small,
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(390, 867));
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 0.65.sh,
            child: PageView(
              onPageChanged: (value) => setState(() {
                currentIndex = value;
              }),
              controller: _pageController,
              children: widget.listItemIntro,
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 15.w,
              ),
              ..._buildIndicator(currentIndex),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    if (currentIndex < widget.listItemIntro.length - 1) {
                      setState(() {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      });
                    } else {
                      AdHelper.sharedPreferences?.setBool("isFirstTime", false);
                      AdHelper.loadInterstitialAd(context, onAdClose: () {
                        // Navigator.pushReplacement(context, HomePage.route());
                      });
                    }
                  },
                  child: Text(
                    currentIndex != widget.listItemIntro.length - 1
                        ? "NEXT"
                        : "START",
                    style: TextStyle(
                      color: const Color(0xFFA76ED6),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
            ],
          ),
          const Spacer(),
          _nativeAd != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 100,
                    child: AdWidget(ad: _nativeAd!),
                  ),
                )
              : Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                )
        ],
      ),
    );
  }

  List<Widget> _buildIndicator(int currentIndex) {
    List<Widget> result = [];
    for (int i = 0; i < widget.listItemIntro.length; i++) {
      if (currentIndex == i) {
        result.add(_indicator(true));
      } else {
        result.add(_indicator(false));
      }
    }
    return result;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 9,
      width: 9,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA76ED6) : const Color(0xFFD3D3D3),
          shape: BoxShape.circle),
    );
  }
}

class ItemIntros extends StatelessWidget {
  const ItemIntros({
    super.key,
    required this.img,
    required this.title,
    required this.des,
  });
  final String img, title, des;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          img,
          fit: BoxFit.cover,
          height: 433.h,
          width: double.infinity,
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5.h),
        Text(
          des,
          style: TextStyle(fontSize: 15.sp, color: const Color(0xFF636363)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
