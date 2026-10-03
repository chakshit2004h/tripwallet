import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/supabase_auth_service.dart';

final supabaseExpensesServiceProvider = Provider<SupabaseExpensesService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final auth = ref.watch(supabaseAuthServiceProvider);
  return SupabaseExpensesService(client: client, auth: auth);
});

class SupabaseExpense {
  final String id;
  final String tripId;
  final String title;
  final int amountMinor;
  final String category;
  final String currency;
  final String paidByUserId;
  final String splitMethod;
  final int taxMinor;
  final int serviceChargeMinor;
  final DateTime createdAt;

  SupabaseExpense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amountMinor,
    required this.category,
    required this.currency,
    required this.paidByUserId,
    required this.splitMethod,
    required this.taxMinor,
    required this.serviceChargeMinor,
    required this.createdAt,
  });

  factory SupabaseExpense.fromMap(Map<String, dynamic> map) {
    return SupabaseExpense(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      amountMinor: ((map['amount_minor'] as num?)?.toInt() ?? 0),
      category: map['category'] as String? ?? 'food',
      currency: map['currency'] as String? ?? 'INR',
      paidByUserId: map['paid_by_user_id'] as String? ?? '',
      splitMethod: map['split_method'] as String? ?? 'equal',
      taxMinor: ((map['tax_minor'] as num?)?.toInt() ?? 0),
      serviceChargeMinor: ((map['service_charge_minor'] as num?)?.toInt() ?? 0),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }
}

class SupabaseSettlement {
  final String id;
  final String tripId;
  final String fromUserId;
  final String toUserId;
  final int amountMinor;
  final String currency;
  final String method;
  final String status;
  final DateTime createdAt;

  SupabaseSettlement({
    required this.id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.amountMinor,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory SupabaseSettlement.fromMap(Map<String, dynamic> map) {
    return SupabaseSettlement(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      fromUserId: map['from_user_id'] as String? ?? '',
      toUserId: map['to_user_id'] as String? ?? '',
      amountMinor: ((map['amount_minor'] as num?)?.toInt() ?? 0),
      currency: map['currency'] as String? ?? 'INR',
      method: map['method'] as String? ?? 'upi',
      status: map['status'] as String? ?? 'confirmed',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }
}

class SupabaseExpensesService {
  final SupabaseClient? client;
  final SupabaseAuthService auth;

  SupabaseExpensesService({this.client, required this.auth});

  Future<SupabaseExpense> addExpense({
    required String tripId,
    required String title,
    required int amountMinor,
    String category = 'food',
    String currency = 'INR',
    required String paidByUserId,
    String splitMethod = 'equal',
    int taxMinor = 0,
    int serviceChargeMinor = 0,
    List<Map<String, dynamic>>? lineItems,
  }) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    final user = auth.currentUser;
    if (user == null) throw Exception('Must be logged in to add expense');

    final expenseMap = await c.from('expenses').insert({
      'trip_id': tripId,
      'title': title,
      'amount_minor': amountMinor,
      'category': category,
      'currency': currency,
      'paid_by_user_id': paidByUserId,
      'split_method': splitMethod,
      'tax_minor': taxMinor,
      'service_charge_minor': serviceChargeMinor,
      'created_by_user_id': user.id,
    }).select().single();

    final expenseId = expenseMap['id'] as String;

    // Insert itemized line items if provided
    if (lineItems != null && lineItems.isNotEmpty) {
      for (final item in lineItems) {
        final lineItemMap = await c.from('expense_line_items').insert({
          'expense_id': expenseId,
          'label': item['label'] as String,
          'price_minor': item['price_minor'] as int,
          'ocr_confidence': (item['confidence'] as num?)?.toDouble() ?? 1.0,
        }).select().single();

        final lineItemId = lineItemMap['id'] as String;
        final claimedBy = (item['claimed_by_user_ids'] as List<dynamic>?) ?? [];
        if (claimedBy.isNotEmpty) {
          final fraction = 1.0 / claimedBy.length;
          for (final userId in claimedBy) {
            await c.from('expense_item_claims').insert({
              'line_item_id': lineItemId,
              'user_id': userId,
              'share_fraction': fraction,
            });
          }
        }
      }
    }

    return SupabaseExpense.fromMap(expenseMap);
  }

  Future<List<SupabaseExpense>> fetchExpenses(String tripId) async {
    final c = client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: false);

      return (rows as List).map((e) => SupabaseExpense.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<SupabaseExpense>> streamExpenses(String tripId) {
    final c = client;
    if (c == null) return const Stream.empty();

    return c
        .from('expenses')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .map((list) => list.map((e) => SupabaseExpense.fromMap(e)).toList());
  }

  Future<void> deleteExpense(String expenseId) async {
    final c = client;
    if (c == null) return;
    await c.from('expenses').delete().eq('id', expenseId);
  }

  Future<SupabaseSettlement> recordSettlement({
    required String tripId,
    required String fromUserId,
    required String toUserId,
    required int amountMinor,
    String currency = 'INR',
    String method = 'upi',
    String? paymentReference,
  }) async {
    final c = client;
    if (c == null) throw Exception('Supabase client not initialized');

    final row = await c.from('settlements').insert({
      'trip_id': tripId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount_minor': amountMinor,
      'currency': currency,
      'method': method,
      'payment_reference': paymentReference,
      'status': 'confirmed',
    }).select().single();

    return SupabaseSettlement.fromMap(row);
  }

  Future<List<SupabaseSettlement>> fetchSettlements(String tripId) async {
    final c = client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('settlements')
          .select()
          .eq('trip_id', tripId)
          .order('created_at', ascending: false);

      return (rows as List).map((s) => SupabaseSettlement.fromMap(s)).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<SupabaseSettlement>> streamSettlements(String tripId) {
    final c = client;
    if (c == null) return const Stream.empty();

    return c
        .from('settlements')
        .stream(primaryKey: ['id'])
        .eq('trip_id', tripId)
        .order('created_at', ascending: false)
        .map((list) => list.map((s) => SupabaseSettlement.fromMap(s)).toList());
  }
}
