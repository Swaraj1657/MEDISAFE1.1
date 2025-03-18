import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FileItem {
  String name;
  String documentType;
  DateTime uploadTime;
  String? filePath; // Store the file path

  FileItem({
    required this.name,
    required this.documentType,
    required this.uploadTime,
    this.filePath,
  });

  // Convert FileItem to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'documentType': documentType,
    'uploadTime': uploadTime.toIso8601String(),
    'filePath': filePath,
  };

  // Create FileItem from JSON
  factory FileItem.fromJson(Map<String, dynamic> json) => FileItem(
    name: json['name'],
    documentType: json['documentType'],
    uploadTime: DateTime.parse(json['uploadTime']),
    filePath: json['filePath'],
  );
}

class Fileupload extends StatelessWidget {
  const Fileupload({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Picker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Upload Documents'),
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
  late SharedPreferences _prefs;
  List<FileItem> uploadedFiles = [];
  String selectedFileName = '';
  String selectedDocumentType = 'Prescription';
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _textController = TextEditingController();
  bool isUploading = false;

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
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    _prefs = await SharedPreferences.getInstance();
    final filesJson = _prefs.getStringList('uploadedFiles') ?? [];

    setState(() {
      uploadedFiles =
          filesJson.map((item) => FileItem.fromJson(jsonDecode(item))).toList();
    });
  }

  Future<void> _saveFiles() async {
    final filesJson =
        uploadedFiles.map((item) => jsonEncode(item.toJson())).toList();
    await _prefs.setStringList('uploadedFiles', filesJson);
  }

  Future<void> pickFile() async {
    if (selectedDocumentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify document type first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => isUploading = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          selectedFileName = result.files.first.name;
          final fileItem = FileItem(
            name: selectedFileName,
            documentType: selectedDocumentType,
            uploadTime: DateTime.now(),
            filePath: result.files.first.path,
          );
          uploadedFiles.add(fileItem);
          _saveFiles(); // Save after adding new file
          isUploading = false;
          _textController.clear();
          selectedDocumentType = '';
        });
        _controller.forward(from: 0);
      } else {
        setState(() => isUploading = false);
      }
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewFile(FileItem file) async {
    try {
      final String extension = path.extension(file.name).toLowerCase();

      if (['.jpg', '.jpeg', '.png'].contains(extension)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: Colors.blue,
                    title: Text(file.documentType),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Image.file(File(file.filePath!), fit: BoxFit.contain),
                ],
              ),
            );
          },
        );
      } else if (extension == '.pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening PDF file...'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${file.documentType}...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _showFilePreview(FileItem file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileIcon(file.documentType),
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  file.documentType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Uploaded',
                        _formatDateTime(file.uploadTime),
                      ),
                      const Divider(height: 16),
                      _buildInfoRow('Status', 'Verified'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _viewFile(file);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return Icons.medical_information;
      case 'report':
        return Icons.description;
      case 'id card':
        return Icons.credit_card;
      case 'certificate':
        return Icons.card_membership;
      default:
        return Icons.insert_drive_file;
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
            fontSize: 20,
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
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(24.0),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload Your Documents',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'Enter document type',
                              hintStyle: TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.document_scanner,
                                color: Colors.blue.shade300,
                                size: 20,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedDocumentType = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedDocumentType.isEmpty
                              ? 'Please specify document type'
                              : 'Upload your ${selectedDocumentType.toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: isUploading ? null : pickFile,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                isUploading
                                    ? const CircularProgressIndicator()
                                    : Column(
                                      children: [
                                        Icon(
                                          Icons.file_upload_outlined,
                                          size: 36,
                                          color: Colors.blue.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Click to browse files',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'or drag and drop here',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (uploadedFiles.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Uploaded Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: uploadedFiles.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final file = uploadedFiles[index];
                          return ListTile(
                            leading: Icon(
                              _getFileIcon(file.documentType),
                              color: Colors.blue,
                            ),
                            title: Text(
                              file.documentType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              'Uploaded: ${_formatDateTime(file.uploadTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _viewFile(file),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      uploadedFiles.removeAt(index);
                                      _saveFiles(); // Save after deleting file
                                    });
                                  },
                                ),
                              ],
                            ),
                            onTap: () => _viewFile(file),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
