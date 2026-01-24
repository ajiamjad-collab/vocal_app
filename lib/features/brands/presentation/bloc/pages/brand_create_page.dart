import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';

import 'package:vocal_app/core/di/service_locator.dart';
import 'package:vocal_app/core/media/helpers/image_helper.dart';
import 'package:vocal_app/core/media/helpers/media_picker.dart';
import 'package:vocal_app/core/media/models/app_media.dart';
import 'package:vocal_app/features/brands/domain/entities/brand_category.dart';
import 'package:vocal_app/features/brands/presentation/bloc/brand_create_cubit.dart';

class BrandCreatePage extends StatelessWidget {
  const BrandCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BrandCreateCubit>(),
      child: const _BrandCreateView(),
    );
  }
}

// -------------------- helpers --------------------

class _LocationIndex {
  final Map<String, dynamic> raw;

  _LocationIndex(this.raw);

  List<String> getStates() => raw.keys.map((e) => e.toString()).toList()..sort();

  List<String> getDistricts(String state) {
    final st = raw[state];
    if (st is Map) {
      return st.keys.map((e) => e.toString()).toList()..sort();
    }
    return const [];
  }

  List<String> getCities(String state, String district) {
    final st = raw[state];
    if (st is Map) {
      final dist = st[district];
      if (dist is Map) {
        return dist.keys.map((e) => e.toString()).toList()..sort();
      }
    }
    return const [];
  }

  List<String> getPins(String state, String district, String city) {
    final st = raw[state];
    if (st is Map) {
      final dist = st[district];
      if (dist is Map) {
        final c = dist[city];
        if (c is List) {
          return c.map((e) => e.toString()).toList()..sort();
        }
        if (c != null) return [c.toString()];
      }
    }
    return const [];
  }
}

class _DayHours {
  final bool isClosed;
  final TimeOfDay open;
  final TimeOfDay close;

  const _DayHours({
    required this.isClosed,
    required this.open,
    required this.close,
  });

  factory _DayHours.defaultOpen() => const _DayHours(
        isClosed: false,
        open: TimeOfDay(hour: 9, minute: 0),
        close: TimeOfDay(hour: 18, minute: 0),
      );

  factory _DayHours.defaultClosed() => const _DayHours(
        isClosed: true,
        open: TimeOfDay(hour: 9, minute: 0),
        close: TimeOfDay(hour: 18, minute: 0),
      );

  _DayHours copyWith({bool? isClosed, TimeOfDay? open, TimeOfDay? close}) {
    return _DayHours(
      isClosed: isClosed ?? this.isClosed,
      open: open ?? this.open,
      close: close ?? this.close,
    );
  }

  Map<String, dynamic> toJson() => {
        'isClosed': isClosed,
        'open': {'h': open.hour, 'm': open.minute},
        'close': {'h': close.hour, 'm': close.minute},
      };
}

String? _validateFoundedYear(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Founded year required';
  final y = int.tryParse(s);
  if (y == null) return 'Enter valid year';
  final nowYear = DateTime.now().year;
  if (y >= nowYear) return 'Founded year must be less than $nowYear';
  if (y < 1800) return 'Enter valid year';
  return null;
}

String? _validateUrl(String? v, {List<String>? allowedHosts}) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri == null || !uri.isAbsolute || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return 'Enter a valid URL (https://...)';
  }
  if (allowedHosts != null && allowedHosts.isNotEmpty) {
    final host = uri.host.toLowerCase();
    final ok = allowedHosts.any((h) => host == h || host.endsWith('.$h'));
    if (!ok) return 'URL must be from: ${allowedHosts.join(', ')}';
  }
  return null;
}

String? _validateEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return null;
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
  return ok ? null : 'Enter valid email';
}

String? _validatePhone(String? v, {bool required = false}) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return required ? 'Phone required' : null;
  if (!RegExp(r'^[0-9]{7,15}$').hasMatch(s)) return 'Enter valid phone (7-15 digits)';
  return null;
}

// -------------------- page --------------------

class _BrandCreateView extends StatefulWidget {
  const _BrandCreateView();

