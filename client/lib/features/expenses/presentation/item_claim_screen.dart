import 'package:flutter/material.dart';
import '../../../core/domain/proration_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/receipt_models.dart';
import 'split_confirm_screen.dart';

class MemberProfile {
  final String id;
  final String name;
  final String initial;
  final Color color;

  const MemberProfile({
    required this.id,
    required this.name,
    required this.initial,
    required this.color,
  });
}

class ItemClaimScreen extends StatefulWidget {
  final ReceiptData receipt;

  const ItemClaimScreen({
    super.key,
    required this.receipt,
  });

  @override
  State<ItemClaimScreen> createState() => _ItemClaimScreenState();
}

class _ItemClaimScreenState extends State<ItemClaimScreen> {
  final List<MemberProfile> _members = const [
    MemberProfile(id: 'm1', name: 'You', initial: 'Y', color: AppColors.coral),
    MemberProfile(id: 'm2', name: 'Rahul', initial: 'R', color: AppColors.teal),
    MemberProfile(id: 'm3', name: 'Priya', initial: 'P', color: AppColors.yellow),
    MemberProfile(id: 'm4', name: 'Amit', initial: 'A', color: AppColors.green),
  ];

  late String _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _selectedMemberId = _members.first.id;

    // By default, if no items are claimed yet, claim the first item for "You"
    if (widget.receipt.items.every((i) => i.claimedMemberIds.isEmpty)) {
      widget.receipt.items.first.claimedMemberIds.add(_selectedMemberId);
    }
  }

  void _toggleClaim(ReceiptItem item) {
    setState(() {
      if (item.claimedMemberIds.contains(_selectedMemberId)) {
        item.claimedMemberIds.remove(_selectedMemberId);
      } else {
        item.claimedMemberIds.add(_selectedMemberId);
      }
    });
  }

  Map<String, int> _computeMemberSubtotals() {
    final subtotals = <String, int>{};
    for (final member in _members) {
      subtotals[member.id] = 0;
    }

    for (final item in widget.receipt.items) {
      if (item.claimedMemberIds.isNotEmpty) {
        final splitCount = item.claimedMemberIds.length;
        final perMemberShare = item.priceMinor ~/ splitCount;
        final remainder = item.priceMinor % splitCount;

        var i = 0;
        for (final memberId in item.claimedMemberIds) {
          final extra = (i == 0) ? remainder : 0;
          subtotals[memberId] = (subtotals[memberId] ?? 0) + perMemberShare + extra;
          i++;
        }
      }
    }
    return subtotals;
  }

  @override
  Widget build(BuildContext context) {
    final subtotals = _computeMemberSubtotals();
    final allocations = prorateReceipt(
      payerId: widget.receipt.payerMemberId,
      memberSubtotals: subtotals,
      totalTaxMinor: widget.receipt.taxMinor,
      totalServiceChargeMinor: widget.receipt.serviceChargeMinor,
    );

    final currentMember = _members.firstWhere((m) => m.id == _selectedMemberId);
    final currentAlloc = allocations[_selectedMemberId];
    final activeMemberTotal = currentAlloc?.totalMinor ?? 0;
    final activeMemberSub = currentAlloc?.subtotalMinor ?? 0;
    final activeMemberTax = currentAlloc?.taxMinor ?? 0;
    final activeMemberService = currentAlloc?.serviceChargeMinor ?? 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Claim Your Dishes', style: AppTypography.titleMedium),
            Text(
              widget.receipt.title,
              style: AppTypography.caption.copyWith(color: AppColors.creamSoft),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Member Selector Carousel
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.paper,
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'SELECTING FOR:',
                    style: AppTypography.caption.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _members.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final isSelected = member.id == _selectedMemberId;
                      final memberSub = subtotals[member.id] ?? 0;
                      return ChoiceChip(
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedMemberId = member.id),
                        selectedColor: member.color.withOpacity(0.2),
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(
                            color: isSelected ? member.color : AppColors.line,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        avatar: CircleAvatar(
                          backgroundColor: member.color,
                          child: Text(
                            member.initial,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        label: Text(
                          '${member.name} (₹${(memberSub / 100).toStringAsFixed(0)})',
                          style: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.cream : AppColors.creamSoft,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Dishes Checklist
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: widget.receipt.items.length,
              itemBuilder: (context, index) {
                final item = widget.receipt.items[index];
                final isClaimedByActive = item.claimedMemberIds.contains(_selectedMemberId);
                final claimCount = item.claimedMemberIds.length;

                return GestureDetector(
                  onTap: () => _toggleClaim(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isClaimedByActive
                          ? currentMember.color.withOpacity(0.08)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isClaimedByActive
                            ? currentMember.color
                            : AppColors.line,
                        width: isClaimedByActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Checkbox indicator
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isClaimedByActive
                                ? currentMember.color
                                : Colors.transparent,
                            border: Border.all(
                              color: isClaimedByActive
                                  ? currentMember.color
                                  : AppColors.creamSoft,
                              width: 2,
                            ),
                          ),
                          child: isClaimedByActive
                              ? const Icon(Icons.check, size: 18, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 14),

                        // Title and quantity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.label, style: AppTypography.bodyMedium),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (claimCount > 1) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Split $claimCount ways · ₹${((item.priceMinor ~/ claimCount) / 100).toStringAsFixed(0)} ea',
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 10,
                                          color: AppColors.yellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Display avatar dots of all claimers
                                  ...item.claimedMemberIds.map((mid) {
                                    final m = _members.firstWhere((mem) => mem.id == mid);
                                    return Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      child: CircleAvatar(
                                        radius: 8,
                                        backgroundColor: m.color,
                                        child: Text(
                                          m.initial,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(item.priceMinor / 100).toStringAsFixed(2)}',
                              style: AppTypography.titleMedium.copyWith(fontSize: 16),
                            ),
                            if (claimCount == 0)
                              Text(
                                'Unclaimed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.creamSoft,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Live Proration Sticky Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(top: BorderSide(color: AppColors.line, width: 1.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live integer breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: currentMember.color,
                          child: Text(
                            currentMember.initial,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${currentMember.name}\'s Share:',
                          style: AppTypography.titleMedium.copyWith(fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      '₹${(activeMemberTotal / 100).toStringAsFixed(2)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items ₹${(activeMemberSub / 100).toStringAsFixed(0)}  ·  Tax +₹${(activeMemberTax / 100).toStringAsFixed(0)}  ·  Service +₹${(activeMemberService / 100).toStringAsFixed(0)}',
                      style: AppTypography.caption.copyWith(color: AppColors.creamSoft),
                    ),
                    Text(
                      'Zero-cent exact',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Review Split Details CTA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SplitConfirmScreen(
                            receipt: widget.receipt,
                            members: _members,
                            allocations: allocations,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Review Split Details', style: AppTypography.button),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
