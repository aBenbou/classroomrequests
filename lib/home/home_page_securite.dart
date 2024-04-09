import 'package:adv_basics/home/notification_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/notification.dart' as model;
import 'package:adv_basics/tiles/notification_tile.dart';
import 'package:adv_basics/add/add_reclamation.dart';
import 'package:adv_basics/edit/edit_reclamation.dart';
import 'package:adv_basics/edit/profil_view.dart';
import 'package:adv_basics/model/reclamation.dart';
import 'package:adv_basics/tiles/reclamation_tile.dart';
import 'package:adv_basics/home/custom_search_bar.dart';
import 'package:adv_basics/login/login_page.dart';

class SecuriteHomePage extends StatefulWidget {
  final int initialPage;
  final String userId;
  const SecuriteHomePage(
      {super.key, required this.initialPage, required this.userId});

  @override
  State<SecuriteHomePage> createState() {
    return _SecuriteHomePageState();
  }
}

class _SecuriteHomePageState extends State<SecuriteHomePage> {
  late int _selectedIndex = 0;
  String _searchTerm = '';
  final List<String> _appBarTitles = [
    'Notifications',
    'Reclamations',
    'Profil',
    'Logout'
  ];
  List<model.Notification> notifications = [];
  bool isNotificationsLoading = true;
  List<Reclamation> reclamations = [];
  bool isReclamationsLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
    fetchNotifications();
    fetchReclamationsForCurrentUser(widget.userId);
  }

  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.toLowerCase();
    });
  }

  // Generic filter list method
  List<T> _filterList<T>(List<T> list, bool Function(T) filterFunc) {
    if (_searchTerm.isEmpty) return list;
    return list.where(filterFunc).toList();
  }

  Future<void> fetchNotifications() async {
    setState(() => isNotificationsLoading = true);
    try {
      notifications =
          await model.Notification.getPendingNotifications(DateTime.now());
      print(
          "Fetched notifications: ${notifications.length}"); // Print the count of notifications fetched
      setState(() => isNotificationsLoading = false);
    } catch (e) {
      print(
          'Error fetching notifications: $e'); // Print the error if fetching fails
      setState(() => isNotificationsLoading = false);
    }
  }

  Future<void> fetchReclamationsForCurrentUser(String currentUserId) async {
    setState(() => isReclamationsLoading = true);
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);

      QuerySnapshot reclamationSnapshot = await FirebaseFirestore.instance
          .collection('reclamations')
          .where('user', isEqualTo: userRef)
          .get();

      List<Future<Reclamation>> futureReclamations = reclamationSnapshot.docs
          .map((doc) => Reclamation.fromFirestore(doc))
          .toList();
      List<Reclamation> fetchedReclamations =
          await Future.wait(futureReclamations);

      setState(() {
        reclamations = fetchedReclamations;
        isReclamationsLoading = false;
      });
    } catch (e) {
      print('Error fetching reclamations for current user: $e');
      setState(() => isReclamationsLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _appBarTitles.length - 1) {
      _logout();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LogInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(_selectedIndex),
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Widget buildFloatingActionButton() {
    if (_selectedIndex == 1) {
      // Check if we are in the 'Reclamations' tab
      return FloatingActionButton(
        onPressed: () async {
          // Navigate to AddReclamation and wait for the result
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddReclamation()),
          );

          // If the result is 'true', refresh the reclamations list
          if (result == true) {
            refreshReclamations();
          }
        },
        backgroundColor: const Color.fromARGB(255, 28, 78, 173),
        child: const Icon(Icons.add),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.event_seat), label: 'Reservations'),
        BottomNavigationBarItem(
            icon: Icon(Icons.report), label: 'Reclamations'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 28, 78, 173),
      onTap: _onItemTapped,
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return buildNotificationsView();
      case 1:
        return _buildReclamationsView();
      case 2:
        return _buildAccountView();
      default:
        return buildNotificationsView();
    }
  }

  Widget buildNotificationsView() {
    if (isNotificationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<model.Notification> filteredNotifications = _filterList(
      notifications,
      (model.Notification notification) {
        // Example filtering logic, adjust as needed
        String reservationDetails =
            notification.reservation.salleDetails.toLowerCase();
        return reservationDetails.contains(_searchTerm);
      },
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(_appBarTitles[0]),
          floating: true,
          snap: true,
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: CustomSearchBar(onSearchChanged: _onSearchChanged)),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int index) {
              // Get the current notification
              model.Notification notification = filteredNotifications[index];

              return NotificationTile(
                notification: notification,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NotificationView(
                        notification: notification,
                        onNotificationStatusChanged: refreshNotifications,
                      ),
                    ),
                  );
                },
              );
            },
            childCount: filteredNotifications.length,
          ),
        ),
      ],
    );
  }

  Widget _buildReclamationsView() {
    if (isReclamationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filtering logic here
    List<Reclamation> filteredReclamations = _filterList(
      reclamations,
      (Reclamation r) =>
          r.description.toLowerCase().contains(_searchTerm) ||
          r.reservation.salleDetails.toLowerCase().contains(_searchTerm) ||
          r.user.nom.toLowerCase().contains(_searchTerm) ||
          r.user.prenom.toLowerCase().contains(_searchTerm),
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(_appBarTitles[1]),
          floating: true,
          snap: true,
          actions: [
            IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: CustomSearchBar(onSearchChanged: _onSearchChanged)),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int index) {
              Reclamation reclamation = filteredReclamations[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditReclamation(
                        reclamationId: reclamation.id,
                        onUpdated: refreshReclamations,
                      ),
                    ),
                  );
                },
                child: ReclamationTile(reclamation: reclamation),
              );
            },
            childCount: filteredReclamations.length,
          ),
        ),
      ],
    );
  }

  void refreshReclamations() async {
    await fetchReclamationsForCurrentUser(widget.userId);
  }

  Widget _buildAccountView() {
    return ProfilView(userId: widget.userId);
  }

  void refreshNotifications() async {
    await fetchNotifications();
    setState(() {});
  }
}
