import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../theme.dart';

import '../models/chess_persona.dart';
import 'debug_log_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final isHumanVsAi = gameState.gameMode == GameMode.humanVsAi;
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).dividerColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: ChessTheme.trafficOrange,
            letterSpacing: 1,
            fontSize: 14,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, 'THEME'),
          Container(
            decoration: ChessTheme.koStyle(context),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(child: _buildModeButton(context, 'LIGHT', gameState.themeMode == ThemeMode.light, () => gameNotifier.updateTheme(ThemeMode.light))),
                Expanded(child: _buildModeButton(context, 'DARK', gameState.themeMode == ThemeMode.dark, () => gameNotifier.updateTheme(ThemeMode.dark))),
                Expanded(child: _buildModeButton(context, 'SYSTEM', gameState.themeMode == ThemeMode.system, () => gameNotifier.updateTheme(ThemeMode.system))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'GAMEPLAY'),
          _buildSwitchTile(
            context,
            'VISUAL THINKING',
            gameState.showArrows,
            (value) => gameNotifier.updateSettings(showArrows: value),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, 'MODE'),
          _buildModeSelector(
            context,
            gameState.gameMode, 
            (mode) => gameNotifier.updateSettings(gameMode: mode)
          ),
          
          const SizedBox(height: 24),
          
          if (isHumanVsAi) ...[
            _buildSectionHeader(context, 'YOUR COLOR'),
            _buildSwitchTile(
              context,
              gameState.playAsWhite ? 'WHITE' : 'BLACK',
              gameState.playAsWhite,
              (val) => gameNotifier.updateSettings(playAsWhite: val),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'OPPONENT'),
            ...ChessPersona.all.map((persona) => _buildPersonaCard(
                  context,
                  persona,
                  gameState.blackPersona.name == persona.name,
                  (p) => gameNotifier.updateSettings(blackPersona: p),
                )),
          ] else ...[
            _buildSectionHeader(context, 'WHITE PLAYER'),
            _buildPersonaDropdown(
              context,
              gameState.whitePersona,
              (p) => gameNotifier.updateSettings(whitePersona: p),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(context, 'BLACK PLAYER'),
             _buildPersonaDropdown(
              context,
              gameState.blackPersona,
              (p) => gameNotifier.updateSettings(blackPersona: p),
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    'DEEP CHESS ENGINE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 8, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const DebugLogScreen())
                    ),
                    child: Text('VIEW DEBUG LOGS', style: TextStyle(color: ChessTheme.trafficOrange, fontSize: 10)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'VERSION 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 8, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector(BuildContext context, GameMode currentMode, Function(GameMode) onChanged) {
    return Container(
      decoration: ChessTheme.koStyle(context),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildModeButton(context, 'HUMAN', currentMode == GameMode.humanVsAi, () => onChanged(GameMode.humanVsAi))),
          Expanded(child: _buildModeButton(context, 'AIvAI', currentMode == GameMode.aiVsAi, () => onChanged(GameMode.aiVsAi))),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected ? ChessTheme.trafficOrange : Colors.transparent,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : Theme.of(context).dividerColor,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPersonaDropdown(BuildContext context, ChessPersona selected, Function(ChessPersona) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ChessTheme.koStyle(context),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChessPersona>(
          value: ChessPersona.all.firstWhere((p) => p.name == selected.name, orElse: () => ChessPersona.all.first),
          dropdownColor: Theme.of(context).cardColor,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: ChessTheme.trafficOrange),
          items: ChessPersona.all.map((persona) {
            return DropdownMenuItem(
              value: persona,
              child: Text(
                '${persona.name.toUpperCase()} (${persona.year}) - ELO ${persona.elo}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: ChessTheme.koStyle(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ChessTheme.trafficOrange,
            activeTrackColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaCard(BuildContext context, ChessPersona persona, bool isSelected, Function(ChessPersona) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(persona),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ChessTheme.trafficOrange.withValues(alpha: 0.05) : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? ChessTheme.trafficOrange : Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  persona.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? ChessTheme.trafficOrange : Theme.of(context).dividerColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${persona.year} • ELO ${persona.elo}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 8, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              persona.vibe.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 7, color: ChessTheme.trafficOrange),
            ),
            const SizedBox(height: 8),
            Text(
              persona.bio,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
