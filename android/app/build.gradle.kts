import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing reads android/key.properties (git-ignored). storeFile is
// resolved from android/app, so ../upload-keystore.jks is android/upload-keystore.jks.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.the_lazy_bear_club.ludo_unbiased"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Play Store package name: permanent once the app is published.
        applicationId = "com.the_lazy_bear_club.ludo_unbiased"
        // versionCode/versionName come from `version:` in pubspec.yaml (name+code).
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// Never produce a release APK/AAB without the upload key.
tasks.matching { it.name.matches(Regex("(bundle|assemble|package)Release")) }.configureEach {
    doFirst {
        if (!keystorePropertiesFile.exists()) {
            throw GradleException("android/key.properties is missing; release builds must be signed with the upload key.")
        }
    }
}

flutter {
    source = "../.."
}
