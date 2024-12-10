import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'config.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  bool loading = true;
  Map<String, dynamic>? data;
  bool showMoreVideos = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(Config.graphData));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          loading = false;
        });
      } else {
        showError('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFFC5EDFE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null || data!['videoScores'] == null) {
      return Scaffold(
        backgroundColor: Color(0xFFC5EDFE),
        body: Center(child: Text('No data available')),
      );
    }

    final videoScores = data!['videoScores'] as Map<String, dynamic>;

    // Sort video scores in descending order
    final sortedVideoScores = Map.fromEntries(
      videoScores.entries.toList()
        ..sort((e1, e2) => e2.value.compareTo(e1.value)),
    );

    return Scaffold(
      backgroundColor: Color(0xFFC5EDFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC5EDFE),
        elevation: 0,  // To remove the default shadow below the AppBar
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Adjust the back button position
          child: IconButton(
            icon: Image.asset('assets/backarrow.png'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0), // Adjusted top padding to make room for the title
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBestVideoPerformance(),
              _buildChart(sortedVideoScores),
              if (data!['bestVideoTitles'] != null &&
                  data!['bestVideoTitles'].isNotEmpty)
                _buildBestVideos(data!['bestVideoTitles']),
              if (showMoreVideos && sortedVideoScores.isNotEmpty)
                _buildVideoScores(sortedVideoScores),
              if (sortedVideoScores.isNotEmpty)
                _buildSeeMoreButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestVideoPerformance() {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: _boxDecoration(),
      child: Text(
        'Best Video Performance',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChart(Map<String, dynamic> videoScores) {
    final chartData = videoScores.values.map((e) {
      final value = double.tryParse(e.toString());
      return value != null && value.isFinite ? value : 0.0;
    }).toList();

    final labels = videoScores.keys.toList();

    return Container(
      height: 300,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: _boxDecoration(),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (value, meta) {
                  final label = labels[value.toInt()];
                  return Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
          ),
          borderData: FlBorderData(show: true),
          barGroups: chartData
              .asMap()
              .entries
              .map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: Colors.blue,
                width: 16,
              ),
            ],
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildBestVideos(List<dynamic> bestVideoTitles) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: _boxDecoration(),
      child: Text(
        'Best Performing Video(s): ${bestVideoTitles.join(', ')}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVideoScores(Map<String, dynamic> videoScores) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: _boxDecoration(color: Color(0xFFE0F7FA)),
      child: SingleChildScrollView(
        child: Column(
          children: videoScores.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Video ID: ${entry.key}, Score: ${entry.value}',
                style: TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            showMoreVideos = !showMoreVideos;
          });
        },
        child: Text(showMoreVideos ? 'See Less' : 'See More'),
      ),
    );
  }

  BoxDecoration _boxDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 6.0,
          spreadRadius: 2.0,
        ),
      ],
    );
  }
}
