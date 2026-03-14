# Add this specific ProGuard rules for Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep your app-specific classes
-keep class com.example.true_budget_app.** { *; }

# Google Fonts
-keep class com.google.fonts.** { *; }

# SQLite
-keep class android.database.sqlite.** { *; }

# Charts (if using fl_chart)
-keep class com.github.drjacky.** { *; }

# Lottie animations (if unused, consider removing)
-keep class com.airbnb.lottie.** { *; }

# Share functionality
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep all enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep all Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
