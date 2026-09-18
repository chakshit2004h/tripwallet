import 'package:uuid/uuid.dart';

class ReceiptItem {
  final String id;
  String label;
  int priceMinor;
  int quantity;
  double confidence;
  final Set<String> claimedMemberIds;

  ReceiptItem({
    String? id,
    required this.label,
    required this.priceMinor,
    this.quantity = 1,
    this.confidence = 0.95,
    Set<String>? claimedMemberIds,
  })  : id = id ?? const Uuid().v4(),
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

  ReceiptData({
    String? id,
    required this.tripId,
    required this.title,
    this.currency = 'INR',
    required this.items,
    this.taxMinor = 0,
    this.serviceChargeMinor = 0,
    this.payerMemberId = 'm1',
  }) : id = id ?? const Uuid().v4();

  int get subtotalMinor => items.fold(0, (sum, item) => sum + item.priceMinor);
  int get totalMinor => subtotalMinor + taxMinor + serviceChargeMinor;

  /// Preset sample receipts for instant testing without camera hardware.
  static ReceiptData getPresetSample(String presetKey, String tripId) {
    switch (presetKey.toLowerCase()) {
      case 'bistro':
        return ReceiptData(
          tripId: tripId,
          title: 'Blue Tokai Roasters',
          currency: 'INR',
          taxMinor: 7550,
          serviceChargeMinor: 12000,
          payerMemberId: 'm1',
          items: [
            ReceiptItem(label: 'Avocado Sourdough Toast', priceMinor: 45000, quantity: 1, confidence: 0.99),
            ReceiptItem(label: 'Iced Cold Brew (x2)', priceMinor: 44000, quantity: 2, confidence: 0.98),
            ReceiptItem(label: 'Parmesan Truffle Fries', priceMinor: 38000, quantity: 1, confidence: 0.97),
            ReceiptItem(label: 'Almond Croissant', priceMinor: 24000, quantity: 1, confidence: 0.96),
          ],
        );
      case 'pizza':
        return ReceiptData(
          tripId: tripId,
          title: "Leo's Artisan Pizzeria",
          currency: 'INR',
          taxMinor: 8700,
          serviceChargeMinor: 17400,
          payerMemberId: 'm1',
          items: [
            ReceiptItem(label: 'Margherita D.O.P.', priceMinor: 55000, quantity: 1, confidence: 0.99),
            ReceiptItem(label: 'Spicy Pepperoni Pizza', priceMinor: 65000, quantity: 1, confidence: 0.99),
            ReceiptItem(label: 'Garlic Butter Crust Bites', priceMinor: 22000, quantity: 1, confidence: 0.95),
            ReceiptItem(label: 'Classic Tiramisu', priceMinor: 32000, quantity: 1, confidence: 0.97),
          ],
        );
      case 'goa':
      default:
        return ReceiptData(
          tripId: tripId,
          title: 'Thalassa Sunset Shack',
          currency: 'INR',
          taxMinor: 9600,
          serviceChargeMinor: 19000,
          payerMemberId: 'm1',
          items: [
            ReceiptItem(label: 'Butter Chicken', priceMinor: 60000, quantity: 1, confidence: 0.98),
            ReceiptItem(label: 'Garlic Naan (x2)', priceMinor: 16000, quantity: 2, confidence: 0.96),
            ReceiptItem(label: 'Kingfisher Ultra (x3)', priceMinor: 75000, quantity: 3, confidence: 0.99),
            ReceiptItem(label: 'Paneer Tikka', priceMinor: 42000, quantity: 1, confidence: 0.97),
            ReceiptItem(label: 'Masala Papad', priceMinor: 19000, quantity: 1, confidence: 0.95),
          ],
        );
    }
  }
}
