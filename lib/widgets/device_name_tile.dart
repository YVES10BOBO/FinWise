import 'package:flutter/material.dart';
import '../services/device_identity_service.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

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
        title: Text(context.l10n.nameThisPhone),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.nameThisPhoneBody,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.deviceName,
                prefixIcon: Icon(Icons.smartphone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(context.l10n.save),
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
      title: Text(context.l10n.thisPhone),
      subtitle: Text(
        _name == null
            ? context.l10n.namingDevice
            : context.l10n.shownOnTx(_name!),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: _rename,
    );
  }
}
