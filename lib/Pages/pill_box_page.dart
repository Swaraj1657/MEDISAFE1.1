import 'package:flutter/material.dart';
import '../services/medication_service.dart';

class PillBoxPage extends StatefulWidget {
  const PillBoxPage({super.key});

  @override
  State<PillBoxPage> createState() => _PillBoxPageState();
}

class _PillBoxPageState extends State<PillBoxPage> {
  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening', 'Night'];
  final List<IconData> _timeSlotIcons = [
    Icons.wb_sunny_outlined,
    Icons.wb_sunny,
    Icons.cloud_outlined,
    Icons.nightlight_outlined,
  ];
  final MedicationService _medicationService = MedicationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pill Box',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildTimeSlotCard(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add medicine page
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeSlotCard(int index) {
    final medications = _medicationService.getMedicationsForTimeSlot(index);
    final allTaken = _medicationService.areAllMedicationsTaken(index);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _timeSlotIcons[index],
                  color: allTaken ? Colors.green : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _timeSlots[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: allTaken ? Colors.green : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (allTaken) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  medications.isEmpty
                      ? Center(
                        child: Text(
                          'No medications',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: medications.length,
                        itemBuilder: (context, i) {
                          final medicine = medications[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: medicine.isTaken,
                                    onChanged:
                                        medicine.isTaken
                                            ? null
                                            : (value) {
                                              setState(() {
                                                _medicationService
                                                    .toggleMedicineTaken(
                                                      index,
                                                      i,
                                                    );

                                                // Show confirmation message
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '${medicine.name} marked as taken',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      textColor: Colors.white,
                                                      onPressed: () {
                                                        setState(() {
                                                          _medicationService
                                                              .toggleMedicineTaken(
                                                                index,
                                                                i,
                                                              );
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                    activeColor: Colors.green,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.medication_outlined,
                                  color:
                                      medicine.isTaken
                                          ? Colors.green
                                          : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    medicine.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration:
                                          medicine.isTaken
                                              ? TextDecoration.lineThrough
                                              : null,
                                      color:
                                          medicine.isTaken
                                              ? Colors.grey
                                              : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _medicationService.removeMedication(
                                          index,
                                          i,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