  @override
  State<_BrandCreateView> createState() => _BrandCreateViewState();
}

class _BrandCreateViewState extends State<_BrandCreateView> {
  final _formKey = GlobalKey<FormState>();

  // required
  final _title = TextEditingController();
  final _desc = TextEditingController();

  // professional only
  final BrandCategory _category = BrandCategory.professional;

  // logo
  Uint8List? _logoBytes;
  String? _logoFileName;
  String? _logoContentType;
  bool _isCropping = false;

  // contacts (allow +2 more => total 3)
  static const int _maxMulti = 3;
  final List<TextEditingController> _phones = [TextEditingController()];
  final List<TextEditingController> _whatsapps = [TextEditingController()];
  final List<TextEditingController> _emails = [TextEditingController()];
  final _website = TextEditingController();

  // social
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _youtube = TextEditingController();
  final _linkedin = TextEditingController();

  // location extra
  final _digiPin = TextEditingController();
  final _googleMapUrl = TextEditingController();
  String _mainType = '';
  final _mainName = TextEditingController();

  // dropdown location (mandatory)
  _LocationIndex? _locIndex;
  bool _locLoading = true;

  String? _state;
  String? _district;
  String? _city;
  String? _pin;

  List<String> _states = const [];
  List<String> _districts = const [];
  List<String> _cities = const [];
  List<String> _pins = const [];

  // business
  final _businessTypeOther = TextEditingController();
  String _businessType = 'Other';

  String _customerType = 'B2C';
  String _companyType = 'Sole Proprietorship';
  final _companyFounded = TextEditingController(text: '${DateTime.now().year - 1}');
  final _gst = TextEditingController();

  // offerings & service modes (multi select)
  final Set<String> _offeringsTypes = {'products'};
  final Set<String> _serviceModes = {'Online'};

  // "Other" custom (3 single-word)
  final _offOther1 = TextEditingController();
  final _offOther2 = TextEditingController();
  final _offOther3 = TextEditingController();

  final _srvOther1 = TextEditingController();
  final _srvOther2 = TextEditingController();
  final _srvOther3 = TextEditingController();

  // tags chips
  final _tagInput = TextEditingController();
  final List<String> _tags = [];

  // languages
  bool _showLanguagesKnown = true;
  final Set<String> _languages = {'English'};

  // categories/subCategories
  final _categoryInput = TextEditingController();
  final _subCategoryInput = TextEditingController();
  final List<String> _categories = [];
  final List<String> _subCategories = [];

  // working hours (editable)
  bool _showWorkingHours = true;
  final Map<String, _DayHours> _workingHours = {
    'Mon': _DayHours.defaultOpen(),
    'Tue': _DayHours.defaultOpen(),
    'Wed': _DayHours.defaultOpen(),
    'Thu': _DayHours.defaultOpen(),
    'Fri': _DayHours.defaultOpen(),
    'Sat': _DayHours.defaultOpen(),
    'Sun': _DayHours.defaultClosed(),
  };

  // branches (kept for old payload compatibility)
  final List<Map<String, dynamic>> _branches = [];

  final mainLocationTypes = const ['', 'Main Branch', 'Main Store', 'Main Office'];

  final businessTypes = const [
    'Seller',
    'Service Provider',
    'Farmer',
    'Hospital / Clinic',
    'Hotel / Resort',
    'Mall / Shopping Center',
    'Restaurant / Cafe',
    'Grocery / Supermarket',
    'Pharmacy',
    'Electronics Store',
    'Fashion / Boutique',
    'Beauty / Salon / Spa',
    'Fitness / Gym',
    'Education / Coaching',
    'Real Estate',
    'Transport / Logistics',
    'Automobile / Garage',
    'Construction / Hardware',
    'Home Services (Plumber/Electrician/etc.)',
    'IT / Software / Digital Agency',
    'Manufacturing',
    'Wholesale / Distributor',
    'NGO',
    'Other',
  ];

  final offeringsTypes = const [
    'products',
    'services',
    'appointments',
    'rooms',
    'menu',
    'rentals',
    'leads_only',
    'other',
  ];

