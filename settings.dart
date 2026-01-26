import 'package:flutter/material.dart';

enum ThemeChoice { system, dark, light }


class Settings extends StatefulWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const Settings({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}


class _SettingsState extends State<Settings> {
  late ThemeChoice _selected;

  @override
  void initState() {
    super.initState();
    
    _selected = _modeToChoice(widget.currentMode);
  }

  
  ThemeChoice _modeToChoice(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeChoice.light;
      case ThemeMode.dark:
        return ThemeChoice.dark;
      case ThemeMode.system:
      default:
        return ThemeChoice.system;
    }
  }

  
  ThemeMode _choiceToMode(ThemeChoice choice) {
    switch (choice) {
      case ThemeChoice.light:
        return ThemeMode.light;
      case ThemeChoice.dark:
        return ThemeMode.dark;
      case ThemeChoice.system:
      default:
        return ThemeMode.system;
    }
  }

  // called when radio changes
  void _onRadioChanged(ThemeChoice? value) {
    if (value == null) return;
    setState(() => _selected = value); 
    widget.onModeChanged(_choiceToMode(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          RadioListTile<ThemeChoice>(
            title: const Text('Follow system'),
            value: ThemeChoice.system,
            groupValue: _selected,
            onChanged: _onRadioChanged,
            secondary: const Icon(Icons.phone_iphone),
          ),
          RadioListTile<ThemeChoice>(
            title: const Text('Light mode'),
            value: ThemeChoice.light,
            groupValue: _selected,
            onChanged: _onRadioChanged,
            secondary: const Icon(Icons.light_mode),
          ),
          RadioListTile<ThemeChoice>(
            title: const Text('Dark mode'),
            value: ThemeChoice.dark,
            groupValue: _selected,
            onChanged: _onRadioChanged,
            secondary: const Icon(Icons.dark_mode),
          ),
        ],
      ),
    );
  }
}
