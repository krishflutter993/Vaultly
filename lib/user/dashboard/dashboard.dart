import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:accounts_information_handler/user/dashboard/Screen/CategoryItems.dart';
import 'package:accounts_information_handler/user/loging/loging.dart';
import 'package:accounts_information_handler/theme/glass_container.dart';
import 'package:accounts_information_handler/user/profile/profile_screen.dart';
import 'package:accounts_information_handler/user/settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String searchText = '';
  final TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> defaultCategories = [
    {
      "title": "Business",
      "icon": Icons.business_center_rounded,
      "color": Colors.blue,
    },
    {
      "title": "Computer Logins",
      "icon": Icons.computer_rounded,
      "color": Colors.deepPurple,
    },
    {
      "title": "Credit Cards",
      "icon": Icons.credit_card_rounded,
      "color": Colors.orange,
    },
    {
      "title": "Important Docs",
      "icon": Icons.description_rounded,
      "color": Colors.green,
    },
    {
      "title": "Private Photos",
      "icon": Icons.photo_library_rounded,
      "color": Colors.pink,
    },
    {
      "title": "Social Media",
      "icon": Icons.share_rounded,
      "color": Colors.lightBlue,
    },
    {
      "title": "Website Passwords",
      "icon": Icons.language_rounded,
      "color": Colors.teal,
    },
    {
      "title": "Drivers License",
      "icon": Icons.drive_eta_rounded,
      "color": Colors.amber,
    },
  ];

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    categories = List.from(defaultCategories);
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        if (data.containsKey('customCategories')) {
          final List<dynamic> customCats = data['customCategories'];
          setState(() {
            for (var catTitle in customCats) {
              if (!categories.any((c) => c['title'] == catTitle)) {
                categories.add({
                  "title": catTitle,
                  "icon": Icons.folder_special_rounded,
                  "color": Colors.indigo,
                });
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
  }

  void _deleteCategory(String title) async {
    setState(() {
      categories.removeWhere((c) => c['title'] == title);
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final customCats = categories
            .where(
              (c) => !defaultCategories.any((dc) => dc['title'] == c['title']),
            )
            .map((c) => c['title'])
            .toList();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'customCategories': customCats,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error deleting category: $e");
      }
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController catController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Category',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            prefixIcon: Icon(Icons.create_new_folder_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = catController.text.trim();
              if (title.isNotEmpty) {
                if (!categories.any((c) => c['title'] == title)) {
                  setState(() {
                    categories.add({
                      "title": title,
                      "icon": Icons.folder_special_rounded,
                      "color": Colors.indigo,
                    });
                  });
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      final customCats = categories
                          .where(
                            (c) => !defaultCategories.any(
                              (dc) => dc['title'] == c['title'],
                            ),
                          )
                          .map((c) => c['title'])
                          .toList();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                            'customCategories': customCats,
                          }, SetOptions(merge: true));
                    } catch (e) {
                      debugPrint("Error saving category: $e");
                    }
                  }
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultView() {
    final filtered = categories.where((item) {
      return item["title"].toString().toLowerCase().contains(
        searchText.toLowerCase(),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Vault",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "End-to-End Encrypted",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => LoginScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // SEARCH
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search categories....",
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchText = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        // CATEGORIES LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              final isDefault = defaultCategories.any(
                (dc) => dc['title'] == item['title'],
              );
              final Color iconColor = item['color'] ?? Colors.indigo;

              final cardContent = Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item["icon"], color: iconColor, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item["title"],
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              );

              final wrappedCard = GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          CategoryDetailsScreen(categoryName: item["title"]),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: cardContent,
              );

              if (isDefault) {
                return wrappedCard;
              }

              return Dismissible(
                key: Key(item["title"]),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteCategory(item["title"]);
                },
                child: wrappedCard,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildVaultView(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddCategoryDialog,
              elevation: 4,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: IndexedStack(index: _currentIndex, children: pages),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_rounded),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
