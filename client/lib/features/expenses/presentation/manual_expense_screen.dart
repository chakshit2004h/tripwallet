import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/db/app_database.dart';
import '../../../core/domain/money.dart';
import '../../../core/domain/expense_members.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';

class ManualExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ManualExpenseScreen({super.key, required this.tripId});
  @override
  ConsumerState<ManualExpenseScreen> createState() =>
      _ManualExpenseScreenState();
}

class _ManualExpenseScreenState extends ConsumerState<ManualExpenseScreen> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _values = <String, TextEditingController>{};
  final _excluded = <String>{};
  String? _payer;
  String _method = 'equal';
  String _category = 'other';
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    for (final c in _values.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> _exactShares(LocalTrip trip, List<LocalMember> members) {
    final participants = members
        .where((m) => !_excluded.contains(m.id))
        .toList();
    return splitWithFixedShares(
      parseMinor(_amount.text, trip.baseCurrency),
      participants.map((m) => m.id),
      {
        for (final member in participants)
          if ((_values[member.id]?.text.trim() ?? '').isNotEmpty)
            member.id: parseMinor(
              _values[member.id]!.text,
              trip.baseCurrency,
              allowZero: true,
            ),
      },
    );
  }

  Future<void> _save(
    LocalTrip trip,
    List<LocalMember> members,
    String payer,
  ) async {
    if (_busy) return;
    try {
      final amount = parseMinor(_amount.text, trip.baseCurrency);
      final participants = members
          .where((m) => !_excluded.contains(m.id))
          .toList();
      if (participants.isEmpty) {
        throw const FormatException(
          'Choose at least one person to split with.',
        );
      }
      Map<String, int> splits;
      if (_method == 'equal') {
        splits = splitEqually(amount, participants.map((m) => m.id));
      } else if (_method == 'exact') {
        splits = _exactShares(trip, members);
      } else {
        final weights = {
          for (final m in participants)
            m.id: parseMinor(_values[m.id]?.text ?? '', 'INR', allowZero: true),
        };
        if (weights.values.fold(0, (a, b) => a + b) != 10000) {
          throw const FormatException('Percentages must add up to 100%.');
        }
        splits = splitByWeights(amount, weights);
      }
      setState(() {
        _busy = true;
        _error = null;
      });
      await ref
          .read(tripRepositoryProvider)
          .saveExpense(
            tripId: trip.id,
            title: _title.text,
            amountMinor: amount,
            payerId: payer,
            splits: splits,
            category: _category,
            splitMethod: _method,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = appError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(ledgerProvider).asData?.value;
    final trip = data?.trips.where((t) => t.id == widget.tripId).firstOrNull;
    final members =
        data?.members
            .where((m) => m.tripId == widget.tripId && canShareNewExpense(m))
            .toList() ??
        <LocalMember>[];
    final payer =
        _payer ??
        data?.myMemberId(widget.tripId, ref.watch(accountIdProvider) ?? '') ??
        members.firstOrNull?.id;
    Map<String, int> automaticShares = {};
    String? splitError;
    if (_method == 'exact' && trip != null && _amount.text.trim().isNotEmpty) {
      try {
        automaticShares = _exactShares(trip, members);
      } on FormatException catch (e) {
        splitError = e.message;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Add an expense')),
      body: trip == null || members.isEmpty
          ? const EmptyState(
              icon: Icons.sync_problem,
              title: 'Load your trip first',
              message: 'Connect and refresh your trip to load its members.',
            )
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'What did you pay for?',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _title,
                    maxLength: 120,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Expense name',
                      hintText: 'Dinner, taxi, a place to stay…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const ValueKey('expense-amount'),
                    controller: _amount,
                    onChanged: (_) => setState(() => _error = null),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '${currencySymbol(trip.baseCurrency)} ',
                      suffixText: trip.baseCurrency,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: payer,
                    decoration: const InputDecoration(labelText: 'Paid by'),
                    items: members
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _payer = v),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items:
                        [
                              'food',
                              'stay',
                              'transport',
                              'activity',
                              'shopping',
                              'other',
                            ]
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c[0].toUpperCase() + c.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'How should we split it?',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'equal', label: Text('Equally')),
                      ButtonSegment(value: 'exact', label: Text('Exact')),
                      ButtonSegment(
                        value: 'percentage',
                        label: Text('Percent'),
                      ),
                    ],
                    selected: {_method},
                    onSelectionChanged: (v) => setState(() {
                      _method = v.first;
                      _error = null;
                      for (final c in _values.values) {
                        c.clear();
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  if (_method == 'exact')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Enter anyone’s share. The rest is split equally among people marked Auto. Clear an entered share to make it automatic again.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ...members.map(
                    (m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Checkbox(
                            key: ValueKey('include-${m.id}'),
                            value: !_excluded.contains(m.id),
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _excluded.remove(m.id);
                              } else {
                                _excluded.add(m.id);
                                _values[m.id]?.clear();
                              }
                              _error = null;
                            }),
                          ),
                          Expanded(
                            child: Text(
                              m.displayName,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          if (_method != 'equal' && !_excluded.contains(m.id))
                            SizedBox(
                              width: 145,
                              child: TextField(
                                key: ValueKey('share-${m.id}'),
                                onChanged: (_) => setState(() => _error = null),
                                controller: _values.putIfAbsent(
                                  m.id,
                                  () => TextEditingController(),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  floatingLabelBehavior: _method == 'exact'
                                      ? FloatingLabelBehavior.always
                                      : FloatingLabelBehavior.auto,
                                  labelText: _method == 'percentage'
                                      ? 'Share %'
                                      : trip.baseCurrency,
                                  hintText:
                                      _method == 'exact' &&
                                          automaticShares.containsKey(m.id)
                                      ? decimalAmount(
                                          automaticShares[m.id]!,
                                          trip.baseCurrency,
                                        )
                                      : null,
                                  hintStyle: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  helperText: _method == 'exact'
                                      ? ((_values[m.id]?.text.trim().isEmpty ??
                                                true)
                                            ? 'Auto'
                                            : 'Entered')
                                      : null,
                                  suffixIcon:
                                      _method == 'exact' &&
                                          (_values[m.id]?.text.isNotEmpty ??
                                              false)
                                      ? IconButton(
                                          tooltip:
                                              'Auto-calculate ${m.displayName}’s share',
                                          icon: const Icon(Icons.restart_alt),
                                          onPressed: () => setState(() {
                                            _values[m.id]?.clear();
                                            _error = null;
                                          }),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (splitError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        splitError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _busy || payer == null || splitError != null
                        ? null
                        : () => _save(trip, members, payer),
                    child: Text(_busy ? 'Saving…' : 'Save expense'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saved on this device immediately. Shared with your crew when connected.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
