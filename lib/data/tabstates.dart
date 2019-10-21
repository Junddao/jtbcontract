
import 'package:flutter/widgets.dart';

class TabStates with ChangeNotifier{

  int _selectedIndex = 0;
  
  int get selectedIndex => _selectedIndex;
  set selectedIndex(int selectedIndex) {
    _selectedIndex = selectedIndex;
    notifyListeners();
  }
}

