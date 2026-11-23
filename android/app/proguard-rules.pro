# OkHttp platform used only on JVM and when Conscrypt and other security providers are available.
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Formerly the CVM native bridge (CVM removed). Kept out of caution: removing them changes what R8 keeps.
-keep class fr.fabrique.social.gouv.pass_emploi_app.** { *; }
-keep class io.flutter.plugin.common.** { *; }
