import 'package:adv_basics/add/add_classe.dart';
import 'package:adv_basics/add/add_classroom.dart';
import 'package:adv_basics/add/add_reservation.dart';
import 'package:adv_basics/add/add_user.dart';
import 'package:adv_basics/edit/edit_classe.dart';
import 'package:adv_basics/edit/edit_classroom.dart';
import 'package:adv_basics/edit/edit_reclamation.dart';
import 'package:adv_basics/edit/edit_reservation.dart';
import 'package:adv_basics/edit/edit_user.dart';
import 'package:adv_basics/home/dashboard_view.dart';
import 'package:adv_basics/model/classe.dart';
import 'package:adv_basics/tiles/classe_tile.dart';
import 'package:adv_basics/model/classroom.dart';
import 'package:adv_basics/tiles/classroom_tile.dart';
import 'package:adv_basics/model/reclamation.dart';
import 'package:adv_basics/tiles/reclamation_tile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adv_basics/model/user.dart';
import 'package:adv_basics/tiles/user_tile.dart';
import 'package:adv_basics/model/reservation.dart';
import 'package:adv_basics/tiles/reservation_tile.dart';
import 'package:adv_basics/home/custom_search_bar.dart';
import 'package:adv_basics/login/login_page.dart';

class HomePage extends StatefulWidget {
  final int initialPage;
  const HomePage({super.key, required this.initialPage});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex = 0;
  String _searchTerm = '';
  final List<String> _appBarTitles = [
    'Dashboard',
    'Reservations',
    'Reclamations',
    'Classrooms',
    'Classes',
    'Account',
    'Logout'
  ];
  List<Reservation> reservations = [];
  bool isReservationsLoading = true;
  List<User> users = [];
  bool isUsersLoading = true;
  List<Reclamation> reclamations = [];
  bool isReclamationsLoading = true;
  List<Classroom> classrooms = [];
  bool isClassroomsLoading = true;
  List<Classe> classes = [];
  bool isClassesLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
    fetchReservations();
    fetchUsers();
    fetchReclamations();
    fetchClassrooms();
    fetchClasses();
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

  Future<void> fetchClassrooms() async {
    setState(() => isClassroomsLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('classrooms').get();
      List<Classroom> fetchedClassrooms =
          snapshot.docs.map((doc) => Classroom.fromFirestore(doc)).toList();

      setState(() {
        classrooms = fetchedClassrooms;
        isClassroomsLoading = false;
      });
    } catch (e) {
      print('Error fetching classrooms: $e');
      setState(() => isClassroomsLoading = false);
    }
  }

  Future<void> fetchClasses() async {
    setState(() => isClassesLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('classes').get();
      List<Classe> fetchedClasses =
          snapshot.docs.map((doc) => Classe.fromFirestore(doc)).toList();

      setState(() {
        classes = fetchedClasses;
        isClassesLoading = false;
      });
    } catch (e) {
      print('Error fetching classes: $e');
      setState(() => isClassesLoading = false);
    }
  }

  Future<void> fetchReclamations() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('reclamations').get();
      print('Fetched reclamations snapshot: ${snapshot.docs}');
      List<Future<Reclamation>> futureReclamations =
          snapshot.docs.map((doc) => Reclamation.fromFirestore(doc)).toList();
      List<Reclamation> fetchedReclamations =
          await Future.wait(futureReclamations);

