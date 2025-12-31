import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../theme.dart';
import '../models/chess_persona.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final isHumanVsAi = gameState.gameMode == GameMode.humanVsAi;

    return Scaffold(
      backgroundColor: ChessTheme.midnight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ChessTheme.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: ChessTheme.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('GAMEPLAY'),
          _buildSwitchTile(
            'Visual Thinking Lines',
            'Show arrows for the engine\'s last move',
            gameState.showArrows,
            (value) => gameNotifier.updateSettings(showArrows: value),
          ),
          const SizedBox(height: 30),
          
          _buildSectionHeader('MODE'),
          _buildModeSelector(
            gameState.gameMode, 
            (mode) => gameNotifier.updateSettings(gameMode: mode)
          ),
          
          const SizedBox(height: 30),
          
          if (isHumanVsAi) ...[
            _buildSectionHeader('YOUR COLOR'),
            _buildSwitchTile(
              gameState.playAsWhite ? 'Playing as White' : 'Playing as Black',
              gameState.playAsWhite ? 'You move first' : 'Engine moves first',
              gameState.playAsWhite,
              (val) => gameNotifier.updateSettings(playAsWhite: val),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('OPPONENT PERSONA'),
            const SizedBox(height: 10),
            ...ChessPersona.all.map((persona) => _buildPersonaCard(
                  context,
                  persona,
                  gameState.blackPersona.name == persona.name, // Match by name to be safe
                  (p) => gameNotifier.updateSettings(blackPersona: p),
                )),
          ] else ...[
            _buildSectionHeader('WHITE PLAYER'),
            _buildPersonaDropdown(
              gameState.whitePersona,
              (p) => gameNotifier.updateSettings(whitePersona: p),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('BLACK PLAYER'),
             _buildPersonaDropdown(
              gameState.blackPersona,
              (p) => gameNotifier.updateSettings(blackPersona: p),
            ),
            const SizedBox(height: 20),
            const Center(
               child: Text(
                 'AI vs AI starts automatically',
                 style: TextStyle(color: ChessTheme.accentGold),
               ),
            ),
          ],

          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Stockfish 16.0 Engine',
              style: TextStyle(color: ChessTheme.silver, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector(GameMode currentMode, Function(GameMode) onChanged) {
    return Container(
      decoration: ChessTheme.glassmorphism,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(GameMode.humanVsAi),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentMode == GameMode.humanVsAi ? ChessTheme.gold : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'HUMAN VS AI',
                    style: TextStyle(
                      color: currentMode == GameMode.humanVsAi ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(GameMode.aiVsAi),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentMode == GameMode.aiVsAi ? ChessTheme.gold : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'AI VS AI',
                    style: TextStyle(
                      color: currentMode == GameMode.aiVsAi ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonaDropdown(ChessPersona selected, Function(ChessPersona) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: ChessTheme.coal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChessPersona>(
          value: ChessPersona.all.firstWhere((p) => p.name == selected.name, orElse: () => ChessPersona.all.first),
          dropdownColor: ChessTheme.coal,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: ChessTheme.gold),
          items: ChessPersona.all.map((persona) {
            return DropdownMenuItem(
              value: persona,
              child: Text(
                '${persona.name} (${persona.year})',
                style: const TextStyle(color: Colors.white),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: ChessTheme.silver.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      decoration: ChessTheme.glassmorphism,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: ChessTheme.silver.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ChessTheme.gold,
            activeTrackColor: ChessTheme.coal,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaCard(BuildContext context, ChessPersona persona,
      bool isSelected, Function(ChessPersona) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(persona),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ChessTheme.gold.withOpacity(0.1) : ChessTheme.coal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ChessTheme.gold : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      persona.name.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? ChessTheme.gold : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        persona.year,
                        style: const TextStyle(color: ChessTheme.silver, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: ChessTheme.gold, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              persona.vibe.toUpperCase(),
              style: const TextStyle(
                color: ChessTheme.accentGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${persona.bio}"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Style: ${persona.style}',
              style: TextStyle(
                color: ChessTheme.silver.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
