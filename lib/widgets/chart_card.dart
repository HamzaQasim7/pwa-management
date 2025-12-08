import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.trailing,
  });

  final String title;
  final Widget chart;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final chartHeight = ResponsiveLayout.value<double>(
      context: context,
      mobile: 180.0,
      tablet: 220.0,
      desktop: 260.0,
    );

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      elevation: context.isDesktop ? 1 : 0,
      child: Padding(
        padding: ResponsiveLayout.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ResponsiveTextStyles.headlineSmall(context),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: ResponsiveLayout.spacing(context)),
            SizedBox(height: chartHeight, child: chart),
          ],
        ),
      ),
    );
  }
}

class PieChartSection extends PieChartSectionData {
  PieChartSection({
    required super.value,
    required super.color,
    required super.title,
  }) : super(radius: 60, titleStyle: const TextStyle(color: Colors.white));
}
