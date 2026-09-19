void checkBalance({required String name, required double balance}) =>
    print('$name, current balance: $balance');

double deposit({required double currentBalance, double? amount}) {
  double money = amount ?? 0.0;
  double newBalance = currentBalance + money;
  print('Deposited: $money. Updated balance: $newBalance');
  return newBalance;
}

double withdraw({
  required String name,
  required double currentBalance,
  double? amount,
  int? pinCode,
}) {
  int pin = pinCode ?? 0000;

  if (pin != 1234) {
    print('$name, incorrect PIN!');
    return currentBalance;
  }

  double money = amount ?? 0.0;

  if (money > currentBalance) {
    print('$name, insufficient funds!');
    return currentBalance;
  }

  double newBalance = currentBalance - money;
  print('$name, withdrawn: $money. Updated balance: $newBalance');
  return newBalance;
}

void main() {
  double balance = 500.0;
  String name = 'Azamat';

  checkBalance(name: name, balance: balance);

  balance = deposit(currentBalance: balance, amount: 150.0);
  balance = deposit(currentBalance: balance, amount: null);

  balance = withdraw(name: name, currentBalance: balance, amount: 50.0, pinCode: 1234);
  balance = withdraw(name: name, currentBalance: balance, amount: 50.0, pinCode: 9999);
  balance = withdraw(name: name, currentBalance: balance, amount: 1000.0, pinCode: 1234);

  checkBalance(name: name, balance: balance);
}

