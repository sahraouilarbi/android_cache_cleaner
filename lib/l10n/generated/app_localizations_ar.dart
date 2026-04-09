// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CacheFlow';

  @override
  String get refresh => 'تحديث';

  @override
  String get info => 'معلومات';

  @override
  String get cacheCleaningCompleted =>
      'تم الانتهاء من تنظيف ذاكرة التخزين المؤقت!';

  @override
  String get accessibilityRequired =>
      'يرجى تمكين خدمة إمكانية الوصول لأتمتة التنظيف.';

  @override
  String errorMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get noAppsFound => 'لم يتم العثور على تطبيقات.';

  @override
  String get totalCacheSize => 'إجمالي حجم ذاكرة التخزين المؤقت';

  @override
  String get topOffenders => 'الأكثر استهلاكاً';

  @override
  String get allApplications => 'جميع التطبيقات';

  @override
  String appSize(String size) {
    return 'حجم التطبيق: $size';
  }

  @override
  String get cleanAllCache => 'تنظيف كل ذاكرة التخزين المؤقت';

  @override
  String get about => 'حول التطبيق';

  @override
  String get developer => 'المطور';

  @override
  String get openSource => 'مفتوح المصدر';

  @override
  String get sourceCodeGithub => 'كود المصدر على GitHub';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get appDescription =>
      'CacheFlow هو أداة مساعدة مفتوحة المصدر مصممة لتحسين مساحة التخزين الخاصة بك عن طريق تنظيف ملفات ذاكرة التخزين المؤقت لتطبيقاتك بذكاء.';

  @override
  String get officialSite => 'الموقع الرسمي';

  @override
  String get supportContact => 'الدعم والاتصال';

  @override
  String get contributeToProject => 'ساهم في المشروع';

  @override
  String get openSourceLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get copyright => '© 2026 Larbi Sahraoui. موزع بموجب رخصة GPL v3.';

  @override
  String get madeWithLove => 'صنع بكل ❤️ بواسطة Larbi Sahraoui';
}
