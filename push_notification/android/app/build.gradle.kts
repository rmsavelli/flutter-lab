plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // já inclui kotlin-android
    id("dev.flutter.flutter-gradle-plugin") // deve vir após Android e Kotlin
    id("com.google.gms.google-services") // Firebase plugin
}

android {
    namespace = "com.example.push_notification"
    compileSdk = 35  // corrigido para 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.exemplo.pushnotification"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true  // habilita desugaring
    }

    kotlinOptions {
        jvmTarget = "17"
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
    implementation("com.google.firebase:firebase-messaging-ktx:24.0.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
