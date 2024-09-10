import 'package:in_app_review/in_app_review.dart';

class SettingHelper {
  static void feedback() async {
    InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        inAppReview.openStoreListing(
          appStoreId: 'your_ios_app_id',
        );
      }
    }
  }

}
