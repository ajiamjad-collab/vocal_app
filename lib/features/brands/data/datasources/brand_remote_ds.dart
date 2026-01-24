import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:vocal_app/core/firebase/functions_client.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';

import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<({List<BrandModel> items, DocumentSnapshot? lastDoc, bool hasMore})>
      getBrandsPage({
    required BrandCategory category,
    required int limit,
    required String searchToken,
    DocumentSnapshot? startAfter,
  });

  Stream<BrandModel> watchBrand(String brandId);

  /// ✅ Watch list (used by BrandListBloc)
  Stream<List<BrandModel>> watchBrands({
    required String category, // 'personal' | 'professional'
    String? searchToken,
  });

  Future<String> createBrand({
    required String title,
    required String description,
    required BrandCategory category,
    required Map<String, dynamic> uiRefs,
    required Map<String, dynamic> payloadExtended,
    required Uint8List? logoBytes,
    required String? logoFileName,
    required String? logoContentType,
  });

  Future<void> setBrandMedia({
    required String brandId,
    String? logoUrl,
    String? coverUrl,
  });

  Future<void> incrementVisit(String brandId);
}

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final FirebaseFirestore firestore;
  final FunctionsClient functions;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  BrandRemoteDataSourceImpl({
    required this.firestore,
    required this.functions,
    required this.storage,
    required this.auth,
  });

  CollectionReference<Map<String, dynamic>> get _brands =>
      firestore.collection('brands');

  @override
  Future<({List<BrandModel> items, DocumentSnapshot? lastDoc, bool hasMore})>
      getBrandsPage({
    required BrandCategory category,
    required int limit,
    required String searchToken,
    DocumentSnapshot? startAfter,
  }) async {
    final token = searchToken.trim().toLowerCase();

    Query<Map<String, dynamic>> q = _brands.where(
      'category',
      isEqualTo: category.wire, // ✅ FIXED
    );

    if (token.isNotEmpty) {
      q = q.where('searchTokens', arrayContains: token);
    }

    q = q.orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    final snap = await q.get(const GetOptions(source: Source.serverAndCache));
    final docs = snap.docs;

    final items = docs.map((d) => BrandModel.fromDoc(d)).toList();
    final last = docs.isEmpty ? null : docs.last;
    final hasMore = docs.length == limit;

    return (items: items, lastDoc: last, hasMore: hasMore);
  }

  @override
  Stream<BrandModel> watchBrand(String brandId) {
    return _brands.doc(brandId).snapshots().map((doc) {
      final d = doc.data();
      if (d == null) throw StateError('Brand not found');
      return BrandModel.fromDoc(doc);
    });
  }

  @override
  Stream<List<BrandModel>> watchBrands({
    required String category,
    String? searchToken,
  }) {
    Query<Map<String, dynamic>> q = _brands.where('category', isEqualTo: category);

    final token = (searchToken ?? '').trim().toLowerCase();
    if (token.isNotEmpty) {
      q = q.where('searchTokens', arrayContains: token);
    }

    q = q.orderBy('createdAt', descending: true);

    return q.snapshots().map((snap) {
      return snap.docs.map((d) => BrandModel.fromDoc(d)).toList();
    });
  }

  @override
  Future<String> createBrand({
    required String title,
    required String description,
    required BrandCategory category,
    required Map<String, dynamic> uiRefs,
    required Map<String, dynamic> payloadExtended,
    required Uint8List? logoBytes,
    required String? logoFileName,
    required String? logoContentType,
  }) async {
    if (auth.currentUser == null) {
      throw StateError('Not signed in');
    }

    final res = await functions.call<Map<dynamic, dynamic>>(
      'createBrand',
      data: <String, dynamic>{
        'title': title,
        'description': description,
        'category': category.wire, // ✅ FIXED
        'uiRefs': uiRefs,
        ...payloadExtended,
      },
    );

    final brandId = (res['brandId'] ?? '').toString();
    if (brandId.isEmpty) {
      throw StateError('createBrand failed: missing brandId');
    }

    // Optional: direct logo upload (if you pass bytes)
    if (logoBytes != null && logoBytes.isNotEmpty) {
      final upload = (res['upload'] as Map?) ?? {};
      final logoPath =
          (upload['logoPath'] ?? 'brand_images/$brandId/logo.jpg').toString();

      final ref = storage.ref().child(logoPath);

      await ref.putData(
        logoBytes,
        SettableMetadata(
          contentType: logoContentType ?? 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
          customMetadata: {
            'brandId': brandId,
            'uploader': auth.currentUser!.uid,
            if (logoFileName != null) 'fileName': logoFileName,
          },
        ),
      );

      final url = await ref.getDownloadURL();
      await setBrandMedia(brandId: brandId, logoUrl: url);
    }

    return brandId;
  }

  @override
  Future<void> setBrandMedia({
    required String brandId,
    String? logoUrl,
    String? coverUrl,
  }) async {
    final payload = <String, dynamic>{'brandId': brandId};

    final l = (logoUrl ?? '').trim();
    final c = (coverUrl ?? '').trim();

    if (l.isNotEmpty) payload['logoUrl'] = l;
    if (c.isNotEmpty) payload['coverUrl'] = c;

    await functions.call<Map<dynamic, dynamic>>(
      'setBrandMedia',
      data: payload,
    );
  }

  @override
  Future<void> incrementVisit(String brandId) async {
    await functions.call<Map<dynamic, dynamic>>(
      'incrementBrandVisit',
      data: {'brandId': brandId},
    );
  }
}
