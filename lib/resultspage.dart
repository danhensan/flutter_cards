// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResultsPage extends StatelessWidget {
  final int playerOneWins;
  final int playerTwoWins;
  final int draws;
  final Function() backAndResetGame;

  ResultsPage(
      {required this.playerOneWins,
      required this.playerTwoWins,
      required this.draws,
      required this.backAndResetGame});

  @override
  Widget build(BuildContext context) {
    final List<_StatisticsData> data = [
      _StatisticsData('PLAYER 1', playerOneWins),
      _StatisticsData('PLAYER 2', playerTwoWins),
      _StatisticsData('DRAWS', draws),
    ];

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff0a6c03),
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('ALMOST BLACKJACK',
              style: TextStyle(fontSize: 21, color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'STATISTICS',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 25),
              SfCartesianChart(
                plotAreaBorderColor: Colors.transparent,
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                series: <ColumnSeries<_StatisticsData, String>>[
                  ColumnSeries<_StatisticsData, String>(
                    dataSource: data,
                    xValueMapper: (_StatisticsData stats, _) => stats.player,
                    yValueMapper: (_StatisticsData stats, _) => stats.wins,
                    dataLabelSettings:
                        DataLabelSettings(isVisible: true, color: Colors.white),
                    color: Colors.red,
                  )
                ],
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  backAndResetGame();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'RETURN AND RESET STATS',
                  style: TextStyle(fontSize: 21, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsData {
  _StatisticsData(this.player, this.wins);

  final String player;
  final int wins;
}
