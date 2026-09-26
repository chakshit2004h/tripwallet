import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class MembersListScreen extends ConsumerWidget {
  final String tripId;

  const MembersListScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Members', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<LocalMember>>(
        stream: (db.select(db.localMembers)..where((m) => m.tripId.equals(tripId))).watch(),
        builder: (context, snapshot) {
          final members = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isCreator = member.role == 'creator';
                    final isYou = member.displayName.toLowerCase() == 'you';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, color: AppColors.inkSoft, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(text: member.displayName),
                                  if (isCreator)
                                    const TextSpan(
                                      text: ' · creator',
                                      style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.normal),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!isCreator && !isYou)
                            TextButton(
                              onPressed: () async {
                                await (db.delete(db.localMembers)..where((m) => m.id.equals(member.id))).go();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Removed ${member.displayName}')),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Remove',
                                style: AppTypography.caption.copyWith(color: AppColors.inkSoft, fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/invite?tripId=$tripId'),
                  icon: const Icon(Icons.qr_code_rounded, size: 18),
                  label: const Text('Re-share invite link'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
