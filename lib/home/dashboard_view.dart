import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/user.dart';
import 'package:adv_basics/model/reservation.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late bool isUsersLoading;
  late bool isReservationsLoading;
  late Map<String, int> userCategoriesCount;
  late List<int> reservationsPerDay;

  @override
  void initState() {
    super.initState();
    isUsersLoading = true;
    isReservationsLoading = true;
    userCategoriesCount = {};
    reservationsPerDay = List.filled(7, 0);
    fetchUsers();
    fetchReservations();
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<User> fetchedUsers =
          snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();

      Map<String, int> categoriesCount = {};
      for (var user in fetchedUsers) {
        categoriesCount[user.category] =
            (categoriesCount[user.category] ?? 0) + 1;
      }

      setState(() {
        userCategoriesCount = categoriesCount;
        isUsersLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isUsersLoading = false;
      });
    }
  }

  Future<void> fetchReservations() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('debut',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfWeek))
          .where('debut',
              isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfWeek))
          .get();

      if (snapshot.docs.isEmpty) {
        print('No reservations found for the current week');
      } else {
        print('Fetched ${snapshot.docs.length} reservations');
      }

      List<Reservation> fetchedReservations = await Future.wait(
          snapshot.docs.map((doc) => Reservation.fromFirestore(doc)));

      Map<int, int> dayCounts = {};
      for (var reservation in fetchedReservations) {
        int weekday = reservation.debut.weekday - 1;
        dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
      }

      for (int i = 0; i < 7; i++) {
        reservationsPerDay[i] = dayCounts[i] ?? 0;
        print('Reservations on day $i: ${reservationsPerDay[i]}');
      }

      setState(() {
        isReservationsLoading = false;
      });
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() {
        isReservationsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: [
          _buildPageContent(
              "User Categories Distribution", _buildUserCategoryPieChart()),
          _buildPageContent(
              "Weekly Reservations", _buildReservationsBarChart()),
          // Add more pages with charts here
        ],
      ),
    );
  }

  Widget _buildPageContent(String title, Widget chartWidget) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          chartWidget,
        ],
      ),
    );
  }

  Widget _buildUserCategoryPieChart() {
    List<PieChartSectionData> sections =
        userCategoriesCount.entries.map((entry) {
      final color = Colors.primaries[
          userCategoriesCount.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '',
        color: color,
        radius: 60,
      );
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 0,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    List<Widget> legendItems = userCategoriesCount.entries.map((entry) {
      final color = Colors.primaries[
          userCategoriesCount.keys.toList().indexOf(entry.key) %
              Colors.primaries.length];
      return ListTile(
        leading: Icon(Icons.circle, color: color),
        title: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();

    return Column(children: legendItems);
  }

  Widget _buildReservationsBarChart() {
    List<BarChartGroupData> barGroups = List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: reservationsPerDay[index].toDouble(),
            color: Theme.of(context).primaryColor,
          ),
        ],
      );
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: reservationsPerDay.reduce(max).toDouble() + 1,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Mon');
                      case 1:
                        return const Text('Tue');
                      case 2:
                        return const Text('Wed');
                      case 3:
                        return const Text('Thu');
                      case 4:
                        return const Text('Fri');
                      case 5:
                        return const Text('Sat');
                      case 6:
                        return const Text('Sun');
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value == value.toInt()) {
                      // Only show integer values
                      return Text('${value.toInt()}');
                    }
                    return const SizedBox.shrink();
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
          ),
        ),
      ),
    );
  }
}
