#!/usr/bin/env python3
"""
Script para substituir imports e usos de FontAwesome por Material Icons
"""

import os
import re

def replace_in_file(filepath):
    """Replace FontAwesome imports and usages in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace import
        content = re.sub(
            r"import 'package:font_awesome_flutter/font_awesome_flutter\.dart';",
            "import '../utils/icon_mapping.dart';",
            content
        )
        
        # Replace FontAwesome icon references with Material Icons directly
        fa_to_material = {
            'FontAwesomeIcons.folderOpen': 'Icons.folder_open',
            'FontAwesomeIcons.folder': 'Icons.folder',
            'FontAwesomeIcons.file': 'Icons.description',
            'FontAwesomeIcons.fileLines': 'Icons.description', 
            'FontAwesomeIcons.fileCode': 'Icons.code',
            'FontAwesomeIcons.readme': 'Icons.info',
            'FontAwesomeIcons.certificate': 'Icons.security',
            'FontAwesomeIcons.terminal': 'Icons.terminal',
            'FontAwesomeIcons.gear': 'Icons.settings',
            'FontAwesomeIcons.play': 'Icons.play_arrow',
            'FontAwesomeIcons.stop': 'Icons.stop',
            'FontAwesomeIcons.clock': 'Icons.access_time',
            'FontAwesomeIcons.clockRotateLeft': 'Icons.history',
            'FontAwesomeIcons.question': 'Icons.help',
            'FontAwesomeIcons.circleCheck': 'Icons.check_circle',
            'FontAwesomeIcons.check': 'Icons.check',
            'FontAwesomeIcons.triangleExclamation': 'Icons.warning',
            'FontAwesomeIcons.ban': 'Icons.block',
            'FontAwesomeIcons.circleExclamation': 'Icons.error',
            'FontAwesomeIcons.xmark': 'Icons.close',
            'FontAwesomeIcons.circleInfo': 'Icons.info',
            'FontAwesomeIcons.plus': 'Icons.add',
            'FontAwesomeIcons.penToSquare': 'Icons.edit',
            'FontAwesomeIcons.trash': 'Icons.delete',
            'FontAwesomeIcons.download': 'Icons.download',
            'FontAwesomeIcons.upload': 'Icons.upload',
            'FontAwesomeIcons.copy': 'Icons.copy',
            'FontAwesomeIcons.scissors': 'Icons.cut',
            'FontAwesomeIcons.paste': 'Icons.paste',
            'FontAwesomeIcons.floppyDisk': 'Icons.save',
            'FontAwesomeIcons.print': 'Icons.print',
            'FontAwesomeIcons.eye': 'Icons.visibility',
            'FontAwesomeIcons.magnifyingGlass': 'Icons.search',
            'FontAwesomeIcons.server': 'Icons.dns',
            'FontAwesomeIcons.database': 'Icons.storage',
            'FontAwesomeIcons.networkWired': 'Icons.cable',
            'FontAwesomeIcons.wifi': 'Icons.wifi',
            'FontAwesomeIcons.hardDrive': 'Icons.storage',
            'FontAwesomeIcons.memory': 'Icons.memory',
            'FontAwesomeIcons.microchip': 'Icons.memory',
            'FontAwesomeIcons.plug': 'Icons.power',
            'FontAwesomeIcons.link': 'Icons.link',
            'FontAwesomeIcons.rightLeft': 'Icons.swap_horiz',
            'FontAwesomeIcons.gaugeHigh': 'Icons.speed',
            'FontAwesomeIcons.chartLine': 'Icons.trending_up',
            'FontAwesomeIcons.rectangleList': 'Icons.list',
            'FontAwesomeIcons.listCheck': 'Icons.checklist',
            'FontAwesomeIcons.calendar': 'Icons.calendar_today',
            'FontAwesomeIcons.user': 'Icons.person',
            'FontAwesomeIcons.users': 'Icons.group',
            'FontAwesomeIcons.key': 'Icons.vpn_key',
            'FontAwesomeIcons.lock': 'Icons.lock',
            'FontAwesomeIcons.unlock': 'Icons.lock_open',
            'FontAwesomeIcons.shield': 'Icons.security',
            'FontAwesomeIcons.bug': 'Icons.bug_report',
            'FontAwesomeIcons.wrench': 'Icons.build',
            'FontAwesomeIcons.screwdriver': 'Icons.build',
            'FontAwesomeIcons.hammer': 'Icons.build',
            'FontAwesomeIcons.docker': 'Icons.dns',
            'FontAwesomeIcons.npm': 'Icons.javascript',
            'FontAwesomeIcons.php': 'Icons.code',
            'FontAwesomeIcons.python': 'Icons.code',
            'FontAwesomeIcons.java': 'Icons.code',
            'FontAwesomeIcons.gem': 'Icons.diamond',
            'FontAwesomeIcons.house': 'Icons.home',
            'FontAwesomeIcons.houseLaptop': 'Icons.computer',
            'FontAwesomeIcons.houseSignal': 'Icons.wifi',
            'FontAwesomeIcons.houseUser': 'Icons.person_pin_circle',
            'FontAwesomeIcons.houseLock': 'Icons.lock_outline',
            'FontAwesomeIcons.houseFlag': 'Icons.flag',
            'FontAwesomeIcons.houseMedical': 'Icons.local_hospital',
            'FontAwesomeIcons.houseChimney': 'Icons.home',
        }
        
        # Apply replacements
        for fa_icon, material_icon in fa_to_material.items():
            content = content.replace(fa_icon, material_icon)
        
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print(f"Processed: {filepath}")
        
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

def main():
    # Process all dart files in lib directory
    lib_dir = "lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath)
    
    # Process test files too
    test_dir = "test"
    if os.path.exists(test_dir):
        for root, dirs, files in os.walk(test_dir):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file)
                    replace_in_file(filepath)

if __name__ == "__main__":
    main()