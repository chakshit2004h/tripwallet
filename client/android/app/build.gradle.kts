import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadProperties = Properties()
val uploadPropertiesFile = rootProject.file("key.properties")
if (uploadPropertiesFile.exists()) {
    uploadPropertiesFile.inputStream().use { uploadProperties.load(it) }
}

android {
    namespace = "com.tripwallet.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.tripwallet.app"
        minSdk = maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadPropertiesFile.exists()) {
            create("upload") {
                keyAlias = uploadProperties.getProperty("keyAlias")
                keyPassword = uploadProperties.getProperty("keyPassword")
                storeFile = file(uploadProperties.getProperty("storeFile"))
                storePassword = uploadProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (uploadPropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("upload")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // Release signing is configured only when a private upload key is available.
    // Debug keys must never sign a Play Store build.
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(project(":ppocr-sdk"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("androidx.exifinterface:exifinterface:1.4.1")
}

// Fail closed for release artifacts: never silently produce an unsigned bundle.
gradle.taskGraph.whenReady {
    if (allTasks.any { it.project == project && it.name.contains("Release") &&
            (it.name.startsWith("package") || it.name.startsWith("bundle") || it.name.startsWith("assemble")) }) {
        check(uploadPropertiesFile.exists()) { "Release signing requires android/key.properties and the private upload key." }
    }
}
