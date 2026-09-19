class Book {
  String title;
  String author;
  double price;
  bool isBorrowed;

  Book({
    required this.title,
    required this.author,
    required this.price,
    this.isBorrowed = false,
  });
}

class Library {
  List<Book> _books = [];

  void addBook(Book book) {
    _books.add(book);
    print('Added: ${book.title}');
  }

  List<Book> getAvailableBooks() {
    return _books.where((book) => book.isBorrowed == false).toList();
  }

  double getTotalValue() {
    return _books.fold(0.0, (sum, book) => sum + book.price);
  }
}

void main() {
  Library myLibrary = Library();

  Book book1 = Book(title: 'Harry Potter', author: 'J.K. Rowling', price: 5500.0);
  Book book2 = Book(title: '1984', author: 'George Orwell', price: 3200.0, isBorrowed: true);
  Book book3 = Book(title: 'Clean Code', author: 'Robert Martin', price: 8900.0);

  myLibrary.addBook(book1);
  myLibrary.addBook(book2);
  myLibrary.addBook(book3);

  print('\n--- Available Books ---');
  List<Book> available = myLibrary.getAvailableBooks();
  for (Book b in available) {
    print('- ${b.title} by ${b.author}');
  }

  print('\n--- Total Collection Value ---');
  double total = myLibrary.getTotalValue();
  print('Total price of all books: $total ₸');
}
