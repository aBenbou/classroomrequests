import 'package:adv_basics/add/add_reclamation.dart';
import 'package:adv_basics/edit/edit_reclamation.dart';
import 'package:adv_basics/edit/profil_view.dart';
import 'package:adv_basics/home/reservation_view.dart';
import 'package:adv_basics/model/reclamation.dart';
import 'package:adv_basics/tiles/reclamation_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/user.dart';
import 'package:adv_basics/model/reservation.dart';
import 'package:adv_basics/tiles/reservation_tile.dart';
import 'package:adv_basics/home/custom_search_bar.dart';
import 'package:adv_basics/login/login_page.dart';

class ProfessorHomePage extends StatefulWidget {
  final int initialPage;
  final String userId;
  const ProfessorHomePage(
      {super.key, required this.initialPage, required this.userId});

  @override
  State<ProfessorHomePage> createState() {
    return _ProfessorHomePageState();
  }
}

class _ProfessorHomePageState extends State<ProfessorHomePage> {
  late int _selectedIndex = 0;
  String _searchTerm = '';
  final List<String> _appBarTitles = [
    'Reservations',
    'Reclamations',
    'Profil',
    'Logout'
  ];
  List<Reservation> reservations = [];
  bool isReservationsLoading = true;
  List<User> users = [];
  bool isUsersLoading = true;
  List<Reclamation> reclamations = [];
  bool isReclamationsLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
    fetchReservations();
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

  Future<void> fetchReservations() async {
    setState(() => isReservationsLoading = true);
    try {
      // Use the server's timestamp to avoid time zone discrepancies
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Print the local start and end of the day
      print('Local start of day: $startOfDay');
      print('Local end of day: $endOfDay');

      // Convert local time to UTC before querying Firestore
      Timestamp startTimestamp = Timestamp.fromDate(startOfDay.toUtc());
      Timestamp endTimestamp = Timestamp.fromDate(endOfDay.toUtc());

      // Print the UTC start and end timestamps
      print('UTC start timestamp: $startTimestamp');
      print('UTC end timestamp: $endTimestamp');

      // Fetch reservations for the current day and professor
      QuerySnapshot reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('professeur',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId))
          .where('debut', isGreaterThanOrEqualTo: startTimestamp)
          .where('debut', isLessThanOrEqualTo: endTimestamp)
          .get();

      // Print the fetched snapshot
      print('Fetched reservation snapshot: ${reservationSnapshot.docs}');

      List<Future<Reservation>> futureReservations = reservationSnapshot.docs
          .map((doc) => Reservation.fromFirestore(doc))
          .toList();

      List<Reservation> fetchedReservations =
          await Future.wait(futureReservations);

      // Print the fetched reservations
      print('Fetched reservations: $fetchedReservations');

      setState(() {
        reservations = fetchedReservations;
        isReservationsLoading = false;
      });
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() => isReservationsLoading = false);
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
      // The 'Reclamations' tab
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
        return buildReservationsView();
      case 1:
        return _buildReclamationsView();
      case 2:
        return _buildAccountView();
      default:
        return buildReservationsView();
    }
  }

  Widget buildReservationsView() {
    if (isReservationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filtering logic here
    List<Reservation> filteredReservations = _filterList(
      reservations,
      (Reservation r) =>
          r.coursIntitule.toLowerCase().contains(_searchTerm) ||
          r.professeurNom.toLowerCase().contains(_searchTerm) ||
          r.salleDetails.toLowerCase().contains(_searchTerm),
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
              // Get the current reservation
              Reservation reservation = filteredReservations[index];

              return ReservationTile(
                reservation: reservation,
                onTap: () {
                  // Navigate to the EditReservation page with the reservation ID
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ReservationView(reservation: reservation),
                  ));
                },
              );
            },
            childCount: filteredReservations.length,
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
}
