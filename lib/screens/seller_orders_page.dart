import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.baru:
        return 'Baru';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.ditolak:
        return 'Ditolak';
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.baru:
        return Colors.orange;
      case OrderStatus.diproses:
        return Colors.blue;
      case OrderStatus.selesai:
        return Colors.green;
      case OrderStatus.ditolak:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kDarkGreen,
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<SellerOrder>>(
          valueListenable: SellerAccountState.instance.myOrders,
          builder: (context, orders, _) {
            if (orders.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada pesanan masuk.',
                  style: TextStyle(
                    fontSize: 13,
                    color: kDarkGreen.withValues(alpha: 0.6),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: kDarkGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.pembeli,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                order.status,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(order.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _statusColor(order.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.produk,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp${_formatPrice(order.total)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                      if (order.status == OrderStatus.baru) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => SellerAccountState.instance
                                    .updateOrderStatus(
                                      order.id,
                                      OrderStatus.ditolak,
                                    ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => SellerAccountState.instance
                                    .updateOrderStatus(
                                      order.id,
                                      OrderStatus.diproses,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kDarkGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Terima'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (order.status == OrderStatus.diproses) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => SellerAccountState.instance
                                .updateOrderStatus(
                                  order.id,
                                  OrderStatus.selesai,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDarkGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Tandai Selesai'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}