import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val keyStoreFileExists = keystorePropertiesFile.exists()


logger.quiet("key.properties existe? $keyStoreFileExists")

if (keyStoreFileExists) {
    logger.info("key.properties carregado com sucesso.")
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    logger.warn("Arquivo key.properties não encontrado.")
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
        if (keyStoreFileExists) {
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
            if (keyStoreFileExists) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        debug {
            if (keyStoreFileExists) {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

}

flutter {
    source = "../.."
}

tasks.register("copyFlutterApks") {
    doLast {
        val fromDir = file("$buildDir/outputs/flutter-apk")
        val destDir = project.projectDir.parentFile.parentFile.resolve("build/app/outputs/flutter-apk")
        if (fromDir.exists()) {
            copy {
                from(fromDir)
                into(destDir)
            }
            logger.quiet("Copied APKs from $fromDir to $destDir")
        } else {
            logger.warn("No flutter-apk directory found at $fromDir; nothing to copy.")
        }
    }
}

gradle.projectsEvaluated {
    listOf("assembleDebug", "assembleRelease").forEach { name ->
        tasks.findByName(name)?.finalizedBy("copyFlutterApks")
    }
}
