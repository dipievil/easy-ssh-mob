import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.easy_ssh_mob_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.dipi.android.easy_ssh_mob"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            getByName("debug") {
                keyAlias = keystoreProperties["debugKeyAlias"] as String
                keyPassword = keystoreProperties["debugKeyPassword"] as String
                storeFile = keystoreProperties["debugStoreFile"]?.let { file(it) }
                storePassword = keystoreProperties["debugStorePassword"] as String
            }
            create("release") {
                keyAlias = keystoreProperties["releaseKeyAlias"] as String
                keyPassword = keystoreProperties["releaseKeyPassword"] as String
                storeFile = keystoreProperties["releaseStoreFile"]?.let { file(it) }
                storePassword = keystoreProperties["releaseStorePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        debug {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    // applicationVariants.all { variant ->
    //     variant.assemble.doLast {
    //     copy {
    //         from "../../build/app/outputs/apk/${variant.flavorName}/${variant.buildType.name}/app-${variant.flavorName}-${variant.buildType.name}.apk";
    //         into '../../build/app/outputs/flutter-apk'
    //         }
    //     }
    // }
}

flutter {
    source = "../.."
}
