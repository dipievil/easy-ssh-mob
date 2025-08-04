allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

//src\android\build\app\outputs\flutter-apk

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("./").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
