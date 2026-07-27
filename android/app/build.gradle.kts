import java.util.Base64

val dartEnvironmentVariables = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val dartDefines = project.property("dart-defines") as String
    dartDefines.split(",").forEach {
        try {
            val decoded = String(Base64.getDecoder().decode(it))
            val split = decoded.split("=")
            if (split.size == 2) {
                dartEnvironmentVariables[split[0].trim()] = split[1].trim()
            }
        } catch (e: Exception) {}
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.vahanmitra.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.vahanmitra.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
