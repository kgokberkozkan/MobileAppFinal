import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'basket_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BasketProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        routes: {
          '/store': (context) => StorePage(),
          '/basket': (context) => BasketPage(),
          '/productDetail': (context) => ProductDetailPage(),
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Store navigation with Hero animation
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/store');
              },
              child: Hero(
                tag: 'storeHero',
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: Icon(Icons.store, size: 50, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Basket navigation with Hero animation
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/basket');
              },
              child: Hero(
                tag: 'basketHero',
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.green,
                  child: Icon(Icons.shopping_basket, size: 50, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<dynamic>> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  // Fetch products from the Fake Store API
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'storeHero',
          child: Text('Store'),
        ),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Display list of products
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data![index];
                  return ListTile(
                    title: Text(product['title']),
                    subtitle: Text('${product['price']} \$'),
                    onTap: () {
                      // Navigate to product detail page with selected product
                      Navigator.of(context).pushNamed(
                        '/productDetail',
                        arguments: product,
                      );
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        // Add product to basket
                        Provider.of<BasketProvider>(context, listen: false).addItem(product);
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the product passed as an argument
    final product = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'storeHero',
          child: Text(product['title']),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('${product['price']} \$', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text(product['description']),
          ],
        ),
      ),
    );
  }
}

class BasketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'basketHero',
          child: Text('Basket'),
        ),
      ),
      body: Consumer<BasketProvider>(
        builder: (context, basketProvider, child) {
          return ListView.builder(
            itemCount: basketProvider.basketItems.length,
            itemBuilder: (context, index) {
              var item = basketProvider.basketItems[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Text('${item['price']} \$'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_shopping_cart),
                  onPressed: () {
                    // Remove item from basket
                    basketProvider.removeItem(item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}