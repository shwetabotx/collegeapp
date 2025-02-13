import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collegeapp/pages/teacher_home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class UploadResourcesPage extends StatefulWidget {
  final String teacherId;
  final String classId;

  const UploadResourcesPage({
    super.key,
    required this.teacherId,
    required this.classId,
  });

  @override
  UploadResourcesPageState createState() => UploadResourcesPageState();
}

class UploadResourcesPageState extends State<UploadResourcesPage> {
  File? _selectedFile;
  String? _fileName;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "Notes";
  String _selectedClassId = "FYBA";
  bool _isLoading = false; // Loading indicator

  final List<String> _categories = [
    "Notes",
    "Assignments",
    "Videos",
    "References"
  ];
  final List<String> _classIds = [
    "FYBA",
    "FYBCOM",
    "FYBCA",
    "SYBA",
    "SYBCOM",
    "SYBCA",
    "TYBA",
    "TYBCOM",
    "TYBCA",
    "LYBA",
    "LYBCOM",
    "LYBCA"
  ];

  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dnxfyvlei/image/upload';
  final String cloudinaryUploadPreset = 'collegeapp';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please select a file and enter a title.");
      return;
    }

    setState(() => _isLoading = true); // Show loading indicator

    try {
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = cloudinaryUploadPreset
        ..files.add(
            await http.MultipartFile.fromPath('file', _selectedFile!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = json.decode(responseData.body);
        String fileUrl = result['secure_url'];

        await FirebaseFirestore.instance
            .collection("classes")
            .doc(_selectedClassId)
            .collection("resources")
            .add({
          "title": _titleController.text,
          "description": _descriptionController.text,
          "fileUrl": fileUrl,
          "fileName": _fileName,
          "classId": _selectedClassId,
          "category": _selectedCategory,
          "teacherId": widget.teacherId,
          "uploadedAt": Timestamp.now(),
        });

        Fluttertoast.showToast(msg: "File uploaded successfully!");
      } else {
        Fluttertoast.showToast(msg: "Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed: $e");
    } finally {
      setState(
          () => _isLoading = false); // Hide loading indicator after completion
    }
  }

  Future<void> _deleteResource(String resourceId) async {
    bool confirmDelete = await _showDeleteConfirmation();
    if (!confirmDelete) return;

    await FirebaseFirestore.instance
        .collection("classes")
        .doc(_selectedClassId)
        .collection("resources")
        .doc(resourceId)
        .delete();

    Fluttertoast.showToast(msg: "Resource deleted successfully.");
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete"),
            content:
                const Text("Are you sure you want to delete this resource?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Delete")),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Resources"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherHomePage(
                teacherId: widget.teacherId,
                classId: widget.classId,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Class Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedClassId,
                    onChanged: (newValue) =>
                        setState(() => _selectedClassId = newValue!),
                    items: _classIds.map((classId) {
                      return DropdownMenuItem(
                          value: classId, child: Text(classId));
                    }).toList(),
                    isExpanded: true,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    underline: const SizedBox(),
                  ),
                ),
                const SizedBox(height: 10),
                // File Picker Button
                ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Choose File"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                if (_fileName != null) Text("Selected: $_fileName"),
                const SizedBox(height: 10),
                // Title Input Field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Description Input Field
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                // Category Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (newValue) =>
                        setState(() => _selectedCategory = newValue!),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    isExpanded: true,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    underline: const SizedBox(),
                  ),
                ),
                const SizedBox(height: 20),
                // Upload Button
                ElevatedButton(
                    onPressed: _uploadFile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Upload")),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("classes")
                        .doc(_selectedClassId)
                        .collection("resources")
                        .orderBy("uploadedAt", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No resources available."));
                      }

                      var resources = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: resources.length,
                        itemBuilder: (context, index) {
                          var resource = resources[index];
                          String title = resource["title"];
                          String fileUrl = resource["fileUrl"];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteResource(resource.id),
                              ),
                              onTap: () async {
                                if (await canLaunchUrl(Uri.parse(fileUrl))) {
                                  await launchUrl(Uri.parse(fileUrl));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Could not open file.");
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
