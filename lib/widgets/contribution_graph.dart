import 'package:flutter/material.dart';

class ContributionGraph extends StatelessWidget {
  final Map<DateTime, int> contributionCounts;
  final DateTime endDate;

  const ContributionGraph({
    super.key,
    required this.contributionCounts,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // Start date is 364 days ago to include today as the 365th day
    final startDate = endDate.subtract(const Duration(days: 364));
    
    // Find the Sunday of the week containing the startDate
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    // We want Sunday to be the first day of the week (dayIndex 0)
    int daysToSubtract = startDate.weekday % 7;
    final firstDisplayDate = startDate.subtract(Duration(days: daysToSubtract));
    
    // Total days from firstDisplayDate to endDate
    final totalDays = endDate.difference(firstDisplayDate).inDays + 1;
    final weeksToShow = (totalDays / 7).ceil();
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Activity Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        Container(
          height: 185,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20), // Month labels + gap
                        ...['', 'Mon', '', 'Wed', '', 'Fri', ''].map(
                          (day) => SizedBox(
                            height: 14,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Start from the right (today)
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                              child: Row(
                                children: List.generate(weeksToShow, (weekIndex) {
                                  final weekStart = firstDisplayDate.add(
                                    Duration(days: weekIndex * 7),
                                  );
                                  bool showMonth = false;
                                  if (weekIndex == 0) {
                                    showMonth = true;
                                  } else {
                                    final prevWeekStart = firstDisplayDate.add(
                                      Duration(days: (weekIndex - 1) * 7),
                                    );
                                    if (weekStart.month != prevWeekStart.month) {
                                      showMonth = true;
                                    }
                                  }

                                  return SizedBox(
                                    width: 14,
                                    height: 16,
                                    child: showMonth
                                        ? OverflowBox(
                                            alignment: Alignment.bottomLeft,
                                            maxWidth: 40,
                                            maxHeight: 16,
                                            child: Text(
                                              monthNames[weekStart.month - 1],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(weeksToShow, (weekIndex) {
                                return Column(
                                  children: List.generate(7, (dayIndex) {
                                    final currentDay = firstDisplayDate.add(
                                      Duration(days: weekIndex * 7 + dayIndex),
                                    );

                                    if (currentDay.isAfter(endDate)) {
                                      return _buildEmptyBox(
                                        const Color(0xFF374151),
                                      );
                                    }

                                    if (currentDay.isBefore(startDate)) {
                                      return _buildEmptyBox(
                                        const Color(0xFF374151),
                                      );
                                    }

                                    final dateKey = DateTime(
                                      currentDay.year,
                                      currentDay.month,
                                      currentDay.day,
                                    );
                                    final count =
                                        contributionCounts[dateKey] ?? 0;

                                    // Week gradient: Red (0) to Purple (270)
                                    // weekIndex 0 is 1 year ago, weekIndex weeksToShow-1 is today.
                                    final hue =
                                        (weekIndex / (weeksToShow - 1)) * 270.0;
                                    final baseColor =
                                        HSVColor.fromAHSV(1.0, hue, 0.7, 1.0)
                                            .toColor();

                                    return _buildContributionBox(
                                      count,
                                      baseColor,
                                      currentDay,
                                    );
                                  }),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 4),
                  _buildLegendBox(const Color(0xFF6B7280)),
                  _buildLegendBox(const Color(0xFF6366F1).withValues(alpha:0.35)),
                  _buildLegendBox(const Color(0xFF6366F1).withValues(alpha:0.6)),
                  _buildLegendBox(const Color(0xFF6366F1)),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContributionBox(int count, Color baseColor, DateTime date) {
    Color color;
    if (count == 0) {
      color = const Color(0xFF6B7280);
    } else {
      // Scale: 1, 2-3, 4-6, 7+
      double opacity;
      if (count >= 7) {
        opacity = 1.0;
      } else if (count >= 4) {
        opacity = 0.8;
      } else if (count >= 2) {
        opacity = 0.55;
      } else {
        opacity = 0.35;
      }
      color = baseColor.withValues(alpha:opacity);
    }

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${monthNames[date.month - 1]} ${date.day}';
    final message = '$count contribution${count == 1 ? '' : 's'} for $dateStr';

    return Tooltip(
      message: message,
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
