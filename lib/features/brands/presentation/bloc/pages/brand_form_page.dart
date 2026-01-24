import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:vocal_app/core/di/service_locator.dart';
import 'package:vocal_app/core/firebase/functions_client.dart';
import 'package:vocal_app/core/media/helpers/image_helper.dart';
import 'package:vocal_app/core/media/rules/image_rules.dart';
import 'package:vocal_app/core/media/upload/firebase_media_uploader.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';
import 'package:vocal_app/features/brands/domain/repositories/brand_repository.dart';

class BrandFormPage extends StatefulWidget {
  const BrandFormPage({super.key});

  @override
  State<BrandFormPage> createState() => _BrandFormPageState();
}

class _BrandFormPageState extends State<BrandFormPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  int _cat = 0; // 0 personal, 1 professional
  bool _loading = false;

  File? _logoFile;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final f = await ImageHelper.pickImage(
      fromCamera: false,
      useCase: ImageUseCase.logo,
      getContext: () => mounted ? context : null,
    );
    if (f == null) return;
    setState(() => _logoFile = f);
  }

  Map<String, dynamic> _defaultContacts() => <String, dynamic>{
        'phones': <dynamic>[],
        'whatsapps': <dynamic>[],
        'emails': <dynamic>[],
        'websites': <dynamic>[],
      };

  Map<String, dynamic> _defaultSocial() => <String, dynamic>{
        'instagram': <dynamic>[],
        'facebook': <dynamic>[],
        'youtube': <dynamic>[],
        'linkedin': <dynamic>[],
      };

  Map<String, dynamic> _defaultWorkingHours() => <String, dynamic>{
        'Mon': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Tue': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Wed': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Thu': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Fri': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Sat': {'isClosed': false, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
        'Sun': {'isClosed': true, 'open': {'h': 9, 'm': 0}, 'close': {'h': 18, 'm': 0}},
      };

  Future<void> _submit() async {
    final title = _title.text.trim();
    final desc = _desc.text.trim();
    if (title.length < 2 || desc.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid title & description')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = sl<BrandRepository>();
      final functions = sl<FunctionsClient>();

      final BrandCategory category = _cat == 0 ? BrandCategory.personal : BrandCategory.professional;

      // uiRefs: keep minimal and extend later (theme colors etc.)
      final uiRefs = <String, dynamic>{
        'createdFrom': 'brand_form_v1',
      };

      // ✅ Provide required schema defaults (you can expand later in UI)
      final contacts = _defaultContacts();
      final socialMedia = _defaultSocial();
      final location = <String, dynamic>{};
      final branches = <Map<String, dynamic>>[];
      final workingHours = _defaultWorkingHours();
      const showWorkingHours = true;

      final tags = <String>[];
      final languagesKnown = <String>[];
      final categories = <String>[];
      final subCategories = <String>[];

      const businessType = 'Other';
      final offeringsTypes = <String>['products'];
      final serviceModes = <String>['Online'];
      const customerType = 'B2C';
      const companyType = 'Sole Proprietorship';
      final companyFounded = '${DateTime.now().year}';
      const String? gstNumber = null;

      // ✅ We are NOT uploading logo bytes anymore (you upload via Storage).
      // So pass nulls for logoBytes/fileName/contentType.
      final brandId = await repo.createBrand(
        title: title,
        description: desc,
        category: category,
        uiRefs: uiRefs,
        contacts: contacts,
        socialMedia: socialMedia,
        location: location,
        branches: branches,
        workingHours: workingHours,
        showWorkingHours: showWorkingHours,
        tags: tags,
        languagesKnown: languagesKnown,
        categories: categories,
        subCategories: subCategories,
        businessType: businessType,
        offeringsTypes: offeringsTypes,
        serviceModes: serviceModes,
        customerType: customerType,
        companyType: companyType,
        companyFounded: companyFounded,
        gstNumber: gstNumber,
        logoBytes: null,
        logoFileName: null,
        logoContentType: null,
      );

      // 2) Upload logo if provided
      if (_logoFile != null) {
        final path = 'brand_images/$brandId/logo.jpg';
        final uploader = FirebaseMediaUploader(storage: FirebaseStorage.instance);

        final logoUrl = await uploader.uploadFile(
          file: _logoFile!,
          storagePath: path,
          contentType: 'image/jpeg',
        );

        // 3) Save logo URL via function (server authoritative)
        await repo.setBrandMedia(brandId: brandId, logoUrl: logoUrl);
      }

      // optional: increment visit
      await functions.call<Map<String, dynamic>>(
        'incrementBrandVisit',
        data: {'brandId': brandId},
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Brand')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Brand Category', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Personal')),
                ButtonSegment(value: 1, label: Text('Professional')),
              ],
              selected: {_cat},
              onSelectionChanged: _loading ? null : (s) => setState(() => _cat = s.first),
            ),
            const SizedBox(height: 14),

            const Text('Logo', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.black12,
                  backgroundImage: _logoFile == null ? null : FileImage(_logoFile!),
                  child: _logoFile == null ? const Icon(Icons.add_photo_alternate) : null,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _pickLogo,
                  icon: const Icon(Icons.upload),
                  label: const Text('Pick Logo'),
                ),
              ],
            ),

            const SizedBox(height: 18),
            TextField(
              controller: _title,
              enabled: !_loading,
              decoration: const InputDecoration(
                labelText: 'Brand Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              enabled: !_loading,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Brand Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Create Brand', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
