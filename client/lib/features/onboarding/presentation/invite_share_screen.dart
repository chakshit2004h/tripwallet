import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class InviteShareScreen extends StatelessWidget {
  final String inviteCode;

  const InviteShareScreen({
    super.key,
    this.inviteCode = 'GOA-8X92',
  });

  @override
  Widget build(BuildContext context) {
    final inviteUrl = 'https://tripwallet.app/j/$inviteCode';

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text('Invite Crew', style: AppTypography.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Invite your crew',
                style: AppTypography.display.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Anyone with this link or QR joins instantly.\nNo app install or password required to view.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),

              // High-Contrast QR Code Card
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Visual QR Matrix simulation
                    Expanded(
                      child: CustomPaint(
                        painter: _QrMatrixPainter(),
                        child: Container(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Scan with phone camera or QR scanner',
                style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 24),

              // Copyable Link Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.coral, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        inviteUrl,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.cream,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.coral),
                      tooltip: 'Copy Link',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invite link copied!', style: AppTypography.bodyMedium),
                            backgroundColor: AppColors.card,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // WhatsApp Share Primary Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sharing to WhatsApp: "Join Goa Weekend on TripWallet: $inviteUrl"',
                          style: AppTypography.bodyMedium,
                        ),
                        backgroundColor: AppColors.card,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Share to WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),

              // Enter Dashboard Secondary Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/trip/demo-trip'),
                  child: const Text('Open Trip Dashboard →', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw 3 corner position markers (top-left, top-right, bottom-left)
    final markerSize = size.width * 0.28;

    // Corner helper
    void drawMarker(double x, double y) {
      // Outer rect
      canvas.drawRect(Rect.fromLTWH(x, y, markerSize, markerSize), paint);
      // Inner white
      canvas.drawRect(
        Rect.fromLTWH(x + markerSize * 0.16, y + markerSize * 0.16, markerSize * 0.68, markerSize * 0.68),
        Paint()..color = Colors.white,
      );
      // Center solid
      canvas.drawRect(
        Rect.fromLTWH(x + markerSize * 0.32, y + markerSize * 0.32, markerSize * 0.36, markerSize * 0.36),
        paint,
      );
    }

    drawMarker(0, 0);
    drawMarker(size.width - markerSize, 0);
    drawMarker(0, size.height - markerSize);

    // Decorative simulated data dots in grid
    final dotSize = size.width / 16;
    for (int r = 0; r < 14; r++) {
      for (int c = 0; c < 14; c++) {
        // Skip marker areas
        if ((r < 5 && c < 5) || (r < 5 && c > 8) || (r > 8 && c < 5)) continue;
        if ((r * 7 + c * 13) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * dotSize + size.width * 0.06, r * dotSize + size.height * 0.06, dotSize * 0.85, dotSize * 0.85),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
