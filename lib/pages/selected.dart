// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pcparts/pages/homepage.dart';
import 'package:pcparts/services/login_api.dart';
import 'package:pcparts/services/products_api.dart';

class SelectedProductsPage extends StatefulWidget {
  const SelectedProductsPage({super.key});

  @override
  State<SelectedProductsPage> createState() => _SelectedProductsPageState();
}

class _SelectedProductsPageState extends State<SelectedProductsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> builds = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBuilds();
  }

  Future<void> _loadBuilds() async {
    try {
      final buildsList = await ProductsApi.getBuilds();
      if (mounted) {
        setState(() {
          builds = buildsList;
          error = null;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          builds = [];
          error = 'Failed to load builds';
          isLoading = false;
        });
      }
    }
  }

  double calculateBuildTotal(List<dynamic> products) {
    return products.fold(
        0.0,
        (sum, product) =>
            sum + (product['product']['price'] as num).toDouble());
  }

  Future<void> _deleteBuild(String buildId, String buildName) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Build'),
          content: Text('Are you sure you want to delete "$buildName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final success = await ProductsApi.deleteBuild(buildId);
        if (success && mounted) {
          setState(() {
            builds.removeWhere((build) => build['_id'] == buildId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Build deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete build: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Builds',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              try {
                final success = await LoginApi.logout();
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                    Navigator.of(context).pushReplacementNamed('/login');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error logging out'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          error!,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  )
                : builds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.build_rounded,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No builds yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first build in the Home page',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: builds.length,
                        itemBuilder: (context, buildIndex) {
                          final build = builds[buildIndex];
                          final double totalPrice =
                              calculateBuildTotal(build['products'] as List);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (build['build_name'][0].toUpperCase() +
                                              build['build_name']
                                                  .substring(1)) ??
                                          'Unnamed Build',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: \$${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.computer,
                                      color: Colors.blue.shade700),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _deleteBuild(
                                      build['_id'], build['build_name']),
                                ),
                                children: [
                                  Divider(height: 1),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (build['products'] as List).length,
                                    itemBuilder: (context, productIndex) {
                                      final product = build['products']
                                          [productIndex]['product'];
                                      return Container(
                                        padding: EdgeInsets.all(8),
                                        child: ListTile(
                                          leading: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                product['image'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.error_outline,
                                                    size: 30,
                                                    color: Colors.red,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            product['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '\$${product['price'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                icon: const Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'List',
            ),
          ],
        ),
      ),
    );
  }
}
