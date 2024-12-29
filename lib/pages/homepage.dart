// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcparts/pages/selected.dart';
import 'package:pcparts/services/login_api.dart';
import 'package:pcparts/services/products_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "Guest";
  bool isLoading = true;
  List<Product> products = [];
  List<Map> selectedProducts = [];
  List<Map<String, dynamic>> buildProducts = [];
  String? error;
  final TextEditingController _buildNameController = TextEditingController();

  Map<String, bool> productClickedState = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _loadSession(),
        _loadProducts(),
      ]);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productsList = await ProductsApi.getProducts();
      if (mounted) {
        setState(() {
          products = productsList;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = [];
          error = 'Failed to load products: $e';
        });
      }
    }
  }

  Future<void> _loadSession() async {
    try {
      final sessionData = await LoginApi.getSession();
      if (mounted) {
        setState(() {
          username = sessionData['username']?.toString() ?? "Guest";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => username = "Guest");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Home Page",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () async {
              setState(() => isLoading = true);
              await _loadProducts();
              if (mounted) {
                setState(() => isLoading = false);
              }
            },
          ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Welcome, ${username[0].toUpperCase() + username.substring(1)}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (username == "Guest")
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                                child: const Text('Login'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: products
                                    .where((p) => p.category == "CPU")
                                    .map(
                                        (product) => _buildProductCard(product))
                                    .toList(),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: products
                                    .where((p) => p.category == "GPU")
                                    .map(
                                        (product) => _buildProductCard(product))
                                    .toList(),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: products
                                    .where((p) => p.category == "Motherboard")
                                    .map(
                                        (product) => _buildProductCard(product))
                                    .toList(),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: products
                                    .where((p) => p.category == "RAM")
                                    .map(
                                        (product) => _buildProductCard(product))
                                    .toList(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SingleChildScrollView(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedProducts.isEmpty
                                      ? Colors.grey
                                      : Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 40),
                                ),
                                onPressed: selectedProducts.isEmpty
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _addToBuild(),
                                        );
                                      },
                                child: const Text(
                                  'Add Build',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedProductsPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list_alt_rounded)),
              label: 'List',
            ),
          ]),
    );
  }

  Widget _buildProductCard(Product product) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SizedBox(
        width: 200,
        child: Card(
          elevation: 4,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4.0),
                      ),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.scaleDown,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: (productClickedState[product.id] == true
                        ? Colors.red
                        : Colors.blue),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: IconButton(
                    icon: Icon(
                      color: Colors.white,
                      productClickedState[product.id] == true
                          ? Icons.close
                          : Icons.add,
                    ),
                    onPressed: () => _addToSelection(product),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToSelection(Product product) {
    setState(() {
      final existingProductIndex = selectedProducts.indexWhere(
        (selectedProduct) => selectedProduct['product'] == product.id,
      );

      if (existingProductIndex != -1) {
        selectedProducts.removeAt(existingProductIndex);
        productClickedState[product.id] = false;
      } else {
        final existingCategoryIndex = selectedProducts.indexWhere(
          (selectedProduct) => selectedProduct['category'] == product.category,
        );

        if (existingCategoryIndex != -1) {
          final existingProductId =
              selectedProducts[existingCategoryIndex]['product'];

          productClickedState[existingProductId] = false;

          selectedProducts[existingCategoryIndex] = {
            'product': product.id,
            'category': product.category,
          };
        } else {
          selectedProducts.add({
            'product': product.id,
            'category': product.category,
          });
        }

        productClickedState[product.id] = true;
      }
    });
  }

  void _updateBuildProducts() async {
    if (_buildNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a build name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        buildProducts = selectedProducts.map((product) {
          return {'product': product['product']};
        }).toList();
      });

      String buildName = _buildNameController.text.trim();

      if (username == "Guest") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to create a build'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final buildData = {
        "build_name": buildName,
        "products": buildProducts,
      };

      debugPrint('Sending build data: ${jsonEncode(buildData)}');

      int statusCode = await ProductsApi.build(buildData);

      _buildNameController.clear();

      if (statusCode == 201 || statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Build "$buildName" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          selectedProducts.clear();
          productClickedState.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to create build (Status: $statusCode). Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating build: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _addToBuild() {
    return AlertDialog(
      title: SizedBox(
        width: 250,
        height: 50,
        child: TextField(
          controller: _buildNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue.shade50,
            hintText: 'Enter Build Name',
            hintStyle: TextStyle(color: Colors.blue.shade300),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
            ),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: selectedProducts.map((product) {
              final productDetails = products.firstWhere(
                (p) => p.id == product['product'],
              );
              return ListTile(
                title: Text(productDetails.name),
                subtitle: Text(
                  'Category: ${productDetails.category}',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '\$${productDetails.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.blue),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            _updateBuildProducts();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
