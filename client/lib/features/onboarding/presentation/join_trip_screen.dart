import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class JoinTripScreen extends ConsumerStatefulWidget {
  final String tripId;

  const JoinTripScreen({super.key, this.tripId = 'demo-trip'});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Chirag');
  int _selectedAvatarIndex = 0;

  final List<String> _avatars = ['CH', 'YO', 'AI', 'RO'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    final memberId = 'm_${DateTime.now().millisecondsSinceEpoch}';

    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: memberId,
            tripId: widget.tripId,
            displayName: name,
            avatarUrl: drift.Value(_avatars[_selectedAvatarIndex]),
            role: const drift.Value('member'),
          ),
        );

    if (mounted) {
      context.go('/trip/${widget.tripId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Join trip', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Preview Card matching Step 6
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goa weekend', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('12–14 sep · 3 already in', style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text('Your name', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              const SizedBox(height: 18),

              Text('Pick an avatar', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_avatars.length, (index) {
                  final isSelected = _selectedAvatarIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => setState(() => _selectedAvatarIndex = index),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.coralTint : AppColors.paper,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.coral : AppColors.line,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _avatars[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.coral : AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Join trip button
              ElevatedButton(
                onPressed: _join,
                child: const Text('Join trip'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
