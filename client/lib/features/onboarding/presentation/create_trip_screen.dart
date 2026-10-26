import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/domain/money.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../trips/data/supabase_trips_service.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});
  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _name = TextEditingController();
  String _currency = 'INR';
  DateTimeRange? _dates;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_busy) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give your trip a name.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final trip = await ref
          .read(supabaseTripsServiceProvider)
          .createTrip(
            name: _name.text.trim(),
            currency: _currency,
            startDate: _dates?.start,
            endDate: _dates?.end,
          );
      // Creation already committed. A refresh failure must not create the trip again.
      try {
        await ref.read(tripRepositoryProvider).sync();
      } catch (_) {}
      if (mounted) {
        context.go('/invite?tripId=${trip.id}&inviteCode=${trip.inviteCode}');
      }
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create a trip')),
    body: ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Where are we going?', style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'One place for your plans, people, and shared expenses.',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _name,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Trip name',
              hintText: 'e.g. A weekend by the sea',
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: const InputDecoration(labelText: 'Trip currency'),
            items: supportedCurrencies
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text('$c  ${currencySymbol(c)}'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _currency = v!),
          ),
          const SizedBox(height: 8),
          Text(
            'All expenses in this trip use this currency.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              _dates == null
                  ? 'Choose dates (optional)'
                  : '${DateFormat('d MMM y').format(_dates!.start)} – ${DateFormat('d MMM y').format(_dates!.end)}',
            ),
            onPressed: () async {
              final dates = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: _dates,
              );
              if (dates != null && mounted) setState(() => _dates = dates);
            },
          ),
          if (_dates != null)
            TextButton(
              onPressed: () => setState(() => _dates = null),
              child: const Text('Clear dates'),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _busy ? null : _create,
            child: Text(
              _busy ? 'Creating your trip…' : 'Create trip & invite friends',
            ),
          ),
        ],
      ),
    ),
  );
}
