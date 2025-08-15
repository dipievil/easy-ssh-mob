#!/bin/bash

# Script para substituir FontAwesome icons por Material Icons
# Esse script é temporário para resolver problemas de compatibilidade

cd "$(dirname "$0")/../src"

echo "Substituindo imports de font_awesome_flutter..."

# Substituir imports
find lib/ -name "*.dart" -exec sed -i "s/import 'package:font_awesome_flutter\/font_awesome_flutter.dart';/import '..\/utils\/icon_mapping.dart';/g" {} \;

echo "Substituindo referências a FontAwesome icons..."

# Mapeamento dos ícones mais comuns
declare -A icon_map=(
    ["FontAwesomeIcons.folderOpen"]="IconMapping.getIcon('folderOpen')"
    ["FontAwesomeIcons.folder"]="IconMapping.getIcon('folder')"
    ["FontAwesomeIcons.file"]="IconMapping.getIcon('file')"
    ["FontAwesomeIcons.fileLines"]="IconMapping.getIcon('fileLines')"
    ["FontAwesomeIcons.fileCode"]="IconMapping.getIcon('fileCode')"
    ["FontAwesomeIcons.terminal"]="IconMapping.getIcon('terminal')"
    ["FontAwesomeIcons.gear"]="IconMapping.getIcon('gear')"
    ["FontAwesomeIcons.play"]="IconMapping.getIcon('play')"
    ["FontAwesomeIcons.stop"]="IconMapping.getIcon('stop')"
    ["FontAwesomeIcons.clock"]="IconMapping.getIcon('clock')"
    ["FontAwesomeIcons.clockRotateLeft"]="IconMapping.getIcon('clockRotateLeft')"
    ["FontAwesomeIcons.question"]="IconMapping.getIcon('question')"
    ["FontAwesomeIcons.circleCheck"]="IconMapping.getIcon('circleCheck')"
    ["FontAwesomeIcons.check"]="IconMapping.getIcon('check')"
    ["FontAwesomeIcons.triangleExclamation"]="IconMapping.getIcon('triangleExclamation')"
    ["FontAwesomeIcons.ban"]="IconMapping.getIcon('ban')"
    ["FontAwesomeIcons.circleExclamation"]="IconMapping.getIcon('circleExclamation')"
    ["FontAwesomeIcons.xmark"]="IconMapping.getIcon('xmark')"
    ["FontAwesomeIcons.circleInfo"]="IconMapping.getIcon('circleInfo')"
    ["FontAwesomeIcons.plus"]="IconMapping.getIcon('plus')"
    ["FontAwesomeIcons.penToSquare"]="IconMapping.getIcon('penToSquare')"
    ["FontAwesomeIcons.trash"]="IconMapping.getIcon('trash')"
    ["FontAwesomeIcons.download"]="IconMapping.getIcon('download')"
    ["FontAwesomeIcons.upload"]="IconMapping.getIcon('upload')"
    ["FontAwesomeIcons.copy"]="IconMapping.getIcon('copy')"
    ["FontAwesomeIcons.server"]="IconMapping.getIcon('server')"
    ["FontAwesomeIcons.database"]="IconMapping.getIcon('database')"
    ["FontAwesomeIcons.readme"]="IconMapping.getIcon('readme')"
    ["FontAwesomeIcons.certificate"]="IconMapping.getIcon('certificate')"
    ["FontAwesomeIcons.hammer"]="IconMapping.getIcon('hammer')"
    ["FontAwesomeIcons.docker"]="IconMapping.getIcon('docker')"
    ["FontAwesomeIcons.npm"]="IconMapping.getIcon('npm')"
    ["FontAwesomeIcons.php"]="IconMapping.getIcon('php')"
    ["FontAwesomeIcons.python"]="IconMapping.getIcon('python')"
    ["FontAwesomeIcons.java"]="IconMapping.getIcon('java')"
    ["FontAwesomeIcons.gem"]="IconMapping.getIcon('gem')"
)

# Aplicar substituições
for fa_icon in "${!icon_map[@]}"; do
    material_icon="${icon_map[$fa_icon]}"
    echo "Substituindo $fa_icon por $material_icon"
    find lib/ -name "*.dart" -exec sed -i "s/${fa_icon}/${material_icon}/g" {} \;
done

echo "Substituição concluída!"