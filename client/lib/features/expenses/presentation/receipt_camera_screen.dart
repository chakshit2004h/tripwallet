import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/receipt_models.dart';
import 'line_item_review_screen.dart';

class ReceiptCameraScreen extends StatefulWidget {
  final String tripId;

  const ReceiptCameraScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<ReceiptCameraScreen> createState() => _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends State<ReceiptCameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _onSelectPreset(String presetKey) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final receipt = ReceiptData.getPresetSample(presetKey, widget.tripId);
    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LineItemReviewScreen(receipt: receipt),
      ),
    );
  }

  void _onCapture() {
    _onSelectPreset('goa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Scan Receipt', style: AppTypography.titleMedium.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isFlashOn ? AppColors.yellow : Colors.white70,
            ),
            onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Viewfinder background simulation
          Positioned.fill(
            child: Container(
              color: const Color(0xFF111417),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color: AppColors.line.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Align receipt inside the frame',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Viewfinder Frame Overlay
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.coral.withOpacity(0.6), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _scanAnimationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimationController.value *
                            (MediaQuery.of(context).size.height * 0.55 - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.coral.withOpacity(0.9),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coral.withOpacity(0.7),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Corner Accents
                  _buildCornerAccent(top: 0, left: 0),
                  _buildCornerAccent(top: 0, right: 0),
                  _buildCornerAccent(bottom: 0, left: 0),
                  _buildCornerAccent(bottom: 0, right: 0),
                ],
              ),
            ),
          ),

          // Processing Indicator
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.coral),
                      const SizedBox(height: 16),
                      Text(
                        'Parsing line items with OCR...',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Controls & Quick Presets
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                    Colors.black,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Presets bar for instant frictionless testing
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.paper.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.yellow, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Instant Test Receipts:',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.cream,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPresetChip('🌴 Goa Shack', () => _onSelectPreset('goa')),
                            const SizedBox(width: 8),
                            _buildPresetChip('☕ Bistro', () => _onSelectPreset('bistro')),
                            const SizedBox(width: 8),
                            _buildPresetChip('🍕 Pizzeria', () => _onSelectPreset('pizza')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Shutter and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library_rounded, color: Colors.white70, size: 28),
                        onPressed: () => _onSelectPreset('bistro'),
                      ),

                      // Shutter button
                      GestureDetector(
                        onTap: _onCapture,
                        child: Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.coral,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.text_snippet_rounded, color: Colors.white70, size: 28),
                        onPressed: () => _onSelectPreset('pizza'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerAccent({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: AppColors.coral, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: AppColors.coral, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: AppColors.coral, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: AppColors.coral, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
