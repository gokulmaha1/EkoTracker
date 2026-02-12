import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/store_provider.dart';
import '../models/store_model.dart';

class OrderEntryScreen extends StatefulWidget {
  final int storeId;
  const OrderEntryScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _OrderEntryScreenState createState() => _OrderEntryScreenState();
}

class _OrderEntryScreenState extends State<OrderEntryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      // Also clear cart? Maybe or maybe not if we want persistence. Let's clear for now.
      Provider.of<OrderProvider>(context, listen: false).clearCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    
    // Find store name safely
    final storeName = storeProvider.stores.firstWhere(
        (s) => s.id == widget.storeId, 
        orElse: () => Store(id: 0, name: 'Unknown Store')
    ).name;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order for $storeName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Show Cart Summary
              _showCartBottomSheet(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productProvider.searchProducts(_searchController.text).length,
                    itemBuilder: (context, index) {
                      final product = productProvider.searchProducts(_searchController.text)[index];
                      final cartItem = orderProvider.cart.firstWhere(
                          (item) => item.productId == product.id, 
                          orElse: () => OrderItem(productId: -1, productName: '', price: 0, quantity: 0)
                      );
                      
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Stock: ${product.stock} | Price: ₹${product.price}'),
                        trailing: cartItem.quantity > 0 
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () => orderProvider.updateQuantity(product.id, cartItem.quantity - 1),
                                  ),
                                  Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: () => orderProvider.addToCart(product.id, product.name, product.price),
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  orderProvider.addToCart(product.id, product.name, product.price);
                                },
                              ),
                      );
                    },
                  ),
          ),
          if (orderProvider.cart.isNotEmpty)
             Container(
               padding: const EdgeInsets.all(16.0),
               color: Colors.blue.withOpacity(0.1),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('Total: ₹${orderProvider.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   ElevatedButton(
                     onPressed: orderProvider.isSubmitting 
                         ? null 
                         : () async {
                             try {
                               await orderProvider.submitOrder(widget.storeId);
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Submitted!')));
                               context.pop(); // Go back to store list
                             } catch (e) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                             }
                           },
                     child: orderProvider.isSubmitting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Order'),
                   ),
                 ],
               ),
             ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            return ListView.builder(
              itemCount: orderProvider.cart.length,
              itemBuilder: (context, index) {
                final item = orderProvider.cart[index];
                return ListTile(
                  title: Text(item.productName),
                  subtitle: Text('${item.quantity} x ₹${item.price} = ₹${item.total}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => orderProvider.removeFromCart(item.productId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
