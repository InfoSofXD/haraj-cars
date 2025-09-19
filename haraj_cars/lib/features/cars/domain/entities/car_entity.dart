import 'package:flutter/material.dart';
import '../../../../models/car.dart';

/// Car status enum to work with existing Car model
enum CarStatus {
  available(1, 'Available', Colors.green),
  unavailable(2, 'Unavailable', Colors.orange),
  auction(3, 'Auction', Colors.blue),
  sold(4, 'Sold', Colors.red);

  const CarStatus(this.value, this.displayName, this.color);

  final int value;
  final String displayName;
  final Color color;

  /// Get car status from integer value
  static CarStatus fromInt(int value) {
    switch (value) {
      case 1:
        return CarStatus.available;
      case 2:
        return CarStatus.unavailable;
      case 3:
        return CarStatus.auction;
      case 4:
        return CarStatus.sold;
      default:
        return CarStatus.available;
    }
  }
}

/// Extension to add clean architecture methods to existing Car model
extension CarEntity on Car {
  /// Get CarStatus enum from int status
  CarStatus get carStatus => CarStatus.fromInt(status);

  /// Check if car is available
  bool get isAvailable => status == 1;

  /// Check if car is in auction
  bool get isAuction => status == 3;

  /// Check if car is sold
  bool get isSold => status == 4;

  /// Check if car is unavailable
  bool get isUnavailable => status == 2;

  /// Check if car is favorite (this would be added from favorites service)
  bool get isFavorite => false; // This will be managed by favorites service
}
