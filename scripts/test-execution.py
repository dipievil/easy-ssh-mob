#!/usr/bin/env python3

"""
Script de teste Python para validar execução de scripts Python
Este script testa várias funcionalidades que devem ser capturadas pela interface
"""

import sys
import os
import time
from datetime import datetime

def main():
    print("=== Teste Python - Easy SSH Mob ===")
    print(f"Timestamp: {datetime.now()}")
    print(f"Versão Python: {sys.version}")
    print(f"Diretório atual: {os.getcwd()}")
    print(f"Argumentos: {sys.argv}")
    
    print("\n=== Teste de Saída Formatada ===")
    print("Output normal")
    print("Caracteres especiais: áéíóú çñü")
    print("Unicode: 🚀 ✅ ❌ 🐍")
    
    print("\n=== Teste de Loop ===")
    for i in range(3):
        print(f"Iteração {i+1}")
        time.sleep(0.1)
    
    print("\n=== Teste de Stderr ===", file=sys.stderr)
    print("Mensagem de erro em Python", file=sys.stderr)
    
    print("\n=== Teste de Variáveis de Ambiente ===")
    print(f"PATH: {os.environ.get('PATH', 'N/A')[:100]}...")
    print(f"HOME: {os.environ.get('HOME', 'N/A')}")
    print(f"USER: {os.environ.get('USER', 'N/A')}")
    
    print("\n=== Teste de Listagem ===")
    try:
        files = os.listdir('.')
        print(f"Encontrados {len(files)} arquivos/diretórios")
        for f in files[:5]:  # Mostra apenas os primeiros 5
            print(f"  - {f}")
        if len(files) > 5:
            print(f"  ... e mais {len(files)-5} items")
    except Exception as e:
        print(f"Erro ao listar diretório: {e}")
    
    print("\n=== Finalizando ===")
    print("Script Python executado com sucesso!")
    return 0

if __name__ == "__main__":
    exit(main())