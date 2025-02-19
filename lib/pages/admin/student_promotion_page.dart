import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentPromotionPage extends StatefulWidget {
  const StudentPromotionPage({super.key, required String adminId});

  @override
  State<StudentPromotionPage> createState() => _StudentPromotionPageState();
}

class _StudentPromotionPageState extends State<StudentPromotionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false; // Track progress

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Promotion"),
          content: const Text(
              "Are you sure you want to promote students to the next year? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                promoteStudents(); // Proceed with promotion
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  void promoteStudents() async {
    setState(() {
      _isProcessing = true; // Start processing
    });

    try {
      WriteBatch batch = _firestore.batch();

      // Define academic years for BA, BCOM, and BS
      Map<String, List<String>> streams = {
        "BA": ["FYBA", "SYBA", "TYBA", "LYBA"],
        "BCOM": ["FYBCOM", "SYBCOM", "TYBCOM", "LYBCOM"],
        "BS": ["FYBS", "SYBS", "TYBS", "LYBS"]
      };

      for (var stream in streams.entries) {
        List<String> years = stream.value;

        for (int i = years.length - 1; i >= 0; i--) {
          String currentYear = years[i];
          String nextYear =
              (i == years.length - 1) ? "GRADUATED" : years[i + 1];

          QuerySnapshot studentSnapshot = await _firestore
              .collection('classes')
              .doc(currentYear)
              .collection('students')
              .get();

          for (var doc in studentSnapshot.docs) {
            if (nextYear == "GRADUATED") {
              batch.delete(doc.reference); // Remove final-year students
            } else {
              DocumentReference newRef = _firestore
                  .collection('classes')
                  .doc(nextYear)
                  .collection('students')
                  .doc(doc.id);

              batch.set(newRef, doc.data()); // Move student to next year
              batch.delete(doc.reference); // Remove from old year
            }
          }
        }

        // Clear first-year students (ready for new batch)
        QuerySnapshot firstYearSnapshot = await _firestore
            .collection('classes')
            .doc(years[0])
            .collection('students')
            .get();

        for (var doc in firstYearSnapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student Promotion Successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error promoting students: $e")),
      );
    } finally {
      setState(() {
        _isProcessing = false; // Stop processing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promote Students")),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator() // Show indicator when processing
            : ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : _showConfirmationDialog, // Disable when processing
                child: const Text("Promote to Next Year"),
              ),
      ),
    );
  }
}
