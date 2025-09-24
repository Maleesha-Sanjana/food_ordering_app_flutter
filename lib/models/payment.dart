class PaymentMethod {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final String cardType; // Visa, MasterCard, etc.

  const PaymentMethod({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    required this.cardType,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
      cardHolderName: json['cardHolderName'] as String,
      cardType: json['cardType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'cardNumber': cardNumber,
    'expiryDate': expiryDate,
    'cvv': cvv,
    'cardHolderName': cardHolderName,
    'cardType': cardType,
  };

  // Helper method to get masked card number for display
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return '**** **** **** $lastFour';
  }

  // Helper method to validate card number (basic validation)
  bool get isValidCardNumber {
    // Remove spaces and check if it's numeric
    final cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;
    return RegExp(r'^\d+$').hasMatch(cleanNumber);
  }

  // Helper method to validate expiry date
  bool get isValidExpiryDate {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) return false;
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    final now = DateTime.now();
    final expiry = DateTime(year, month);
    return expiry.isAfter(now);
  }

  // Helper method to validate CVV
  bool get isValidCvv {
    return cvv.length >= 3 && cvv.length <= 4 && RegExp(r'^\d+$').hasMatch(cvv);
  }

  // Helper method to get card type based on card number
  static String getCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    
    if (cleanNumber.startsWith('4')) return 'Visa';
    if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) return 'MasterCard';
    if (cleanNumber.startsWith('3')) return 'American Express';
    if (cleanNumber.startsWith('6')) return 'Discover';
    
    return 'Unknown';
  }

  // Helper method to validate all fields
  bool get isValid {
    return isValidCardNumber && 
           isValidExpiryDate && 
           isValidCvv && 
           cardHolderName.trim().isNotEmpty;
  }
}

// Dummy payment methods for testing
class DummyPaymentMethods {
  static const List<PaymentMethod> methods = [
    PaymentMethod(
      cardNumber: '4111 1111 1111 1111',
      expiryDate: '12/25',
      cvv: '123',
      cardHolderName: 'John Doe',
      cardType: 'Visa',
    ),
    PaymentMethod(
      cardNumber: '5555 5555 5555 4444',
      expiryDate: '06/26',
      cvv: '456',
      cardHolderName: 'Jane Smith',
      cardType: 'MasterCard',
    ),
    PaymentMethod(
      cardNumber: '3782 822463 10005',
      expiryDate: '09/27',
      cvv: '789',
      cardHolderName: 'Bob Johnson',
      cardType: 'American Express',
    ),
  ];
}
