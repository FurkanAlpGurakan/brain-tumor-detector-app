# Genel Flutter ProGuard Kuralları
-keep class io.flutter.** { *; }
-keep class com.example.** { *; }

# Firebase ile ilgili tüm sınıfları koru
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Cloud Firestore için gerekli olanlar
-keep class com.google.firestore.** { *; }
-dontwarn com.google.firestore.**

# Firebase Auth için gerekli olanlar
-keep class com.google.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.auth.**
-dontwarn com.google.android.gms.auth.**

# Firebase Storage için gerekli olanlar
-keep class com.google.firebase.storage.** { *; }
-dontwarn com.google.firebase.storage.**

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task