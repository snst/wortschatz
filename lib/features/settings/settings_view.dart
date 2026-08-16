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
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) {
          final frontFirst = settings['frontFirst'] as bool;
          final readFront = settings['readFront'] as bool;
          final readBack = settings['readBack'] as bool;
          final langFront = settings['langFront'] as String;
          final langBack = settings['langBack'] as String;
          final speechRate = settings['speechRate'] as double;

          if (_languageFrontController.text != langFront && !_languageFrontController.selection.isValid) {
            _languageFrontController.text = langFront;
          }
          if (_languageBackController.text != langBack && !_languageBackController.selection.isValid) {
            _languageBackController.text = langBack;
          }

          return ListView(
            children: [
              SwitchListTile(
                title: Text(frontFirst ? '$langFront -> $langBack' : '$langBack -> $langFront'),
                subtitle: const Text('Direction'),
                value: frontFirst,
                onChanged: (val) => ref.read(settingsProvider.notifier).setFrontFirst(val),
              ),
              const Divider(),
              SwitchListTile(
                title: Text('Read aloud $langFront'),
                value: readFront,
                onChanged: (val) => ref.read(settingsProvider.notifier).setReadFront(val),
              ),
              SwitchListTile(
                title: Text('Read aloud $langBack'),
                value: readBack,
                onChanged: (val) => ref.read(settingsProvider.notifier).setReadBack(val),
              ),
              ListTile(
                title: const Text('Speech Rate'),
                subtitle: Slider(
                  value: speechRate,
                  min: 0.1,
                  max: 1.5,
                  divisions: 14,
                  label: speechRate.toStringAsFixed(1),
                  onChanged: (val) => ref.read(settingsProvider.notifier).setSpeechRate(val),
                ),
                trailing: Text(speechRate.toStringAsFixed(1)),
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
                  onSubmitted: (val) => ref.read(settingsProvider.notifier).setLanguageFront(val),
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
                  onSubmitted: (val) => ref.read(settingsProvider.notifier).setLanguageBack(val),
                ),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
