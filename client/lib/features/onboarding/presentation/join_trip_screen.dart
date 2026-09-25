import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class JoinTripScreen extends StatefulWidget {
  const JoinTripScreen({super.key});

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Chakshit');
  String _selectedEmoji = '🏖️';
  Color _selectedColor = AppColors.coral;

  final List<String> _emojis = ['🏖️', '🍕', '🚀', '🏄', '✈️', '🌴', '🍹', '🛵'];
  final List<Color> _colors = [
    AppColors.coral,
    const Color(0xFF4EA8DE),
    AppColors.green,
    AppColors.amber,
    const Color(0xFF9B5DE5),
    const Color(0xFFF15BB5),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text('Join Trip', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('🌴', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goa Weekend 2026', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('12–16 Oct · 5 crew members', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text("Pick your guest identity", style: AppTypography.display.copyWith(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                'No email or password needed. Other members will see you by this name and avatar.',
                style: AppTypography.caption.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),

              // Avatar preview
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedColor.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty ? 'Your name' : _nameController.text,
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name input
              Text('YOUR NAME', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
                decoration: const InputDecoration(
                  hintText: 'Enter your name or nickname',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.coral),
                ),
              ),
              const SizedBox(height: 20),

              // Emoji Picker
              Text('CHOOSE ICON', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _emojis.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return InkWell(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.coral.withOpacity(0.25) : AppColors.paper,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.coral : AppColors.line,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Color Swatches
              Text('AVATAR COLOR', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 8),
              Row(
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Join Trip CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/trip/demo-trip'),
                  child: const Text('Enter Trip Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
