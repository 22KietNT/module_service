import 'package:ads_module/core/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

Future<bool> showExitConfirmationDialog(BuildContext context,
    {required String iconApp}) async {
  return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ExitApp(
          iconApp: iconApp,
        ),
      ) ??
      false;
}

class ExitApp extends StatefulWidget {
  const ExitApp({
    super.key,
    required this.iconApp,
  });
  final String iconApp;
  @override
  State<ExitApp> createState() => _ExitAppState();
}

class _ExitAppState extends State<ExitApp> {
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    AdHelper.loadNativeAd(
        adLoaded: (p0) => setState(() {
              _nativeAd = p0;
            }),
        templateType: TemplateType.medium);
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.iconApp,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Are you sure\n to exit the application?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _nativeAd != null
                ? SizedBox(
                    height: 360,
                    child: AdWidget(ad: _nativeAd!),
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.grey,
                      height: 420,
                      width: double.infinity,
                    )),
          ],
        ),
      ),
    );
  }
}
