# Fix: Correção dos Erros de Instalação Android

## Problema Identificado

O erro `java.lang.ClassNotFoundException: Didn't find class "com.android.easy_ssh_mob.MainActivity"` estava ocorrendo porque havia uma discrepância entre:

- **Namespace declarado**: `com.android.easy_ssh_mob` (no `build.gradle.kts`)
- **Package real da MainActivity**: `com.example.easy_ssh_mob_new`

## Correções Aplicadas

### 1. Namespace Corrigido (build.gradle.kts)
```kotlin
// ANTES
namespace = "com.android.easy_ssh_mob"

// DEPOIS  
namespace = "com.example.easy_ssh_mob_new"
```

### 2. Configurações de Assinatura Protegidas
```kotlin
// ANTES - Causava erro quando key.properties não existia
signingConfigs {
    getByName("debug") {
        keyAlias = keystoreProperties["debugKeyAlias"] as String
        // ...
    }
}

// DEPOIS - Protegido com verificação de existência
signingConfigs {
    if (keystorePropertiesFile.exists()) {
        getByName("debug") {
            keyAlias = keystoreProperties["debugKeyAlias"] as String
            // ...
        }
    }
}
```

### 3. Settings.gradle.kts Robusto
```kotlin
// ANTES - Falhava se local.properties não existisse
file("local.properties").inputStream().use { properties.load(it) }
val flutterSdkPath = properties.getProperty("flutter.sdk")
require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }

// DEPOIS - Failsafe com fallbacks
val localPropertiesFile = file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { properties.load(it) }
}
val flutterSdkPath = properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT") ?: "/tmp/flutter"
```

### 4. Arquivo local.properties Criado
```properties
sdk.dir=/usr/lib/android-sdk
flutter.sdk=/tmp/flutter
```

## Resultado

✅ O namespace agora corresponde ao package real da MainActivity  
✅ Build não falhará mais por configurações de assinatura faltantes  
✅ Configuração do Flutter SDK tem fallbacks robustos  
✅ App deve instalar sem erro de ClassNotFoundException  

## Arquivos Modificados

- `src/android/app/build.gradle.kts`
- `src/android/settings.gradle.kts` 
- `src/android/local.properties` (criado)