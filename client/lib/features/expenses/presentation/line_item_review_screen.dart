import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/receipt_models.dart';
import 'item_claim_screen.dart';

class LineItemReviewScreen extends StatefulWidget {
  final ReceiptData receipt;

  const LineItemReviewScreen({
    super.key,
    required this.receipt,
  });

  @override
  State<LineItemReviewScreen> createState() => _LineItemReviewScreenState();
}

class _LineItemReviewScreenState extends State<LineItemReviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _taxController;
  late TextEditingController _serviceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.receipt.title);
    _taxController = TextEditingController(
      text: (widget.receipt.taxMinor / 100).toStringAsFixed(2),
    );
    _serviceController = TextEditingController(
      text: (widget.receipt.serviceChargeMinor / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _taxController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      widget.receipt.items.add(
        ReceiptItem(
          label: 'New Item',
          priceMinor: 10000, // ₹100.00
          quantity: 1,
          confidence: 1.0,
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (widget.receipt.items.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item is required')),
      );
      return;
    }
    setState(() {
      widget.receipt.items.removeAt(index);
    });
  }

  void _onContinue() {
    widget.receipt.title = _titleController.text.trim();
    final taxVal = double.tryParse(_taxController.text.trim()) ?? 0.0;
    widget.receipt.taxMinor = (taxVal * 100).round();
    final serviceVal = double.tryParse(_serviceController.text.trim()) ?? 0.0;
    widget.receipt.serviceChargeMinor = (serviceVal * 100).round();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemClaimScreen(receipt: widget.receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.receipt.subtotalMinor;
    final taxVal = (double.tryParse(_taxController.text.trim()) ?? 0.0) * 100;
    final serviceVal = (double.tryParse(_serviceController.text.trim()) ?? 0.0) * 100;
    final grandTotal = subtotal + taxVal.round() + serviceVal.round();

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        title: Text('Review Scanned Items', style: AppTypography.titleMedium),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  '98% OCR Match',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expense Title', style: AppTypography.caption),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        style: AppTypography.titleMedium,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Line Items Header
                Row(
                  children: [
                    Text('Line Items (${widget.receipt.items.length})', style: AppTypography.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.coral),
                      label: Text('Add Item', style: AppTypography.caption.copyWith(color: AppColors.coral, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items list
                ...widget.receipt.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildItemRow(item, index);
                }),

                const SizedBox(height: 20),

                // Taxes & Service Charge Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items Subtotal', style: AppTypography.bodyMedium),
                          Text('₹${(subtotal / 100).toStringAsFixed(2)}', style: AppTypography.titleMedium),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.line),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Tax (GST / VAT)', style: AppTypography.bodyMedium),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _taxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Service Charge / Tip', style: AppTypography.bodyMedium),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _serviceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.line),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Receipt Total', style: AppTypography.titleMedium),
                          Text(
                            '₹${(grandTotal / 100).toStringAsFixed(2)}',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.coral,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.paper,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue to Item Claiming', style: AppTypography.button),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(ReceiptItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: item.label,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => item.label = val,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: (item.priceMinor / 100).toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '₹',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                final num = double.tryParse(val) ?? 0.0;
                setState(() {
                  item.priceMinor = (num * 100).round();
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.creamSoft),
            onPressed: () => _removeItem(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
