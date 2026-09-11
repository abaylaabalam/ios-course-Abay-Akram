double processOrder({
  required String orderId,
  required double itemPrice,
  String? promoCode,
  double? deliveryFee,
}) {
  deliveryFee = deliveryFee ?? 500.0;

  double discount = 0;

  if (promoCode == 'SAVE10') {
    discount = itemPrice * 0.10;
  }
  double finalTotal = itemPrice - discount + deliveryFee;

  print('Order: $orderId');
  print('Item price: $itemPrice ₸');
  print('Discount: $discount ₸');
  print('Delivery fee: $deliveryFee ₸');
  print('Final total: $finalTotal ₸');

  return finalTotal;
}

void main() {
  processOrder(
    orderId: '123',
    itemPrice: 10000,
    promoCode: 'SAVE10',
  );
}
