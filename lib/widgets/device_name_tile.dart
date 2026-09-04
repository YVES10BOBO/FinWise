import 'package:flutter/material.dart';
import '../services/device_identity_service.dart';
import '../theme/app_theme.dart';

/// Lets the user rename this phone.
///
/// Transactions are stamped with the device that recorded them, which is how
/// an entry synced from another signed-in phone can be recognised. The
/// default is the hardware model ("SM-A057F"), which is neither friendly nor
/// unique — two identical handsets would be indistinguishable, defeating the
/// point. Renaming fixes both.
class DeviceNameTile extends StatefulWidget {
  const DeviceNameTile({super.key});

  @override
  State<DeviceNameTile> createState() => _DeviceNameTileState();
}

class _DeviceNameTileState extends State<DeviceNameTile> {
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await DeviceIdentityService.currentName();
    if (mounted) setState(() => _name = name);
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _name ?? '');

    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Name this phone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Transactions recorded on this phone are labelled with this '
              'name, so you can tell them apart from ones recorded on your '
              'other devices.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Device name',
                prefixIcon: Icon(Icons.smartphone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == null || saved.trim().isEmpty) return;
    await DeviceIdentityService.rename(saved);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.smartphone,
            color: AppTheme.primaryColor, size: 20),
      ),
      title: const Text('This phone'),
      subtitle: Text(
        _name == null
            ? 'Naming this device…'
            : '$_name — shown on transactions recorded here',
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: _rename,
    );
  }
}
