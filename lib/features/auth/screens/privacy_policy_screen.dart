import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Burbly Flashcard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: January 27, 2026',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. Introduction'),
            _buildSectionText(
              'Welcome to Burbly Flashcard. We are committed to protecting your personal information and your right to privacy.',
            ),
            _buildSectionTitle('2. Information We Collect'),
            _buildSectionText(
              'We collect personal information that you provide to us such as email address and password when you register on the App.',
            ),
            _buildSectionTitle('3. How We Use Your Information'),
            _buildSectionText(
              'We use your information to facilitate account creation and logon process, and to provide the flashcard study services.',
            ),
            _buildSectionTitle('4. Data Storage and Security'),
            _buildSectionText(
              'Your data is stored securely using Firebase (a Google service). We implement appropriate technical and organizational security measures designed to protect the security of any personal information we process.',
            ),
            _buildSectionTitle('5. Your Privacy Rights'),
            _buildSectionText(
              'You can review, change, or terminate your account at any time by contacting us or using the settings within the app.',
            ),
            _buildSectionTitle('6. Contact Us'),
            _buildSectionText(
              'If you have questions or comments about this policy, you may contact us at support@burbly.app.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }
}
