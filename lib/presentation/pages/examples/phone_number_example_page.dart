import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/presentation/widgets/input/phone_input_field.dart';
import 'package:dent_app_mobile/presentation/widgets/text/phone_number_text.dart';
import 'package:flutter/material.dart';

class PhoneNumberExamplePage extends StatefulWidget {
  const PhoneNumberExamplePage({super.key});

  @override
  State<PhoneNumberExamplePage> createState() => _PhoneNumberExamplePageState();
}

class _PhoneNumberExamplePageState extends State<PhoneNumberExamplePage> {
  final TextEditingController _phoneController = TextEditingController();
  final List<String> _exampleNumbers = [
    '996204904599',
    '905554443322',
    '14155552671',
    '6197771234',
    '442071234567',
  ];

  String _customFormattedNumber = '';

  @override
  void initState() {
    super.initState();
    // Set initial number
    _phoneController.text = '996204904599';
    _updateCustomFormat();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateCustomFormat() {
    setState(() {
      _customFormattedNumber = FormatUtils.formatPhoneNumber(
        _phoneController.text,
        countryCodeSeparator: '-',
        areaCodePrefix: '[',
        areaCodeSuffix: ']',
        lastSeparator: '/',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number Formatting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field
            const Text(
              'Enter a phone number:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            PhoneInputField(
              controller: _phoneController,
              labelText: 'Phone Number',
              hintText: 'Enter phone number',
              onChanged: (_) => _updateCustomFormat(),
            ),

            const SizedBox(height: 32),

            // Formatted display
            const Text(
              'Standard Format:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue),
                    const SizedBox(width: 12),
                    PhoneNumberText(
                      phoneNumber: _phoneController.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Custom format
            const Text(
              'Custom Format:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      _customFormattedNumber,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Examples
            const Text(
              'Examples:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exampleNumbers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final number = _exampleNumbers[index];
                return ListTile(
                  title: Text('Original: $number'),
                  subtitle: PhoneNumberText(
                    phoneNumber: number,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  leading: const Icon(Icons.phone),
                  onTap: () {
                    setState(() {
                      _phoneController.text = number;
                      _updateCustomFormat();
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
