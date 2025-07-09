import 'package:enhud/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '2_scope_selection_screen.dart';

class MaterialSelectionScreen extends StatefulWidget {
  final bool isExamMode;
  const MaterialSelectionScreen({super.key, required this.isExamMode});

  @override
  State<MaterialSelectionScreen> createState() =>
      _MaterialSelectionScreenState();
}

class _MaterialSelectionScreenState extends State<MaterialSelectionScreen> {
  String? _selectedMaterial;
  final List<String> materials = [
    "Arabic",
    "Math",
    "English",
    "French",
    "Physics",
    "Chemistry",
    "Biology",
    "Programming"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Material")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  final isSelected = _selectedMaterial == material;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMaterial = material),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          material,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo'),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Back"))),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMaterial == null
                            ? Colors.grey.shade300
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo'),
                      ),
                      onPressed: _selectedMaterial == null
                          ? null
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScopeSelectionScreen(
                                      material: _selectedMaterial!,
                                      isExamMode: widget.isExamMode,
                                    ),
                                  ));
                            },
                      child: const Text("Next"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
