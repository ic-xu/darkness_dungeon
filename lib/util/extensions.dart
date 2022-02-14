import 'package:bonfire/bonfire.dart';

extension DirectionExtensions on Direction {
  String getName() {
    return this.toString().replaceAll('Direction.', '');
  }
}

extension StringExtensions on String {

  getDirectionEnum() {
    switch (this) {
      case 'left':
        return Direction.left;
        break;
      case 'right':
        return Direction.right;
        break;
      case 'up':
        return Direction.up;
        break;
      case 'down':
        return Direction.down;
        break;


      case 'upLeft':
        return Direction.left;
        break;

      case 'upRight':
        return Direction.right;
        break;

      case 'downLeft':
        return Direction.left;
        break;

      case 'downRight':
        return Direction.right;
        break;
      default:
        return Direction.left;
    }
  }

}
