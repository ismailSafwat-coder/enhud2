import 'package:enhud/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String groupValue = 'Absolutely';
  final TextEditingController _enjoyController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _enjoyController.dispose();
    _suggestionsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_enjoyController.text.isEmpty || _suggestionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user ID if logged in
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Create feedback data
      Map<String, dynamic> feedbackData = {
        'recommendation': groupValue,
        'enjoyment': _enjoyController.text,
        'suggestions': _suggestionsController.text,
        'userId': userId ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(userId)
          .set(feedbackData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );

        // Clear form
        _enjoyController.clear();
        _suggestionsController.clear();

        // Navigate back after successful submission
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
                        title: const Text('Absolutely not!'),
                        value: "Absolutely not!",
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
                        title: const Text('Definitely!'),
                        value: "Definitely!",
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
                _buildTextField(_enjoyController, 'Share your experience...'),
                const SizedBox(height: 25),
                _buildSectionTitle('Any suggestions or comments?'),
                _buildTextField(
                    _suggestionsController, 'Your feedback helps us improve'),
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
                    onPressed: _isSubmitting ? null : _submitFeedback,
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
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500),
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

  Widget _buildTextField(TextEditingController controller, String hint) {
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
        controller: controller,
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
