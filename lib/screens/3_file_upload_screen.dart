import 'dart:io';
import 'package:enhud/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '4_exam_loading_screen.dart';

class FileUploadScreen extends StatefulWidget {
  final String material;
  final String scope;
  final bool isExamMode;

  const FileUploadScreen(
      {super.key,
      required this.material,
      required this.scope,
      required this.isExamMode});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Material File")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.upload_file_rounded,
                      size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    "Please upload the relevant PDF or TXT file for the selected unit.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                        _selectedFile == null ? 'Choose File' : 'Change File'),
                    onPressed: _pickFile,
                  ),
                  if (_selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Selected: ${_selectedFile!.path.split('/').last}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            Row(
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
                      backgroundColor: _selectedFile == null
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
                    onPressed: _selectedFile == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExamLoadingScreen(
                                  file: _selectedFile!,
                                  isExamMode: widget.isExamMode,
                                ),
                              ),
                            );
                          },
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
