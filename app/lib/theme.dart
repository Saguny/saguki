import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

/// Color tokens (PLAN.md §7). Dark only.
class C {
  static const bg = Color(0xFF0E0D12);
  static const surface1 = Color(0xFF16151C);
  static const surface2 = Color(0xFF1E1C26);
  static const surface3 = Color(0xFF272433);
  static const border = Color(0xFF2E2B3A);
  static const text = Color(0xFFECEAF2);
  static const text2 = Color(0xFFA9A5B8);
  static const text3 = Color(0xFF6F6B80);
  static const accent = Color(0xFFB9A7FF);
  static const accentContainer = Color(0xFF2C2547);
  static const onAccent = Color(0xFF17132A);
  static const again = Color(0xFFFF8A94);
  static const hard = Color(0xFFF2C078);
  static const good = Color(0xFF86D9A8);
  static const easy = Color(0xFF8EC9FF);
}

/// Swap to 'SF Pro' here if you bundle it (licence: Apple platforms only).
const kFont = 'Inter';

/// CJK fallback order decides which glyph set wins for unified Han characters.
List<String> cjkFallback(String? lang) =>
    lang == 'zh-Hant' || lang == 'zh-Hans' ? const ['NotoSansTC', 'NotoSansJP'] : const ['NotoSansJP', 'NotoSansTC'];

Locale? localeFor(String? lang) => switch (lang) {
      'ja' => const Locale('ja', 'JP'),
      'zh-Hant' => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
      'zh-Hans' => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
      'ko' => const Locale('ko', 'KR'),
      _ => null,
    };

/// Text style on the SF/iOS scale. Variable fonts need the wght axis set explicitly.
TextStyle ts(double size, {int w = 400, Color color = C.text, double? height, String? lang}) => TextStyle(
      fontFamily: kFont,
      fontFamilyFallback: cjkFallback(lang),
      locale: localeFor(lang),
      fontSize: size,
      fontWeight: FontWeight.values[(w ~/ 100) - 1],
      fontVariations: [FontVariation('wght', w.toDouble())],
      color: color,
      height: height,
    );

/// iOS type scale.
class T {
  static final largeTitle = ts(34, w: 700, height: 1.2);
  static final title2 = ts(22, w: 700);
  static final title3 = ts(20, w: 600);
  static final headline = ts(17, w: 600);
  static final body = ts(17);
  static final callout = ts(16);
  static final subhead = ts(15, color: C.text2);
  static final footnote = ts(13, color: C.text2);
  static final caption = ts(12, color: C.text3);
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: kFont);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      surface: C.bg,
      surfaceContainerLow: C.surface1,
      surfaceContainer: C.surface2,
      surfaceContainerHigh: C.surface3,
      primary: C.accent,
      onPrimary: C.onAccent,
      primaryContainer: C.accentContainer,
      secondary: C.accent,
      onSurface: C.text,
      onSurfaceVariant: C.text2,
      outline: C.border,
      outlineVariant: C.border,
      error: C.again,
    ),
    textTheme: base.textTheme.copyWith(
      bodyLarge: T.body,
      bodyMedium: T.callout,
      bodySmall: T.footnote,
      titleLarge: T.title2,
      titleMedium: T.headline,
      labelLarge: ts(15, w: 600),
    ),
    dividerTheme: const DividerThemeData(color: C.border, thickness: 0.5, space: 0.5),
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: T.headline,
      iconTheme: const IconThemeData(color: C.accent),
      actionsIconTheme: const IconThemeData(color: C.accent),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.accent,
        foregroundColor: C.onAccent,
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: ts(17, w: 600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: C.accent, textStyle: ts(17))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surface2,
      labelStyle: T.subhead,
      floatingLabelStyle: ts(13, color: C.accent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: C.accent, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: C.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: C.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: T.callout,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.surface3,
      contentTextStyle: T.callout,
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    }),
  );
}

/// iOS-Settings-style grouped section: rows on surface1 with hairline dividers.
class Group extends StatelessWidget {
  const Group({super.key, required this.children, this.header});
  final List<Widget> children;
  final String? header;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(header!.toUpperCase(), style: ts(12, color: C.text3, w: 500)),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ColoredBox(
              color: C.surface1,
              child: Column(children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Padding(padding: EdgeInsets.only(left: 16), child: Divider()),
                  children[i],
                ],
              ]),
            ),
          ),
        ],
      );
}
