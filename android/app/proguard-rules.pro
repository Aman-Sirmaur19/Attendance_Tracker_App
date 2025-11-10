#############################################
## Google Mobile Ads (AdMob)
#############################################
# Keep all classes from Google Play Services Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Keep all classes from Google Mobile Ads mediation adapters
-keep class com.google.ads.mediation.** { *; }
-dontwarn com.google.ads.mediation.**

#############################################
## Facebook Audience Network (FAN)
#############################################
# Keep Facebook Ads SDK classes
-keep class com.facebook.ads.** { *; }
-dontwarn com.facebook.ads.**

# Keep Infer Annotations (fixes your Nullsafe issue)
-keep class com.facebook.infer.annotation.** { *; }
-dontwarn com.facebook.infer.annotation.**

# Keep internal annotations used by FAN
-keep @interface com.facebook.ads.internal.**
-dontwarn com.facebook.ads.internal.**

#############################################
## General Rules (Safe Defaults)
#############################################
# Keep all annotations (prevents stripping used by SDKs)
-keepattributes *Annotation*

# Keep class members used by reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent obfuscation of native method names
-keepclasseswithmembernames class * {
    native <methods>;
}
