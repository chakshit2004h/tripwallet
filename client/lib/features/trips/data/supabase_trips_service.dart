import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/supabase_auth_service.dart';

final supabaseTripsServiceProvider = Provider<SupabaseTripsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final auth = ref.watch(supabaseAuthServiceProvider);
  return SupabaseTripsService(client: client, auth: auth);
});

class SupabaseTrip {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final String baseCurrency;
  final String? coverImageUrl;
  final String status;
  final String createdBy;
  final int memberCount;
  final int totalSpentMinor;

  SupabaseTrip({
    required this.id,
    required this.name,
    required this.inviteCode,
    this.startDate,
    this.endDate,
    required this.baseCurrency,
    this.coverImageUrl,
    required this.status,
    required this.createdBy,
    this.memberCount = 1,
    this.totalSpentMinor = 0,
  });

  factory SupabaseTrip.fromMap(Map<String, dynamic> map, {int memberCount = 1, int totalSpentMinor = 0}) {
    return SupabaseTrip(
      id: map['id'] as String,
      name: map['name'] as String,
      inviteCode: map['invite_code'] as String,
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date'] as String) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date'] as String) : null,
      baseCurrency: map['base_currency'] as String? ?? 'INR',
      coverImageUrl: map['cover_image_url'] as String?,
      status: map['status'] as String? ?? 'active',
      createdBy: map['created_by'] as String? ?? '',
      memberCount: memberCount,
      totalSpentMinor: totalSpentMinor,
    );
  }
}

class SupabaseTripMember {
  final String id;
  final String tripId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final String? paymentVpa;

  SupabaseTripMember({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    this.paymentVpa,
  });

  factory SupabaseTripMember.fromMap(Map<String, dynamic> map) {
    return SupabaseTripMember(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      userId: map['user_id'] as String,
      displayName: map['display_name'] as String? ?? 'Member',
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'member',
      paymentVpa: map['payment_vpa'] as String?,
    );
  }
}

class SupabaseTripsService {
  final SupabaseClient? client;
  final SupabaseAuthService auth;
  SupabaseTripsService({this.client, required this.auth});
  SupabaseClient get _client => client ?? (throw StateError('Cloud connection is not configured.'));

  Future<SupabaseTrip> createTrip({required String name, DateTime? startDate,
    DateTime? endDate, String currency = 'INR', String? coverImageUrl}) async {
    final row = await _client.rpc('create_trip', params: {
      'p_name': name.trim(), 'p_currency': currency,
      'p_start': startDate?.toIso8601String().split('T').first,
      'p_end': endDate?.toIso8601String().split('T').first,
    });
    return SupabaseTrip.fromMap(Map<String,dynamic>.from(row));
  }
  Future<List<SupabaseTrip>> fetchUserTrips() async {
    final rows = await _client.from('trips').select().order('created_at', ascending: false);
    return rows.map(SupabaseTrip.fromMap).toList();
  }
  Future<SupabaseTrip?> fetchTripById(String id) async {
    final row = await _client.from('trips').select().eq('id', id).maybeSingle();
    return row == null ? null : SupabaseTrip.fromMap(row);
  }
  Future<SupabaseTrip?> fetchTripByInviteCode(String code) async => _resolve(code, false);
  Future<SupabaseTrip> joinTripByInviteCode(String code) async => _resolve(code, true);
  Future<SupabaseTrip> _resolve(String code, bool join) async {
    final row = Map<String,dynamic>.from(await _client.rpc('resolve_invite',
      params: {'p_code': code.trim().toUpperCase(), 'p_join': join}));
    if (row['error'] != null) throw FormatException(row['error']);
    return SupabaseTrip.fromMap(row);
  }
  Future<List<SupabaseTripMember>> fetchTripMembers(String id) async {
    final rows = await _client.from('trip_members').select().eq('trip_id',id).order('joined_at');
    return rows.map(SupabaseTripMember.fromMap).toList();
  }
  Future<void> archiveTrip(String id) => manageTrip(id, 'archive');
  Future<void> deleteTrip(String id) => manageTrip(id, 'delete');
  Future<void> manageTrip(String id, String action) async {
    await _client.rpc('manage_trip',params:{'p_trip':id,'p_action':action});
  }
}
