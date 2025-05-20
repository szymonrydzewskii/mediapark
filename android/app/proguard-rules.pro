############################################
#   PROGUARD RULES FOR MEDIAPARK APP       #
############################################

########## FLUTTER ENGINE & EMBEDDING ##########

# Zachowaj klasy Fluttera
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Pluginy Fluttera
-keep class io.flutter.plugins.** { *; }

########## PLATFORM CHANNELS / JNI ##########

# JNI używane przez Fluttera
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

########## WEBVIEW (używasz WebView) ##########

# Dla Android WebView + WebViewClient
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void onReceivedSslError(android.webkit.WebView, android.webkit.SslErrorHandler, android.net.http.SslError);
}
-dontwarn android.webkit.**

########## HTTP / URI / JSON ##########

# GSON (jeśli używasz json_serializable albo GSON bezpośrednio)
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*
-dontwarn com.google.gson.**

########## OGÓLNE WYKLUCZENIA DLA STABILNOŚCI ##########

# Zachowaj adnotacje (często używane przez generatory kodu Fluttera)
-keepattributes Signature, RuntimeVisibleAnnotations, AnnotationDefault

# Zachowaj wszystkie klasy `GeneratedPluginRegistrant` (wymagane przez Flutter)
