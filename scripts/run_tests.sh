#!/bin/bash

# Script para gerar mocks e executar testes
# Usar este script na pasta src/ do projeto

echo "Gerando mocks com build_runner..."
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "Executando testes..."
flutter test --coverage --reporter=expanded

echo "Script concluído!"