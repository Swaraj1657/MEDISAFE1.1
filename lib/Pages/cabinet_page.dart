import 'package:flutter/material.dart';
import 'addmedicicne.dart';
// import 'bandages_cabinet_page.dart';
// import 'first_aid_cabinet_page.dart';

class CabinetPage extends StatefulWidget {
  const CabinetPage({super.key});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage> {
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.medication, 'title': 'Medicines', 'items': <String>[]},
    {'icon': Icons.medical_services, 'title': 'Bandages', 'items': <String>[]},
    {'icon': Icons.healing, 'title': 'First Aid', 'items': <String>[]},
  ];

  void _navigateToCategoryPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MedicineTrackerScreen();
        break;
      // case 1:
      //   page = const BandagesCabinetPage();
      //   break;
      // case 2:
      //   page = const FirstAidCabinetPage();
      //   break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            color: Colors.grey[600],
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              backgroundColor: Colors.black87,
              leading: Icon(category['icon'] as IconData, color: Colors.blue),
              title: Text(
                category['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              children: [
                if ((category['items'] as List).isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No items added yet',
                      style: TextStyle(
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (category['items'] as List).length,
                  itemBuilder: (context, itemIndex) {
                    return ListTile(
                      title: Text(category['items'][itemIndex]),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            (category['items'] as List).removeAt(itemIndex);
                          });
                        },
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () => _navigateToCategoryPage(index),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