      setState(() {
        reclamations = fetchedReclamations;
        isReclamationsLoading = false;
      });
    } catch (e) {
      print('Error fetching reclamations: $e');
      setState(() => isReclamationsLoading = false);
    }
  }

  Future<void> fetchUsers() async {
    setState(() {});
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<User> fetchedUsers =
          snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();

      setState(() {
        users = fetchedUsers;
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
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('reservations').get();

      List<Future<Reservation>> futureReservations =
          snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();

      List<Reservation> fetchedReservations =
          await Future.wait(futureReservations);

      setState(() {
        reservations = fetchedReservations;
        isReservationsLoading = false;
      });
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() {
        isReservationsLoading = false;
      });
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

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.event_seat), label: 'Reservations'),
        BottomNavigationBarItem(
            icon: Icon(Icons.report), label: 'Reclamations'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business), label: 'Classrooms'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Classes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Logout'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 28, 78, 173),
      onTap: _onItemTapped,
    );
  }

  Widget buildFloatingActionButton() {
    return (_selectedIndex == 1 ||
            _selectedIndex == 3 ||
            _selectedIndex == 4 ||
            _selectedIndex == 5)
        ? FloatingActionButton(
            onPressed: () {
              if (_selectedIndex == 1) {
                // Logic for adding a new reservation
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const AddReservation()),
                );
              } else if (_selectedIndex == 3) {
                // Logic for adding a new classroom
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AddClassroom()),
                );
              } else if (_selectedIndex == 4) {
                // Logic for adding a new classe
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AddClasse()),
                );
              } else if (_selectedIndex == 5) {
                // Logic for adding a new acount
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AddUser()),
                );
              }
            },
            backgroundColor: const Color.fromARGB(255, 28, 78, 173),
            child: const Icon(Icons.add),
          )
        : const SizedBox();
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return _buildDashboardView();
      case 1:
        return buildReservationsView();
      case 2:
        return _buildReclamationsView();
      case 3:
        return _buildClassroomsView();
      case 4:
        return _buildClassesView();
      case 5:
        return _buildAccountView();
      default:
        return _buildDashboardView();
    }
  }

  Widget _buildClassroomsView() {
    if (isClassroomsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filtering logic here
    List<Classroom> filteredClassrooms = _filterList(
      classrooms,
      (Classroom c) => c.salleDetails.toLowerCase().contains(_searchTerm),
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(_appBarTitles[3]),
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
              Classroom classroom = filteredClassrooms[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditClassroom(
                        classroomId: classroom.id,
                        onUpdated: refreshClassrooms,
                      ),
                    ),
                  );
                },
                child: ClassroomTile(classroom: classroom),
              );
            },
            childCount: filteredClassrooms.length,
          ),
        ),
      ],
    );
  }

  void refreshClassrooms() async {
    await fetchClassrooms();
  }

  Widget _buildClassesView() {
    if (isClassesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filtering logic here
    List<Classe> filteredClasses = _filterList(
      classes,
      (Classe cl) => cl.intitule.toLowerCase().contains(_searchTerm),
    );
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(_appBarTitles[4]),
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
              Classe classe = filteredClasses[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditClasse(
                        classeId: classe.id,
                        onUpdated:
                            fetchClasses, // Pass fetchClasses as callback
                      ),
                    ),
                  );
                },
                child: ClasseTile(classe: classe),
              );
            },
            childCount: filteredClasses.length,
          ),
        ),
      ],
    );
  }

  void refreshClasses() async {
    await fetchClasses();
  }

  Widget _buildDashboardView() {
    return const DashboardView();
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
              // Get the current reservation
              Reservation reservation = filteredReservations[index];

              return ReservationTile(
                reservation: reservation,
                onTap: () {
                  // Navigate to the EditReservation page with the reservation ID
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditReservation(
                      reservationId: reservation.id,
                    ),
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
          title: Text(_appBarTitles[2]),
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
    await fetchReclamations();
  }

  Widget _buildAccountView() {
    if (isUsersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filtering logic here
    List<User> filteredUsers = _filterList(
      users,
      (User u) =>
          u.nom.toLowerCase().contains(_searchTerm) ||
          u.prenom.toLowerCase().contains(_searchTerm) ||
          u.category.toLowerCase().contains(_searchTerm),
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(_appBarTitles[5]), // Index 5 for 'Account'
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
              User user = filteredUsers[index];
              return UserTile(
                user: user,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditUser(
                        userId: user.id, // Assuming User has an id field
                        onUpdated: refreshUsers,
                      ),
                    ),
                  );
                },
              );
            },
            childCount: filteredUsers.length,
          ),
        ),
      ],
    );
  }

  void refreshUsers() async {
    await fetchUsers();
  }
}
