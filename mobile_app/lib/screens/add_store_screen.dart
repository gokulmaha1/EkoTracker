import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  _AddStoreScreenState createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  
  File? _image;
  double? _lat;
  double? _lng;
  bool _isLoadingLocation = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, maxWidth: 800);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location fetched successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch location first')),
      );
      return;
    }

    try {
      final storeData = {
        'name': _nameController.text,
        'owner_name': _ownerController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'area': _areaController.text,
        'lat': _lat,
        'lng': _lng,
      };

      await Provider.of<StoreProvider>(context, listen: false)
          .createStore(storeData, _image?.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create store: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Store'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Tap to capture store image'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _lat != null 
                          ? 'Loc: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}' 
                          : 'Location not set',
                    ),
                  ),
                  IconButton(
                    icon: _isLoadingLocation 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: storeProvider.isLoading ? null : _submit,
                  child: storeProvider.isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text('Add Store'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
