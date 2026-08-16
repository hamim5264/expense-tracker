# Flutter ProGuard / R8 Rules for Maximum Optimization & Size Reduction

# Ignore optional Google Play Core SplitInstall classes referenced by Flutter Engine
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Keep Flutter Classes & Enums
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Native Plugins
-dontwarn io.flutter.plugins.**
-keep class io.flutter.plugins.** { *; }

# Keep Hive, Supabase & Dio
-keep class com.supabase.** { *; }
-dontwarn com.supabase.**
-dontwarn dio.**

# Remove line number attributes for size reduction & security
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
