import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../trips/data/supabase_trips_service.dart';

class JoinTripScreen extends ConsumerStatefulWidget {
  final String tripId;

  const JoinTripScreen({super.key, this.tripId = ''});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  SupabaseTrip? _previewTrip;

  final List<String> _avatars = ['YO', 'CH', 'AI', 'RO'];

  @override
  void initState() {
    super.initState();
    if (widget.tripId.isNotEmpty && widget.tripId != 'demo-trip') {
      _codeController.text = widget.tripId;
      _lookupCode(widget.tripId);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _lookupCode(String code) async {
    if (code.trim().length < 4) return;
    try {
      final supaTrips = ref.read(supabaseTripsServiceProvider);
      final trip = await supaTrips.fetchTripByInviteCode(code.trim());
      if (mounted && trip != null) {
        setState(() {
          _previewTrip = trip;
          _errorMessage = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter an invite code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supaTrips = ref.read(supabaseTripsServiceProvider);
      final trip = await supaTrips.joinTripByInviteCode(code);

      // Cache trip locally in Drift
      final db = ref.read(databaseProvider);
      await db.into(db.localTrips).insertOnConflictUpdate(
            LocalTripsCompanion.insert(
              id: trip.id,
              name: trip.name,
              inviteCode: trip.inviteCode,
              startDate: drift.Value(trip.startDate ?? DateTime.now()),
              endDate: drift.Value(trip.endDate ?? DateTime.now().add(const Duration(days: 3))),
              baseCurrency: drift.Value(trip.baseCurrency),
              status: drift.Value(trip.status),
            ),
          );

      if (mounted) {
        context.go('/trip/${trip.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invite Code Field
              Text('Trip invite code', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: AppTypography.bodyMedium.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'e.g. 9F2K4B',
                  prefixIcon: Icon(Icons.tag_rounded, size: 20),
                ),
                onChanged: (val) {
                  if (val.trim().length >= 4) {
                    _lookupCode(val.trim());
                  }
                },
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.coralDark),
                  ),
                ),
              ],

              // Trip Preview Card if found
              if (_previewTrip != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_previewTrip!.name, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_previewTrip!.memberCount} members',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Currency: ${_previewTrip!.baseCurrency} · Ready to join', style: AppTypography.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text('Your name in this trip', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter name (e.g. Chirag)',
                ),
              ),
              const SizedBox(height: 18),

              Text('Pick an avatar badge', style: AppTypography.titleMedium.copyWith(fontSize: 13)),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.coralTint : AppColors.paper,
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
              const SizedBox(height: 40),

              // Join trip button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _join,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_previewTrip != null ? 'Join ${_previewTrip!.name}' : 'Join trip'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
