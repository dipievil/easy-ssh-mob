allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Wrapper task to assemble the app and copy generated flutter-apk outputs to repo-level build.
tasks.register("assembleDebugAndCopy") {
    group = "build"
    description = "Run :app:assembleDebug and copy generated flutter-apk to ../build/app/outputs/flutter-apk"
    dependsOn(":app:assembleDebug")
    doLast {
        val fromDir = file("app/build/outputs/flutter-apk")
        val destDir = rootProject.projectDir.resolve("src").resolve("build/app/outputs/flutter-apk")
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