  final serviceModesList = const [
    'In-store',
    'At-home',
    'Online',
    'On-site',
    'Delivery',
    'Pickup',
    'Doorstep Service',
    'Remote Support',
    'Teleconsultation',
    'Home Visit',
    'Subscription',
    'Membership',
    'Rental Service',
    'Installation',
    'Maintenance',
    'Repair',
    'Emergency / 24x7',
    'Appointment Only',
    'Walk-in',
    'Pre-order',
    'Curbside',
    'Event / Venue Service',
    'Bulk / Enterprise',
    'Pan-India',
    'International',
    'Other',
  ];

  final customerTypes = const ['B2C', 'B2B', 'Both'];

  final companyTypes = const [
    'Sole Proprietorship',
    'HUF (Hindu Undivided Family)',
    'Partnership Firm',
    'Limited Liability Partnership (LLP)',
    'One Person Company (OPC)',
    'Private Limited Company',
    'Public Limited Company',
    'Section 8 Company (Non-profit)',
    'Trust',
    'Society',
    'Co-operative Society',
    'Producer Company',
    'Nidhi Company',
    'Government Entity',
    'PSU (Public Sector Undertaking)',
    'Foreign Company',
    'Branch Office',
    'Liaison Office',
    'Subsidiary',
    'Startup',
    'NGO',
    'Other',
  ];

  final Map<String, String> indianLanguagesNative = const {
    'English': 'English',
    'Hindi': 'हिन्दी',
    'Bengali': 'বাংলা',
    'Telugu': 'తెలుగు',
    'Marathi': 'मराठी',
    'Tamil': 'தமிழ்',
    'Urdu': 'اردو',
    'Gujarati': 'ગુજરાતી',
    'Kannada': 'ಕನ್ನಡ',
    'Odia': 'ଓଡ଼ିଆ',
    'Malayalam': 'മലയാളം',
    'Punjabi': 'ਪੰਜਾਬੀ',
    'Assamese': 'অসমীয়া',
    'Maithili': 'मैथिली',
    'Santali': 'ᱥᱟᱱᱛᱟᱲᱤ',
    'Kashmiri': 'कॉशुर / كٲشُر',
    'Nepali': 'नेपाली',
    'Konkani': 'कोंकणी',
    'Sindhi': 'سنڌي / सिन्धी',
    'Dogri': 'डोगरी',
    'Manipuri (Meitei)': 'মৈতৈলোন্',
    'Bodo': 'बड़ो',
    'Sanskrit': 'संस्कृतम्',
  };

  @override
  void initState() {
    super.initState();
    _loadLocationJson();
  }

