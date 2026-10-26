import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/domain/money.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';

typedef _ActivityEvent = ({
  String tripId,
  DateTime date,
  String title,
  String subtitle,
  IconData icon,
});

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(ledgerProvider).asData?.value;
    final events = <_ActivityEvent>[
      for (final expense in data?.expenses ?? [])
        (
          tripId: expense.tripId,
          date: expense.createdAt,
          title: expense.title,
          subtitle:
              '${data!.memberName(expense.paidByMemberId)} paid ${formatMoney(expense.amountMinor, expense.currency)}',
          icon: Icons.receipt_long_outlined,
        ),
      for (final payment in data?.settlements ?? [])
        (
          tripId: payment.tripId,
          date: payment.createdAt,
          title: 'Payment recorded',
          subtitle:
              '${data!.memberName(payment.fromMemberId)} paid ${data.memberName(payment.toMemberId)} ${formatMoney(payment.amountMinor, payment.currency)}',
          icon: Icons.payments_outlined,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final tripNames = {
      for (final trip in data?.trips ?? []) trip.id: trip.name,
    };
    final byTrip = <String, List<_ActivityEvent>>{
      for (final id in tripNames.keys) id: [],
    };
    for (final event in events) {
      (byTrip[event.tripId] ??= []).add(event);
    }
    final grouped = byTrip.length > 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              grouped ? 'Activity by trip' : 'The latest from your trips.',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 24),
            if (grouped)
              for (final group in byTrip.entries)
                _TripActivitySection(
                  key: ValueKey('activity-trip-${group.key}'),
                  name: tripNames[group.key] ?? 'Other trip',
                  events: group.value,
                )
            else if (events.isEmpty)
              const EmptyState(
                icon: Icons.bolt_outlined,
                title: 'A fresh start',
                message:
                    'Shared expenses and recorded payments will appear here.',
              )
            else
              ...events.map((event) => _ActivityCard(event: event)),
          ],
        ),
      ),
    );
  }
}

class _TripActivitySection extends StatelessWidget {
  final String name;
  final List<_ActivityEvent> events;
  const _TripActivitySection({
    super.key,
    required this.name,
    required this.events,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.luggage_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(name, style: AppTypography.titleMedium),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${events.length} ${events.length == 1 ? 'update' : 'updates'}',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No activity yet'),
              subtitle: Text(
                'Expenses and payments for this trip will appear here.',
              ),
            ),
          )
        else
          ...events.map((event) => _ActivityCard(event: event)),
      ],
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  final _ActivityEvent event;
  const _ActivityCard({required this.event});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(event.icon),
      title: Text(event.title),
      subtitle: Text(
        '${event.subtitle}\n${DateFormat('d MMM, h:mm a').format(event.date.toLocal())}',
      ),
      isThreeLine: true,
    ),
  );
}
