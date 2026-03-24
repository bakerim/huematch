import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    
    // 🔥 FİREBASE DÜKKAN İÇİ EKLENTİSİ (JSON'I OKUYACAK OLAN KOD BU)
    id("com.google.gms.google-services")
}

// 🔥 1. ADIM: GİZLİ KASAYI AÇIYORUZ (key.properties dosyasını okuma işlemi)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.movingpixel.huematch"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 🔥 KAVGA BİTTİ! İkisi de Java 11'e çekildi!
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // 🔥 Burası zaten Java 11'di, artık alt tarafla %100 uyumlu!
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.movingpixel.huematch"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔥 2. ADIM: İMZALAMA AYARLARI (Tapu bilgilerini kasadan alıyoruz)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            val storeFileProp = keystoreProperties.getProperty("storeFile")
            if (storeFileProp != null) {
                storeFile = file(storeFileProp)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // 🔥 3. ADIM: ARTIK "debug" DEĞİL, KENDİ GÜVENLİ "release" İMZAMIZI KULLANIYORUZ
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// 🔥 ÇEVİRMEN MOTURUMUZ
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}