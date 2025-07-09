import 'package:enhud/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '3_file_upload_screen.dart';

class ScopeSelectionScreen extends StatefulWidget {
  final String material;
  final bool isExamMode;
  const ScopeSelectionScreen(
      {super.key, required this.material, required this.isExamMode});

  @override
  State<ScopeSelectionScreen> createState() => _ScopeSelectionScreenState();
}

class _ScopeSelectionScreenState extends State<ScopeSelectionScreen> {
  String? _selectedScope;
  final List<String> scopes = List.generate(8, (i) => "Unit ${i + 1}")
    ..add("Full Content");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Exercises Scope")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: scopes.length,
                itemBuilder: (context, index) {
                  final scope = scopes[index];
                  final isSelected = _selectedScope == scope;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedScope = scope),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 10)
                              ]
                            : [],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2)),
                        child: Center(
                          child: Text(
                            scope.contains("Unit")
                                ? scope.split(" ").join("\n")
                                : "Full\nContent",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
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
                        backgroundColor: _selectedScope == null
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
                      onPressed: _selectedScope == null
                          ? null
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FileUploadScreen(
                                      material: widget.material,
                                      scope: _selectedScope!,
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
