#!/bin/bash

# Script para configurar o ambiente de desenvolvimento do EasySSH

set -e

# Instalar dependências básicas
echo "📦 Instalando dependências básicas..."
sudo apt update && sudo apt install -y openjdk-11-jdk wget unzip git curl

# Instalar Flutter
echo "🚀 Instalando Flutter..."
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_DIR
else
  echo "Flutter já está instalado em $FLUTTER_DIR"
fi
export PATH="$PATH:$FLUTTER_DIR/bin"

# Verificar instalação do Flutter
echo "🔍 Verificando instalação do Flutter..."
flutter doctor || { echo "Erro ao configurar o Flutter"; exit 1; }

# Instalar Android SDK
echo "📱 Instalando Android SDK..."
ANDROID_SDK_DIR="$HOME/android-sdk"
if [ ! -d "$ANDROID_SDK_DIR" ]; then
  mkdir -p $ANDROID_SDK_DIR/cmdline-tools
  cd $ANDROID_SDK_DIR/cmdline-tools
  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
  unzip commandlinetools-linux-9477386_latest.zip
  rm commandlinetools-linux-9477386_latest.zip
  mv cmdline-tools latest
else
  echo "Android SDK já está instalado em $ANDROID_SDK_DIR"
fi
export ANDROID_HOME=$ANDROID_SDK_DIR
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Aceitar licenças e instalar componentes do Android SDK
echo "📜 Aceitando licenças do Android SDK..."
sdkmanager --licenses || { echo "Erro ao aceitar licenças do Android SDK"; exit 1; }
echo "📦 Instalando ferramentas do Android SDK..."
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Verificar instalação do Java
echo "☕ Verificando instalação do Java..."
java -version || { echo "Erro ao configurar o Java"; exit 1; }

# Finalização
echo "✅ Ambiente configurado com sucesso!"