  Future<void> _loadLocationJson() async {
    try {
      final raw = await rootBundle.loadString('assets/pincodes/pincode_in.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _locIndex = _LocationIndex(map);
      _states = _locIndex!.getStates();
    } catch (_) {
      _locIndex = null;
      _states = const [];
    }
    if (!mounted) return;
    setState(() => _locLoading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();

    for (final c in _phones) {
      c.dispose();
    }
    for (final c in _whatsapps) {
      c.dispose();
    }
    for (final c in _emails) {
      c.dispose();
    }
    _website.dispose();

    _instagram.dispose();
    _facebook.dispose();
    _youtube.dispose();
    _linkedin.dispose();

    _digiPin.dispose();
    _googleMapUrl.dispose();
    _mainName.dispose();

    _businessTypeOther.dispose();
    _companyFounded.dispose();
    _gst.dispose();

    _offOther1.dispose();
    _offOther2.dispose();
    _offOther3.dispose();
    _srvOther1.dispose();
    _srvOther2.dispose();
    _srvOther3.dispose();

    _tagInput.dispose();
    _categoryInput.dispose();
    _subCategoryInput.dispose();

    super.dispose();
  }

  // -------------------- logo pick --------------------

  Future<void> _pickLogo() async {
    if (_isCropping) return;
    _isCropping = true;

    try {
      final picked = await MediaPicker.pick(
        kind: MediaKind.image,
        allowMultiple: false,
        fromCamera: false,
      );
      if (picked.isEmpty) return;

      final AppMedia media = picked.first;

      final cropped = await ImageHelper.crop(
        getContext: () => mounted ? context : null,
        media: media,
        enable: true,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        toolbarTitle: 'Crop Logo',
      );

      final finalMedia = cropped ?? media;
      final bytes = await finalMedia.readBytes();

      if (!mounted) return;
      setState(() {
        _logoBytes = bytes;
        _logoFileName = finalMedia.name;
        _logoContentType = lookupMimeType(finalMedia.name) ?? 'image/jpeg';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logo pick failed: $e')));
    } finally {
      _isCropping = false;
    }
  }

  // -------------------- dropdown handlers --------------------

  void _onStateChanged(String? v) {
    setState(() {
      _state = v;
      _district = null;
      _city = null;
      _pin = null;

      _districts = (v != null && _locIndex != null) ? _locIndex!.getDistricts(v) : const [];
      _cities = const [];
      _pins = const [];
    });
  }

  void _onDistrictChanged(String? v) {
    setState(() {
      _district = v;
      _city = null;
      _pin = null;

      _cities = (_state != null && v != null && _locIndex != null) ? _locIndex!.getCities(_state!, v) : const [];
      _pins = const [];
    });
  }

  void _onCityChanged(String? v) {
    setState(() {
      _city = v;
      _pin = null;

      _pins = (_state != null && _district != null && v != null && _locIndex != null)
          ? _locIndex!.getPins(_state!, _district!, v)
          : const [];
    });
  }

  // -------------------- chips helpers --------------------

  void _addSingleWordChip(TextEditingController input, List<String> target) {
    final t = input.text.trim();
    if (t.isEmpty) return;

    final normalized = t.replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only single word allowed')));
      return;
    }
    if (target.contains(normalized)) {
      input.clear();
      return;
    }
    setState(() {
      target.add(normalized);
      input.clear();
    });
  }

  void _removeChip(List<String> target, String v) {
    setState(() => target.remove(v));
  }

  // -------------------- contacts multi add --------------------

  Widget _multiInputSection({
    required String title,
    required List<TextEditingController> controllers,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        ...List.generate(controllers.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[i],
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      labelText: controllers.length == 1 ? label : '$label ${i + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: validator,
                  ),
                ),
                const SizedBox(width: 8),
                if (controllers.length > 1)
                  IconButton(
                    onPressed: () => setState(() {
                      controllers.removeAt(i).dispose();
                    }),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: controllers.length >= _maxMulti ? null : () => setState(() => controllers.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: Text('Add ${title.toLowerCase()}'),
          ),
        ),
      ],
    );
  }

  // -------------------- build payload --------------------

  Map<String, dynamic> _contactsPayload() {
    final phones = _phones.map((c) => c.text.trim()).where((v) => v.isNotEmpty).toList();
    final whats = _whatsapps.map((c) => c.text.trim()).where((v) => v.isNotEmpty).toList();
    final emails = _emails.map((c) => c.text.trim()).where((v) => v.isNotEmpty).toList();

    return {
      'phones': phones.map((n) => {'countryCode': '+91', 'number': n}).toList(),
      'whatsapps': whats.map((n) => {'countryCode': '+91', 'number': n}).toList(),
      'emails': emails,
      'websites': _website.text.trim().isEmpty ? <dynamic>[] : <dynamic>[_website.text.trim()],
    };
  }

  Map<String, dynamic> _socialPayload() => {
        'instagram': _instagram.text.trim().isEmpty ? <dynamic>[] : <dynamic>[_instagram.text.trim()],
        'facebook': _facebook.text.trim().isEmpty ? <dynamic>[] : <dynamic>[_facebook.text.trim()],
        'youtube': _youtube.text.trim().isEmpty ? <dynamic>[] : <dynamic>[_youtube.text.trim()],
        'linkedin': _linkedin.text.trim().isEmpty ? <dynamic>[] : <dynamic>[_linkedin.text.trim()],
      };

  Map<String, dynamic> _locationPayload() => {
        'state': _state ?? '',
        'district': _district ?? '',
        'city': _city ?? '',
        'pin': _pin ?? '',
        'digiPin': _digiPin.text.trim(),
        'googleMapUrl': _googleMapUrl.text.trim(),
        'main': {'type': _mainType.trim(), 'name': _mainName.text.trim()},
      };

  Map<String, dynamic> _workingHoursPayload() {
    final out = <String, dynamic>{};
    for (final e in _workingHours.entries) {
      out[e.key] = e.value.toJson();
    }
    return out;
  }

  List<String> _offeringsFinal() {
    final base = _offeringsTypes.toList();
    if (_offeringsTypes.contains('other')) {
      for (final c in [_offOther1, _offOther2, _offOther3]) {
        final t = c.text.trim().toLowerCase();
        if (t.isNotEmpty) base.add(t);
      }
    }
    return base;
  }

  List<String> _serviceModesFinal() {
    final base = _serviceModes.toList();
    if (_serviceModes.contains('Other')) {
      for (final c in [_srvOther1, _srvOther2, _srvOther3]) {
        final t = c.text.trim();
        if (t.isNotEmpty) base.add(t);
      }
    }
    return base;
  }

  // -------------------- submit --------------------

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_state == null || _district == null || _city == null || _pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('State, District, City, PIN are required')));
      return;
    }

    await context.read<BrandCreateCubit>().submit(
          title: _title.text.trim(),
          description: _desc.text.trim(),
          category: _category,
          uiRefs: {'createdFrom': 'brand_create_professional'},

          contacts: _contactsPayload(),
          socialMedia: _socialPayload(),
          location: _locationPayload(),
          branches: _branches,
          workingHours: _workingHoursPayload(),
          showWorkingHours: _showWorkingHours,

          tags: _tags,
          languagesKnown: _showLanguagesKnown ? _languages.toList() : <String>[],
          categories: _categories,
          subCategories: _subCategories,

          businessType: _businessType == 'Other' ? _businessTypeOther.text.trim() : _businessType,
          offeringsTypes: _offeringsFinal(),
          serviceModes: _serviceModesFinal(),
          customerType: _customerType,

          companyType: _companyType,
          companyFounded: _companyFounded.text.trim(),
          gstNumber: _gst.text.trim().isEmpty ? null : _gst.text.trim(),

          logoBytes: _logoBytes?.toList(),
          logoFileName: _logoFileName,
          logoContentType: _logoContentType,
        );

    if (!mounted) return;

    final st = context.read<BrandCreateCubit>().state;
    if (st.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(st.error!)));
      return;
    }
    if (st.brandId != null) {
      Navigator.of(context).pop(true);
    }
  }

  // -------------------- UI widgets --------------------

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
      );

  Future<void> _pickTime(String day, {required bool isOpen}) async {
    final current = _workingHours[day]!;
    final initial = isOpen ? current.open : current.close;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpen ? 'Select opening time' : 'Select closing time',
    );
    if (picked == null) return;

    final updated = isOpen ? current.copyWith(open: picked) : current.copyWith(close: picked);

    if (!updated.isClosed) {
      final openMin = updated.open.hour * 60 + updated.open.minute;
      final closeMin = updated.close.hour * 60 + updated.close.minute;
      if (closeMin <= openMin) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Close time must be after open time')));
        return;
      }
    }

    setState(() => _workingHours[day] = updated);
  }

  Widget _workingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Working Hours'),
        SwitchListTile(
          value: _showWorkingHours,
          onChanged: (v) => setState(() => _showWorkingHours = v),
          title: const Text('Show Working Hours'),
          contentPadding: EdgeInsets.zero,
        ),
        if (_showWorkingHours)
          ..._workingHours.entries.map((e) {
            final day = e.key;
            final hours = e.value;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(day, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Switch(
                          value: hours.isClosed,
                          onChanged: (v) => setState(() => _workingHours[day] = hours.copyWith(isClosed: v)),
                        ),
                        Text(hours.isClosed ? 'Closed' : 'Open'),
                      ],
                    ),
                    if (!hours.isClosed)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickTime(day, isOpen: true),
                              child: Text('Open: ${hours.open.format(context)}'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickTime(day, isOpen: false),
                              child: Text('Close: ${hours.close.format(context)}'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _chipInput({
    required String title,
    required TextEditingController input,
    required List<String> values,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: input,
                decoration: InputDecoration(labelText: hint, border: const OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: onAdd, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map((t) => Chip(
                    label: Text(t),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeChip(values, t),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _multiSelectChips({
    required String title,
    required List<String> items,
    required Set<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) {
            final isSel = selected.contains(it);
            return FilterChip(
              label: Text(it),
              selected: isSel,
              onSelected: (v) => setState(() {
                if (v) {
                  selected.add(it);
                } else {
                  selected.remove(it);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _otherTripleRow({
    required String label,
    required TextEditingController c1,
    required TextEditingController c2,
    required TextEditingController c3,
  }) {
    InputDecoration deco(String hint) => InputDecoration(labelText: hint, border: const OutlineInputBorder());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: TextField(controller: c1, decoration: deco('Other 1'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: c2, decoration: deco('Other 2'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: c3, decoration: deco('Other 3'))),
          ],
        ),
      ],
    );
  }

  Widget _locationDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: '$label *', border: const OutlineInputBorder()),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Professional Brand')),
      body: BlocBuilder<BrandCreateCubit, BrandCreateState>(
        builder: (_, s) {
          return AbsorbPointer(
            absorbing: s.loading,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // LOGO
                  Center(
                    child: InkWell(
                      onTap: _pickLogo,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.grey.shade200,
                            child: _logoBytes == null
                                ? const Icon(Icons.add_a_photo)
                                : ClipOval(
                                    child: Image.memory(_logoBytes!, width: 104, height: 104, fit: BoxFit.cover),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _logoBytes == null ? 'Add your logo' : 'Change logo',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // BASIC
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Brand Title *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 5) ? 'Enter description' : null,
                  ),

                  // CONTACTS (multi add)
                  _multiInputSection(
                    title: 'Phones',
                    controllers: _phones,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validatePhone(v),
                  ),
                  _multiInputSection(
                    title: 'WhatsApps',
                    controllers: _whatsapps,
                    label: 'WhatsApp',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validatePhone(v),
                  ),
                  _multiInputSection(
                    title: 'Emails',
                    controllers: _emails,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  _sectionTitle('Website'),
                  TextFormField(
                    controller: _website,
                    decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v),
                  ),

                  // SOCIAL
                  _sectionTitle('Social'),
                  TextFormField(
                    controller: _instagram,
                    decoration: const InputDecoration(labelText: 'Instagram', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v, allowedHosts: const ['instagram.com']),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _facebook,
                    decoration: const InputDecoration(labelText: 'Facebook', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v, allowedHosts: const ['facebook.com', 'fb.com']),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _youtube,
                    decoration: const InputDecoration(labelText: 'YouTube', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v, allowedHosts: const ['youtube.com', 'youtu.be']),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _linkedin,
                    decoration: const InputDecoration(labelText: 'LinkedIn', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v, allowedHosts: const ['linkedin.com']),
                  ),

                  // LOCATION (MANDATORY DROPDOWNS)
                  _sectionTitle('Location (Mandatory)'),
                  if (_locLoading) const LinearProgressIndicator(),
                  if (!_locLoading && _locIndex == null)
                    const Text('Failed to load pincode JSON. Check assets path in pubspec.yaml.'),
                  if (!_locLoading && _locIndex != null) ...[
                    _locationDropdown(label: 'State', value: _state, items: _states, onChanged: _onStateChanged),
                    const SizedBox(height: 10),
                    _locationDropdown(label: 'District', value: _district, items: _districts, onChanged: _onDistrictChanged),
                    const SizedBox(height: 10),
                    _locationDropdown(label: 'City', value: _city, items: _cities, onChanged: _onCityChanged),
                    const SizedBox(height: 10),
                    _locationDropdown(label: 'PIN', value: _pin, items: _pins, onChanged: (v) => setState(() => _pin = v)),
                  ],
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _digiPin,
                    decoration: const InputDecoration(labelText: 'DigiPin (optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _googleMapUrl,
                    decoration: const InputDecoration(labelText: 'Google Map URL (optional)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.url,
                    validator: (v) => _validateUrl(v),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _mainType,
                    items: mainLocationTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.isEmpty ? '(None)' : e)))
                        .toList(),
                    onChanged: (v) => setState(() => _mainType = v ?? ''),
                    decoration: const InputDecoration(labelText: 'Main Location Type', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _mainName,
                    decoration: const InputDecoration(labelText: 'Main Location Name', border: OutlineInputBorder()),
                  ),

                  // BUSINESS
                  _sectionTitle('Business'),
                  DropdownButtonFormField<String>(
                    initialValue: _businessType,
                    items: businessTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _businessType = v ?? 'Other'),
                    decoration: const InputDecoration(labelText: 'Business Type *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  if (_businessType == 'Other') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _businessTypeOther,
                      decoration: const InputDecoration(labelText: 'Business Type (Other) *', border: OutlineInputBorder()),
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Required';
                        final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
                        if (words.length > 3) return 'Max 3 words';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _customerType,
                    items: customerTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _customerType = v ?? 'B2C'),
                    decoration: const InputDecoration(labelText: 'Customer Type *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _companyType,
                    items: companyTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _companyType = v ?? companyTypes.first),
                    decoration: const InputDecoration(labelText: 'Company Type *', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _companyFounded,
                    decoration: const InputDecoration(labelText: 'Founded Year *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateFoundedYear,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _gst,
                    decoration: const InputDecoration(labelText: 'GST Number (optional)', border: OutlineInputBorder()),
                  ),

                  // OFFERINGS
                  _multiSelectChips(title: 'Offerings Types', items: offeringsTypes, selected: _offeringsTypes),
                  if (_offeringsTypes.contains('other'))
                    _otherTripleRow(label: 'Offerings (Other) - single words', c1: _offOther1, c2: _offOther2, c3: _offOther3),

                  // SERVICE MODES
                  _multiSelectChips(title: 'Service Modes', items: serviceModesList, selected: _serviceModes),
                  if (_serviceModes.contains('Other'))
                    _otherTripleRow(label: 'Service Modes (Other)', c1: _srvOther1, c2: _srvOther2, c3: _srvOther3),

                  // TAGS
                  _chipInput(
                    title: 'Tags (single word)',
                    input: _tagInput,
                    values: _tags,
                    hint: 'Enter tag',
                    onAdd: () => _addSingleWordChip(_tagInput, _tags),
                  ),

                  // LANGUAGES
                  _sectionTitle('Languages Known'),
                  SwitchListTile(
                    value: _showLanguagesKnown,
                    onChanged: (v) => setState(() => _showLanguagesKnown = v),
                    title: const Text('Show Languages Known'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_showLanguagesKnown)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: indianLanguagesNative.keys.map((lang) {
                        final sel = _languages.contains(lang);
                        return FilterChip(
                          label: Text('$lang (${indianLanguagesNative[lang]})'),
                          selected: sel,
                          onSelected: (v) => setState(() {
                            if (v) {
                              _languages.add(lang);
                            } else {
                              if (lang != 'English') _languages.remove(lang);
                            }
                          }),
                        );
                      }).toList(),
                    ),

                  // CATEGORIES + SUBCATEGORIES
                  _chipInput(
                    title: 'Categories',
                    input: _categoryInput,
                    values: _categories,
                    hint: 'Enter category (single word)',
                    onAdd: () => _addSingleWordChip(_categoryInput, _categories),
                  ),
                  _chipInput(
                    title: 'Sub Categories',
                    input: _subCategoryInput,
                    values: _subCategories,
                    hint: 'Enter sub-category (single word)',
                    onAdd: () => _addSingleWordChip(_subCategoryInput, _subCategories),
                  ),

                  // WORKING HOURS
                  _workingHoursSection(),

                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: s.loading ? null : _submit,
                      child: s.loading ? const CircularProgressIndicator() : const Text('Create Brand'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
