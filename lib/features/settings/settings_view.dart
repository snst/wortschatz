import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_notifier.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  late TextEditingController _languageFrontController;
  late TextEditingController _languageBackController;

  @override
  void initState() {
    super.initState();
    _languageFrontController = TextEditingController();
    _languageBackController = TextEditingController();
  }

  @override
  void dispose() {
    _languageFrontController.dispose();
    _languageBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    if (_languageFrontController.text != settings.langFront && !_languageFrontController.selection.isValid) {
      _languageFrontController.text = settings.langFront;
    }
    if (_languageBackController.text != settings.langBack && !_languageBackController.selection.isValid) {
      _languageBackController.text = settings.langBack;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(settings.frontIsQuestion ? '${settings.langFront} -> ${settings.langBack}' : '${settings.langBack} -> ${settings.langFront}'),
            subtitle: const Text('Direction'),
            value: settings.frontIsQuestion,
            onChanged: (val) => notifier.frontFirst = val,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Read aloud Solution'),
            value: settings.readAnswer,
            onChanged: (val) => notifier.readAnswer = val,
          ),
          ListTile(
            title: const Text('Speech Rate'),
            subtitle: Slider(
              value: settings.speechRate,
              min: 0.1,
              max: 1.5,
              divisions: 14,
              label: settings.speechRate.toStringAsFixed(1),
              onChanged: (val) => notifier.speechRate = val,
            ),
            trailing: Text(settings.speechRate.toStringAsFixed(1)),
          ),
          ListTile(
            title: const Text('Speech Rate (slow)'),
            subtitle: Slider(
              value: settings.speechRateSlow,
              min: 0.1,
              max: 1.5,
              divisions: 14,
              label: settings.speechRateSlow.toStringAsFixed(1),
              onChanged: (val) => notifier.speechRateSlow = val,
            ),
            trailing: Text(settings.speechRateSlow.toStringAsFixed(1)),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _languageFrontController,
              decoration: const InputDecoration(
                labelText: 'Language Front (e.g., es-ES)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) => notifier.langFront = val,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _languageBackController,
              decoration: const InputDecoration(
                labelText: 'Language Back (e.g., de-DE)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) => notifier.langBack = val,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
