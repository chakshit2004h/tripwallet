import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/app_error.dart';
import '../../../core/data/trip_repository.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ledger_widgets.dart';
import '../../trips/data/supabase_trips_service.dart';
import '../domain/invite_code.dart';
import 'invite_scanner_screen.dart';

class JoinTripScreen extends ConsumerStatefulWidget {
  final String? tripId;
  final String? initialCode;
  const JoinTripScreen({super.key, this.tripId, this.initialCode});
  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  late final TextEditingController _code = TextEditingController(
    text: widget.initialCode ?? '',
  );
  SupabaseTrip? _preview;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool _scanning = false;

  Future<void> _scan() async {
    if (_busy || _scanning) return;
    FocusScope.of(context).unfocus();
    setState(() => _scanning = true);
    final route = MaterialPageRoute<String>(
      builder: (_) => const InviteScannerScreen(),
    );
    final code = await Navigator.of(context).push<String>(route);
    // Finish closing the camera route before replacing the join page.
    await route.completed;
    if (!mounted) return;
    setState(() => _scanning = false);
    if (code == null) return;
    setState(() {
      _code.text = code;
      _preview = null;
      _error = null;
    });
    await _submit(joinImmediately: true);
  }

  Future<void> _submit({bool joinImmediately = false}) async {
    if (_busy) return;
    final code = inviteCodeFromInput(_code.text);
    if (code == null) {
      setState(() => _error = 'Enter the 6–8 character code from your invite.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = ref.read(supabaseTripsServiceProvider);
      if (_preview == null && !joinImmediately) {
        final trip = await service.fetchTripByInviteCode(code);
        if (mounted) setState(() => _preview = trip);
      } else {
        final trip = await service.joinTripByInviteCode(code);
        try {
          await ref.read(tripRepositoryProvider).sync();
        } catch (_) {}
        if (mounted) context.go('/trip/${trip.id}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = appError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Join your crew')),
    body: ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('You’re invited.', style: AppTypography.display),
          const SizedBox(height: 8),
          Text(
            'Scan your friend’s QR code, paste an invite link, or enter their code.',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _busy || _scanning ? null : _scan,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan QR code'),
          ),
          const SizedBox(height: 24),
          TextField(
            readOnly: _busy || _scanning,
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Invite code or link',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
            onChanged: (_) => setState(() {
              _preview = null;
              _error = null;
            }),
            onSubmitted: (_) => _submit(),
          ),
          if (_preview != null) ...[
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.luggage_outlined),
                title: Text(_preview!.name),
                subtitle: Text('Shared trip · ${_preview!.baseCurrency}'),
              ),
            ),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy || _scanning ? null : () => _submit(),
            child: Text(
              _busy
                  ? 'Connecting…'
                  : _preview == null
                  ? 'Find trip'
                  : 'Join ${_preview!.name}',
            ),
          ),
        ],
      ),
    ),
  );
}
