import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class EarthquakeStatsCard extends StatefulWidget {
  final Map<String, dynamic> stats;

  const EarthquakeStatsCard({super.key, required this.stats});

  @override
  State<EarthquakeStatsCard> createState() => _EarthquakeStatsCardState();
}

class _EarthquakeStatsCardState extends State<EarthquakeStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.statistics,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),

                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.list_alt,
                              label: l10n.total,
                              value: widget.stats['total'].toString(),
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.trending_up,
                              label: l10n.maxMagnitude,
                              value: (widget.stats['maxMagnitude'] as double)
                                  .toStringAsFixed(1),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.trending_down,
                              label: l10n.minMagnitude,
                              value: (widget.stats['minMagnitude'] as double)
                                  .toStringAsFixed(1),
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.analytics,
                              label: l10n.average,
                              value:
                                  (widget.stats['averageMagnitude'] as double)
                                      .toStringAsFixed(1),
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
