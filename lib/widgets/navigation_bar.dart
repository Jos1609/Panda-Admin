import 'package:flutter/material.dart' ;
import 'package:panda_admin/utils/screen_enum.dart';

class NavigationBar1 extends StatelessWidget {
  final Screen currentScreen;

  const NavigationBar1({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentScreen.index,
      onTap: (index) {
        switch (Screen.values[index]) {
          case Screen.dashboard:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
          case Screen.orders:
            Navigator.pushReplacementNamed(context, '/orders');
            break;
          case Screen.products:
            Navigator.pushReplacementNamed(context, '/products');
            break;
          case Screen.drivers:
            Navigator.pushReplacementNamed(context, '/drivers');
            break;
          case Screen.customers:
            Navigator.pushReplacementNamed(context, '/customers');
            break;
          case Screen.locations:
            Navigator.pushReplacementNamed(context, '/locations');
            break;
          case Screen.reports:
            Navigator.pushReplacementNamed(context, '/reports');
            break;
          case Screen.settings:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard,color: Colors.black),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart,color: Colors.black),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood,color: Colors.black),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delivery_dining,color: Colors.black),
          label: 'Repartidores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people,color: Colors.black),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store,color: Colors.black),
          label: 'Locales',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics,color: Colors.black),
          label: 'Informes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings,color: Colors.black),
          label: 'Configuración',
        ),
      ],
    );
  }
}