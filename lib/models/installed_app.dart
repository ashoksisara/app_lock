// Transient model representing an installed app on the device
import 'dart:typed_data';

class InstalledApp {
  final String name;
  final String packageName;
  final Uint8List? icon;

  const InstalledApp({
    required this.name,
    required this.packageName,
    this.icon,
  });
}
