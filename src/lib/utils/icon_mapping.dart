import 'package:flutter/material.dart';

/// Temporary icon mapping to replace FontAwesome icons with Material Icons
/// This resolves compatibility issues with font_awesome_flutter and Flutter 3.24.5
class IconMapping {
  static const Map<String, IconData> _iconMap = {
    // File operations
    'folderOpen': Icons.folder_open,
    'folder': Icons.folder,
    'file': Icons.description,
    'fileLines': Icons.description,
    'fileCode': Icons.code,
    'readme': Icons.info,
    'certificate': Icons.security,
    
    // System operations
    'terminal': Icons.terminal,
    'gear': Icons.settings,
    'play': Icons.play_arrow,
    'stop': Icons.stop,
    'clock': Icons.access_time,
    'clockRotateLeft': Icons.history,
    'question': Icons.help,
    
    // Status icons
    'circleCheck': Icons.check_circle,
    'check': Icons.check,
    'triangleExclamation': Icons.warning,
    'ban': Icons.block,
    'circleExclamation': Icons.error,
    'xmark': Icons.close,
    'circleInfo': Icons.info,
    
    // Action icons
    'plus': Icons.add,
    'penToSquare': Icons.edit,
    'trash': Icons.delete,
    'download': Icons.download,
    'upload': Icons.upload,
    'copy': Icons.copy,
    'scissors': Icons.cut,
    'paste': Icons.paste,
    'floppyDisk': Icons.save,
    'print': Icons.print,
    'eye': Icons.visibility,
    'magnifyingGlass': Icons.search,
    
    // Network & Server
    'server': Icons.dns,
    'database': Icons.storage,
    'networkWired': Icons.cable,
    'wifi': Icons.wifi,
    'hardDrive': Icons.storage,
    'memory': Icons.memory,
    'microchip': Icons.memory,
    'plug': Icons.power,
    'link': Icons.link,
    'rightLeft': Icons.swap_horiz,
    
    // Charts & Analytics
    'gaugeHigh': Icons.speed,
    'chartLine': Icons.trending_up,
    'rectangleList': Icons.list,
    'listCheck': Icons.checklist,
    
    // Time & Calendar
    'calendar': Icons.calendar_today,
    
    // User & Security
    'user': Icons.person,
    'users': Icons.group,
    'key': Icons.vpn_key,
    'lock': Icons.lock,
    'unlock': Icons.lock_open,
    'shield': Icons.security,
    
    // Development & Tools
    'bug': Icons.bug_report,
    'wrench': Icons.build,
    'screwdriver': Icons.build,
    'hammer': Icons.build,
    
    // Technology specific
    'docker': Icons.dns,
    'npm': Icons.javascript,
    'php': Icons.code,
    'python': Icons.code,
    'java': Icons.code,
    'gem': Icons.diamond,
    
    // Additional icons for full compatibility
    'house': Icons.home,
    'houseLaptop': Icons.computer,
    'houseSignal': Icons.wifi,
    'houseUser': Icons.person_pin_circle,
    'houseLock': Icons.lock_outline,
    'houseFlag': Icons.flag,
    'houseMedical': Icons.local_hospital,
    'houseChimney': Icons.home,
    'houseCircleCheck': Icons.home,
    'houseCircleExclamation': Icons.home,
    'houseCircleXmark': Icons.home,
    'houseCrack': Icons.home,
    'houseFire': Icons.home,
    'houseFloodWater': Icons.home,
    'houseHeart': Icons.home,
    'houseMedicalCircleCheck': Icons.home,
    'houseMedicalCircleExclamation': Icons.home,
    'houseMedicalCircleXmark': Icons.home,
    'houseMedicalFlag': Icons.home,
    'houseTsunami': Icons.home,
  };

  /// Get Material Icon for FontAwesome icon name
  static IconData getIcon(String fontAwesomeName) {
    return _iconMap[fontAwesomeName] ?? Icons.help;
  }

  // Direct FontAwesome to Material mapping for code replacement
  static const Map<String, IconData> fontAwesome = {
    'folderOpen': Icons.folder_open,
    'folder': Icons.folder,
    'file': Icons.description,
    'fileLines': Icons.description,
    'fileCode': Icons.code,
    'readme': Icons.info,
    'certificate': Icons.security,
    'terminal': Icons.terminal,
    'gear': Icons.settings,
    'play': Icons.play_arrow,
    'stop': Icons.stop,
    'clock': Icons.access_time,
    'clockRotateLeft': Icons.history,
    'question': Icons.help,
    'circleCheck': Icons.check_circle,
    'check': Icons.check,
    'triangleExclamation': Icons.warning,
    'ban': Icons.block,
    'circleExclamation': Icons.error,
    'xmark': Icons.close,
    'circleInfo': Icons.info,
    'plus': Icons.add,
    'penToSquare': Icons.edit,
    'trash': Icons.delete,
    'download': Icons.download,
    'upload': Icons.upload,
    'copy': Icons.copy,
    'scissors': Icons.cut,
    'paste': Icons.paste,
    'floppyDisk': Icons.save,
    'print': Icons.print,
    'eye': Icons.visibility,
    'magnifyingGlass': Icons.search,
    'server': Icons.dns,
    'database': Icons.storage,
    'networkWired': Icons.cable,
    'wifi': Icons.wifi,
    'hardDrive': Icons.storage,
    'memory': Icons.memory,
    'microchip': Icons.memory,
    'plug': Icons.power,
    'link': Icons.link,
    'rightLeft': Icons.swap_horiz,
    'gaugeHigh': Icons.speed,
    'chartLine': Icons.trending_up,
    'rectangleList': Icons.list,
    'listCheck': Icons.checklist,
    'calendar': Icons.calendar_today,
    'user': Icons.person,
    'users': Icons.group,
    'key': Icons.vpn_key,
    'lock': Icons.lock,
    'unlock': Icons.lock_open,
    'shield': Icons.security,
    'bug': Icons.bug_report,
    'wrench': Icons.build,
    'screwdriver': Icons.build,
    'hammer': Icons.build,
    'docker': Icons.dns,
    'npm': Icons.javascript,
    'php': Icons.code,
    'python': Icons.code,
    'java': Icons.code,
    'gem': Icons.diamond,
    'house': Icons.home,
    'houseLaptop': Icons.computer,
    'houseSignal': Icons.wifi,
    'houseUser': Icons.person_pin_circle,
    'houseLock': Icons.lock_outline,
    'houseFlag': Icons.flag,
    'houseMedical': Icons.local_hospital,
    'houseChimney': Icons.home,
  };
}