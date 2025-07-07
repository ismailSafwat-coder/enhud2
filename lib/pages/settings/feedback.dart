import 'package:enhud/main.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String groupValue = 'Absolutely';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F8CF8),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text('Feedback',
            style: TextStyle(fontWeight: FontWeight.bold)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'We would love to hear your thoughts, suggestions, concerns or problems with anything so we can improve!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle(
                    'How likely will you recommend us to your friends?'),

                // Replace the container with a better layout
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      // First option
                      RadioListTile<String>(
                        title: const Text(
                          'Definitely!',
                          style: commonTextStyle,
                        ),
                        value: "Definitely!",
                        groupValue: groupValue,
                        activeColor: const Color(0xFF5F8CF8),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          setState(() => groupValue = val!);
                        },
                      ),
                      const Divider(height: 1),
                      // Second option

                      RadioListTile<String>(
                        title: const Text(
                          'Absolutely not!',
                          style: commonTextStyle,
                        ),
                        value: "Absolutely not!",
                        groupValue: groupValue,
                        activeColor: const Color(0xFF5F8CF8),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          setState(() => groupValue = val!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle(
                    'What did you enjoy most about the application?'),
                _buildTextField('Share your experience...'),
                const SizedBox(height: 25),
                _buildSectionTitle('Any suggestions or comments?'),
                _buildTextField('Your feedback helps us improve'),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Thank you!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF5F8CF8), Color(0xFF3A6CD7)],
                        ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit logic
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: const Color(0xFF5F8CF8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 12),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Submit',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFF5F8CF8)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5F8CF8), width: 2),
          ),
        ),
      ),
    );
  }
}
