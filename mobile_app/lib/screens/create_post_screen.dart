import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/timeline_provider.dart';
import '../providers/store_provider.dart';
import '../models/store_model.dart'; // Import Store model

class CreatePostScreen extends StatefulWidget {
  final int? storeId; // Pre-select store if coming from store details
  const CreatePostScreen({Key? key, this.storeId}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descriptionController = TextEditingController();
  File? _image;
  double? _lat;
  double? _lng;
  bool _isLoadingLocation = false;
  String _selectedType = 'visit';
  int? _selectedStoreId;

  // Type options
  final List<String> _types = ['visit', 'lead', 'follow_up', 'general'];

  @override
  void initState() {
    super.initState();
    _selectedStoreId = widget.storeId;
    _getCurrentLocation();
    // Fetch stores if not already loaded, needed for dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<StoreProvider>(context, listen: false).fetchStores();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxWidth: 800);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
        // ... (Similar location logic as AddStore, simplified for brevity)
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
            _lat = position.latitude;
            _lng = position.longitude;
        });
    } catch (e) {
        // Handle error
    } finally {
        setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_descriptionController.text.isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a description or photo')));
      return;
    }

    try {
      final postData = {
        'type': _selectedType,
        'description': _descriptionController.text,
        'gps_lat': _lat,
        'gps_lng': _lng,
        'store_id': _selectedStoreId,
      };

      await Provider.of<TimelineProvider>(context, listen: false).createPost(postData, _image?.path);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Post'), actions: [
        IconButton(onPressed: _submit, icon: const Icon(Icons.send))
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: const InputDecoration(labelText: 'Activity Type'),
            ),
            const SizedBox(height: 16),
            if (widget.storeId == null) // Show store picker if not pres-selected
                DropdownButtonFormField<int>(
                    value: _selectedStoreId,
                    items: storeProvider.stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => _selectedStoreId = v),
                    decoration: const InputDecoration(labelText: 'Select Store (Optional)'),
                ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What are you doing? (e.g. Meeting outcome, observations)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_image != null) 
                Stack(
                    children: [
                        Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                            right: 0,
                            child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white), 
                                onPressed: () => setState(() => _image = null)
                            )
                        )
                    ]
                ),
            TextButton.icon(
                onPressed: _pickImage, 
                icon: const Icon(Icons.camera_alt), 
                label: const Text('Add Photo')
            ),
            if (_isLoadingLocation) const LinearProgressIndicator(), 
          ],
        ),
      ),
    );
  }
}
