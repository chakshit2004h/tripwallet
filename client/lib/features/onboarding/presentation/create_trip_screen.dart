import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Goa weekend');
  final TextEditingController _datesController = TextEditingController(text: '12 sep – 14 sep');
  final TextEditingController _currencyController = TextEditingController(text: 'INR');

  @override
  void dispose() {
    _nameController.dispose();
    _datesController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _createTrip() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
    final inviteCode = '9f${tripId.substring(tripId.length - 3)}';

    await db.into(db.localTrips).insert(
          LocalTripsCompanion.insert(
            id: tripId,
            name: name,
            inviteCode: inviteCode,
            startDate: drift.Value(DateTime.now()),
            endDate: drift.Value(DateTime.now().add(const Duration(days: 3))),
            baseCurrency: drift.Value(_currencyController.text.trim().isEmpty ? 'INR' : _currencyController.text.trim()),
            status: const drift.Value('active'),
          ),
        );

    // Insert user as member
    await db.into(db.localMembers).insert(
          LocalMembersCompanion.insert(
            id: 'm_you_$tripId',
            tripId: tripId,
            displayName: 'You',
            role: const drift.Value('organizer'),
            avatarUrl: const drift.Value('YO'),
          ),
        );

    if (mounted) {
      context.push('/invite?tripId=$tripId&inviteCode=$inviteCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('New trip', style: AppTypography.titleLarge),
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
              // Dashed cover area matching Step 4
              Container(
                height: 96,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.line,
                    style: BorderStyle.solid,
                    width: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Name field
              TextField(
                controller: _nameController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Trip name',
                ),
              ),
              const SizedBox(height: 10),

              // Dates field
              TextField(
                controller: _datesController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Dates (e.g. 12 sep – 14 sep)',
                ),
              ),
              const SizedBox(height: 10),

              // Currency field
              TextField(
                controller: _currencyController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text('INR  ₹', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const Spacer(),

              // Create trip button
              ElevatedButton(
                onPressed: _createTrip,
                child: const Text('Create trip'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
