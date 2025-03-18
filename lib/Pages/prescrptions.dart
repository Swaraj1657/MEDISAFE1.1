import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Class to hold file information
class FileItem {
  final String name;
  final String path;
  final DateTime uploadTime;
  final String customName;

  FileItem({
    required this.name,
    required this.path,
    required this.uploadTime,
    required this.customName,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'uploadTime': uploadTime.toIso8601String(),
    'customName': customName,
  };

  // Create from JSON for loading
  factory FileItem.fromJson(Map<String, dynamic> json) => FileItem(
    name: json['name'],
    path: json['path'],
    uploadTime: DateTime.parse(json['uploadTime']),
    customName: json['customName'],
  );
}

class Prescrptions extends StatelessWidget {
  const Prescrptions({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prescription Upload',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Upload Your Prescription'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String? selectedFileName;
  String? selectedFilePath;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? uploadStatus;
  List<FileItem> uploadedFiles = [];
  late SharedPreferences _prefs;
  final TextEditingController _customNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _loadFiles();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    _prefs = await SharedPreferences.getInstance();
    final savedFiles = _prefs.getStringList('prescriptionFiles') ?? [];

    setState(() {
      uploadedFiles =
          savedFiles
              .map((item) => FileItem.fromJson(jsonDecode(item)))
              .toList();
    });
  }

  Future<void> _saveFiles() async {
    final filesList =
        uploadedFiles.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList('prescriptionFiles', filesList);
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;
        String fileName = result.files.single.name;

        // Validate file type
        if (!fileName.toLowerCase().endsWith('.jpg') &&
            !fileName.toLowerCase().endsWith('.jpeg') &&
            !fileName.toLowerCase().endsWith('.png')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select only JPG or PNG images'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          selectedFileName = fileName;
          selectedFilePath = filePath;
          uploadStatus = null;
        });
        _controller.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void deleteFile(int index) {
    setState(() {
      File(uploadedFiles[index].path).deleteSync();
      uploadedFiles.removeAt(index);
      _saveFiles();
    });
  }

  Future<void> uploadFile() async {
    if (selectedFilePath == null) {
      setState(() {
        uploadStatus = 'Please select a prescription image';
      });
      return;
    }

    if (_customNameController.text.isEmpty) {
      setState(() {
        uploadStatus = 'Please enter a name for the prescription';
      });
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
      uploadStatus = 'Uploading prescription...';
    });

    try {
      // Simulated upload process
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          uploadProgress = i / 100;
        });
      }

      // Add file to uploaded files list with custom name
      if (selectedFileName != null && selectedFilePath != null) {
        setState(() {
          uploadedFiles.add(
            FileItem(
              name: selectedFileName!,
              path: selectedFilePath!,
              uploadTime: DateTime.now(),
              customName: _customNameController.text,
            ),
          );
        });
        await _saveFiles();
      }

      setState(() {
        isUploading = false;
        uploadStatus = 'Upload completed successfully!';
        selectedFileName = null;
        selectedFilePath = null;
        _customNameController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        uploadStatus = 'Error: Failed to upload prescription';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24.0,
              24.0,
              24.0,
              MediaQuery.of(context).viewInsets.bottom + 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.medical_information_outlined,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Upload Your Prescription',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Please upload a clear image of your prescription (JPG or PNG)',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      InkWell(
                        onTap: isUploading ? null : pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.blue.shade300,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Click to browse images',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'or drag and drop here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Supported: JPG, PNG',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (selectedFileName != null)
                        Column(
                          children: [
                            FadeTransition(
                              opacity: _animation,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.image_outlined,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            'Selected: $selectedFileName',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _customNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Enter Prescription Name',
                                        hintText:
                                            'e.g., Blood Pressure Medicine',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: isUploading ? null : uploadFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isUploading)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    isUploading
                                        ? 'Uploading...'
                                        : 'Upload Prescription',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'No prescription selected',
                          style: TextStyle(color: Colors.black38, fontSize: 14),
                        ),
                    ],
                  ),
                ),
                if (isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: LinearProgressIndicator(
                      value: uploadProgress,
                      backgroundColor: Colors.blue.shade50,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                if (uploadStatus != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      uploadStatus!,
                      style: TextStyle(
                        color:
                            uploadStatus!.contains('successfully')
                                ? Colors.green
                                : uploadStatus!.contains('Please')
                                ? Colors.red
                                : Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (uploadedFiles.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Uploaded Prescriptions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: uploadedFiles.length,
                          itemBuilder: (context, index) {
                            final file = uploadedFiles[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.file(
                                      File(file.path),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                file.customName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Uploaded on ${file.uploadTime.day}/${file.uploadTime.month}/${file.uploadTime.year}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => deleteFile(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
