import 'dart:math';
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

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<SupabaseTrip> createTrip({
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    String currency = 'INR',
    String? coverImageUrl,
  }) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to create a trip');
    }

    final inviteCode = _generateInviteCode();

    final tripData = await c.from('trips').insert({
      'name': name,
      'invite_code': inviteCode,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'base_currency': currency,
      'cover_image_url': coverImageUrl,
      'status': 'active',
      'created_by': user.id,
    }).select().single();

    final tripId = tripData['id'] as String;

    // Add creator to trip_members
    await c.from('trip_members').insert({
      'trip_id': tripId,
      'user_id': user.id,
      'display_name': auth.currentDisplayName,
      'role': 'creator',
      'payment_vpa': auth.currentPaymentVpa,
      'avatar_url': 'YO',
    });

    return SupabaseTrip.fromMap(tripData, memberCount: 1);
  }

  Future<List<SupabaseTrip>> fetchUserTrips() async {
    final c = client;
    if (c == null) return [];

    final user = auth.currentUser;
    if (user == null) return [];

    try {
      // Fetch trip IDs where user is a member
      final memberRows = await c
          .from('trip_members')
          .select('trip_id')
          .eq('user_id', user.id);

      final tripIds = (memberRows as List).map((row) => row['trip_id'] as String).toList();
      if (tripIds.isEmpty) return [];

      final tripsData = await c
          .from('trips')
          .select()
          .inFilter('id', tripIds)
          .order('created_at', ascending: false);

      final List<SupabaseTrip> results = [];
      for (final tripMap in tripsData) {
        final tripId = tripMap['id'] as String;
        // Count members
        final membersCount = await c
            .from('trip_members')
            .count(CountOption.exact)
            .eq('trip_id', tripId);

        // Sum expenses
        final expRows = await c
            .from('expenses')
            .select('amount_minor')
            .eq('trip_id', tripId);

        final totalSpent = (expRows as List).fold<int>(
          0,
          (sum, e) => sum + ((e['amount_minor'] as num?)?.toInt() ?? 0),
        );

        results.add(SupabaseTrip.fromMap(
          tripMap,
          memberCount: membersCount,
          totalSpentMinor: totalSpent,
        ));
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  Future<SupabaseTrip?> fetchTripById(String tripId) async {
    final c = client;
    if (c == null) return null;

    try {
      final tripMap = await c
          .from('trips')
          .select()
          .eq('id', tripId)
          .maybeSingle();

      if (tripMap == null) return null;

      final membersCount = await c
          .from('trip_members')
          .count(CountOption.exact)
          .eq('trip_id', tripId);

      return SupabaseTrip.fromMap(tripMap, memberCount: membersCount);
    } catch (_) {
      return null;
    }
  }

  Future<SupabaseTrip?> fetchTripByInviteCode(String inviteCode) async {
    final c = client;
    if (c == null) return null;

    try {
      final tripMap = await c
          .from('trips')
          .select()
          .eq('invite_code', inviteCode.toUpperCase().trim())
          .maybeSingle();

      if (tripMap == null) return null;

      final membersCount = await c
          .from('trip_members')
          .count(CountOption.exact)
          .eq('trip_id', tripMap['id']);

      return SupabaseTrip.fromMap(tripMap, memberCount: membersCount);
    } catch (_) {
      return null;
    }
  }

  Future<SupabaseTrip> joinTripByInviteCode(String inviteCode) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Must be logged in to join a trip');
    }

    final trip = await fetchTripByInviteCode(inviteCode);
    if (trip == null) {
      throw Exception('Invalid invite code: "$inviteCode". Trip not found.');
    }

    // Check if user is already a member
    final existing = await c
        .from('trip_members')
        .select()
        .eq('trip_id', trip.id)
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      await c.from('trip_members').insert({
        'trip_id': trip.id,
        'user_id': user.id,
        'display_name': auth.currentDisplayName,
        'role': 'member',
        'payment_vpa': auth.currentPaymentVpa,
      });
    }

    return trip;
  }

  Future<List<SupabaseTripMember>> fetchTripMembers(String tripId) async {
    final c = client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('trip_members')
          .select()
          .eq('trip_id', tripId)
          .order('joined_at', ascending: true);

      return (rows as List).map((m) => SupabaseTripMember.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<SupabaseTripMember>> streamTripMembers(String tripId) {
    final c = client;
    if (c == null) return const Stream.empty();

    return c
        .from('trip_members')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .map((list) => list.map((m) => SupabaseTripMember.fromMap(m)).toList());
  }

  Future<void> archiveTrip(String tripId) async {
    final c = client;
    if (c == null) return;
    await c.from('trips').update({'status': 'archived'}).eq('id', tripId);
  }

  Future<void> deleteTrip(String tripId) async {
    final c = client;
    if (c == null) return;
    await c.from('trips').delete().eq('id', tripId);
  }
}
