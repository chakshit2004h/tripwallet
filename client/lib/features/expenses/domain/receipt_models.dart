import 'package:uuid/uuid.dart';

class ReceiptItem {
  final String id;
  String label;
  int priceMinor;
  int quantity;
  int? unitPriceMinor;
  String? taxRatePercent;
  final bool isAdjustment;
  double confidence;
  final Set<String> claimedMemberIds;

  ReceiptItem({
    String? id,
    required this.label,
    required this.priceMinor,
    this.quantity = 1,
    this.unitPriceMinor,
    this.taxRatePercent,
    this.isAdjustment = false,
    this.confidence = 0.95,
    Set<String>? claimedMemberIds,
  }) : id = id ?? const Uuid().v4(),
       claimedMemberIds = claimedMemberIds ?? <String>{};

  ReceiptItem copyWith({
    String? label,
    int? priceMinor,
    int? quantity,
    double? confidence,
    Set<String>? claimedMemberIds,
  }) {
    return ReceiptItem(
      id: id,
      label: label ?? this.label,
      priceMinor: priceMinor ?? this.priceMinor,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor,
      taxRatePercent: taxRatePercent,
      isAdjustment: isAdjustment,
      confidence: confidence ?? this.confidence,
      claimedMemberIds: claimedMemberIds ?? Set.from(this.claimedMemberIds),
    );
  }
}

class ReceiptData {
  final String id;
  final String tripId;
  String title;
  String currency;
  List<ReceiptItem> items;
  int taxMinor;
  int serviceChargeMinor;
  String payerMemberId;
  final Map<String, int> taxBreakdown;
  int? printedTotalMinor;

  ReceiptData({
    String? id,
    required this.tripId,
    required this.title,
    this.currency = 'INR',
    required this.items,
    this.taxMinor = 0,
    this.serviceChargeMinor = 0,
    this.payerMemberId = '',
    this.taxBreakdown = const {},
    this.printedTotalMinor,
  }) : id = id ?? const Uuid().v4();

  int get subtotalMinor => items
      .where((i) => !i.isAdjustment)
      .fold(0, (sum, item) => sum + item.priceMinor);
  int get adjustmentMinor => items
      .where((i) => i.isAdjustment)
      .fold(0, (sum, item) => sum + item.priceMinor);
  int get totalMinor =>
      subtotalMinor + adjustmentMinor + taxMinor + serviceChargeMinor;
}
