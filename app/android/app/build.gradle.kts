import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The Play upload key (M8). `android/key.properties` is written by
// `tool/make_upload_key.ps1` on the owner's machine, or by the Release workflow
// from GitHub secrets, and is git-ignored. Without it a release build is signed
// with the debug key: it still installs on an emulator, and Play refuses a
// debug-signed bundle, so an unkeyed build cannot be uploaded by mistake.
// https://docs.flutter.dev/deployment/android#configure-signing-in-gradle
val uploadKeyFile = rootProject.file("key.properties")
val uploadKey = Properties().apply {
    if (uploadKeyFile.exists()) FileInputStream(uploadKeyFile).use { load(it) }
}

android {
    namespace = "io.github.hongphuc_pham.schwanotes"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications, which uses java.time to
        // schedule the optional daily reminder (F-066) in the device timezone.
        // Without this the release build fails at :app:checkReleaseAarMetadata.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Permanent once uploaded to Play. Based on the owner's GitHub account, the one
        // namespace they own; `_` because Android package segments cannot contain `-`
        // (iOS, which cannot contain `_`, uses io.github.hongphuc-pham.schwanotes).
        applicationId = "io.github.hongphuc_pham.schwanotes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadKeyFile.exists()) {
            create("upload") {
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
                storeFile = file(uploadKey.getProperty("storeFile"))
                storePassword = uploadKey.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (uploadKeyFile.exists()) {
                    signingConfigs.getByName("upload")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

dependencies {
    // Backports java.time and friends to the minSdk. Pairs with
    // isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
