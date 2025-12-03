// lib/screens/admin/reports_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../providers/admin_provider_web.dart';

import '../../routes/app_routes.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();
    final themeProvider = context.watch<ThemeProvider>();
    final backgroundColor = themeProvider.backgroundColor;

    return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          backgroundColor: themeProvider.cardColor,
          foregroundColor: themeProvider.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Reports & Analytics'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            
            // Summary Cards
            _buildSummaryCards(context, themeProvider),
            const SizedBox(height: 24),
            
            // Monthly Performance Chart
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Performance',
                      style: themeProvider.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  switch (value.toInt()) {
                                    case 0: text = 'Jan'; break;
                                    case 1: text = 'Feb'; break;
                                    case 2: text = 'Mar'; break;
                                    case 3: text = 'Apr'; break;
                                    case 4: text = 'May'; break;
                                    case 5: text = 'Jun'; break;
                                  }
                                  return Text(
                                    text,
                                    style: TextStyle(
                                      color: themeProvider.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: themeProvider.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 35),
                                FlSpot(1, 28),
                                FlSpot(2, 42),
                                FlSpot(3, 38),
                                FlSpot(4, 45),
                                FlSpot(5, 51),
                              ],
                              isCurved: true,
                              color: themeProvider.primaryColor,
                              barWidth: 4,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: themeProvider.primaryColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Reports
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Reports',
                      style: themeProvider.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildReportList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ThemeProvider themeProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _SummaryCard(
          title: 'Total Revenue',
          value: '\$24,532',
          icon: Icons.attach_money,
          color: Colors.green,
          onTap: () {},
        ),
        _SummaryCard(
          title: 'Active Users',
          value: '1,248',
          icon: Icons.people,
          color: themeProvider.primaryColor,
          onTap: () {},
        ),
        _SummaryCard(
          title: 'Completed Jobs',
          value: '342',
          icon: Icons.check_circle,
          color: Colors.blue,
          onTap: () {},
        ),
        _SummaryCard(
          title: 'Pending Actions',
          value: '12',
          icon: Icons.notifications_active,
          color: Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildReportList() {
    final reports = [
      _ReportItem('Monthly Financial Report', 'May 2023', Icons.picture_as_pdf),
      _ReportItem('User Activity Summary', 'Last 30 days', Icons.bar_chart),
      _ReportItem('Service Performance', 'Q2 2023', Icons.assessment),
      _ReportItem('Customer Feedback', 'April 2023', Icons.feedback),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ListTile(
          leading: Icon(report.icon, color: Colors.grey[600]),
          title: Text(report.title),
          subtitle: Text(report.date),
          trailing: const Icon(Icons.download),
          onTap: () {
            // Handle report download
          },
        );
      },
    );
  }
}

class _ReportItem {
  final String title;
  final String date;
  final IconData icon;

  _ReportItem(this.title, this.date, this.icon);
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}