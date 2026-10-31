import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CampusConnectApp());
}

const _green = Color(0xFF10B981); // Primary (Green)
const _blue = Color(0xFF0F3E82); // Secondary (Dark Blue)
const _ink = Color(0xFF182842);
const _muted = Color(0xFF687B98);
const _canvas = Color(0xFFF4F7FB);
const _line = Color(0xFFE0E8F2);
const _photoChannel = MethodChannel('campus_connect/photo_picker');

class CampusConnectApp extends StatefulWidget {
  const CampusConnectApp({super.key, this.initialLoggedIn = false});

  final bool initialLoggedIn;

  @override
  State<CampusConnectApp> createState() => _CampusConnectAppState();
}

class _CampusConnectAppState extends State<CampusConnectApp> {
  late bool _isLoggedIn;
  String _userName = 'Campus community member';
  String _userEmail = 'student@campus.edu';

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;
  }

  void _login(String name, String email) {
    setState(() {
      _isLoggedIn = true;
      if (name.isNotEmpty) _userName = name;
      if (email.isNotEmpty) _userEmail = email;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          primary: _green,
          secondary: _blue,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(color: _ink, fontSize: 14),
          bodySmall: TextStyle(color: _muted, fontSize: 12),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
      home: _isLoggedIn
          ? CampusHomePage(
              userName: _userName,
              userEmail: _userEmail,
              onLogout: _logout,
            )
          : AuthScreen(onLogin: _login),
    );
  }
}

class IncidentCategory {
  const IncidentCategory(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

const _categories = <IncidentCategory>[
  IncidentCategory('Broken Facility', Icons.build_rounded, _green),
  IncidentCategory('Water Shortage', Icons.water_drop_rounded, _blue),
  IncidentCategory('Electricity Outage', Icons.bolt_rounded, Color(0xFFFFA51F)),
  IncidentCategory('Damaged Furniture', Icons.chair_rounded, Color(0xFF274C77)),
  IncidentCategory('Sanitation Problem', Icons.wc_rounded, Color(0xFF365BA8)),
  IncidentCategory(
    'Safety Concern',
    Icons.verified_user_rounded,
    Color(0xFF16945B),
  ),
];

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.photoPath,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? photoPath;
}

List<Incident> _sampleIncidents() => [
  Incident(
    id: 'CC-1048',
    title: 'Projector not working',
    category: 'Broken Facility',
    description: 'The projector in classroom 3B will not turn on.',
    location: 'Science Block · Room 3B',
    date: DateTime(2025, 10, 25, 10, 24),
    status: 'In Progress',
  ),
  Incident(
    id: 'CC-1045',
    title: 'No water in the library',
    category: 'Water Shortage',
    description: 'The water fountain on the ground floor is dry.',
    location: 'Main Library · Ground floor',
    date: DateTime(2025, 10, 22, 14, 17),
    status: 'Resolved',
  ),
  Incident(
    id: 'CC-1041',
    title: 'Lights not working in building A',
    category: 'Electricity Outage',
    description: 'The lights in the east hallway are not working.',
    location: 'Building A · East hallway',
    date: DateTime(2025, 10, 20, 11, 3),
    status: 'Pending',
  ),
  Incident(
    id: 'CC-1038',
    title: 'Broken chair in classroom',
    category: 'Damaged Furniture',
    description: 'One of the chairs in the front row has a loose leg.',
    location: 'Arts Building · Room 12',
    date: DateTime(2025, 10, 18, 16, 45),
    status: 'In Progress',
  ),
  Incident(
    id: 'CC-1033',
    title: 'Dirty restroom',
    category: 'Sanitation Problem',
    description: 'The second-floor restroom needs attention.',
    location: 'Student Centre · Floor 2',
    date: DateTime(2025, 10, 16, 9, 12),
    status: 'Resolved',
  ),
];

class CampusHomePage extends StatefulWidget {
  const CampusHomePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  @override
  State<CampusHomePage> createState() => _CampusHomePageState();
}

class _CampusHomePageState extends State<CampusHomePage> {
  int _selectedTab = 0;
  bool _showAllIncidents = false;
  final List<Incident> _incidents = _sampleIncidents();

  void _openIncidents({bool showAll = false}) {
    setState(() {
      _selectedTab = 2;
      _showAllIncidents = showAll;
    });
  }

  void _submitIncident(Incident incident) {
    setState(() {
      _incidents.insert(0, incident);
      _selectedTab = 2;
      _showAllIncidents = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your incident has been submitted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _IncidentDashboard(
        incidents: _incidents,
        showAll: _showAllIncidents,
        onShowAll: () => _openIncidents(showAll: true),
        onShowMine: () => setState(() => _showAllIncidents = false),
        onReport: () => setState(() => _selectedTab = 1),
      ),
      _ReportWizard(
        key: ValueKey('report-$_selectedTab-${_incidents.length}'),
        onClose: () => setState(() => _selectedTab = 0),
        onSubmit: _submitIncident,
      ),
      _IncidentDashboard(
        incidents: _incidents,
        showAll: true,
        onShowAll: () => _openIncidents(showAll: true),
        onShowMine: () => setState(() {
          _selectedTab = 0;
          _showAllIncidents = false;
        }),
        onReport: () => setState(() => _selectedTab = 1),
      ),
      _ProfilePage(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
            if (index == 2) _showAllIncidents = true;
          });
        },
        destinations: const [
          NavigationDestination(
            key: ValueKey('nav-home'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            key: ValueKey('nav-report'),
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Report',
          ),
          NavigationDestination(
            key: ValueKey('nav-incidents'),
            icon: Icon(Icons.list_alt_rounded),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Incidents',
          ),
          NavigationDestination(
            key: ValueKey('nav-profile'),
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _IncidentDashboard extends StatefulWidget {
  const _IncidentDashboard({
    required this.incidents,
    required this.showAll,
    required this.onShowAll,
    required this.onShowMine,
    required this.onReport,
  });

  final List<Incident> incidents;
  final bool showAll;
  final VoidCallback onShowAll;
  final VoidCallback onShowMine;
  final VoidCallback onReport;

  @override
  State<_IncidentDashboard> createState() => _IncidentDashboardState();
}

class _IncidentDashboardState extends State<_IncidentDashboard> {
  String _query = '';
  String _categoryFilter = 'All Categories';
  String _statusFilter = 'All Statuses';

  @override
  Widget build(BuildContext context) {
    final incidents = widget.incidents.where((incident) {
      final matchesQuery =
          _query.isEmpty ||
          '${incident.title} ${incident.category} ${incident.location}'
              .toLowerCase()
              .contains(_query.toLowerCase());
      final matchesCategory =
          _categoryFilter == 'All Categories' ||
          incident.category == _categoryFilter;
      final matchesStatus =
          _statusFilter == 'All Statuses' || incident.status == _statusFilter;
      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();

    return Column(
      children: [
        _BrandHeader(onReport: widget.onReport),
        Expanded(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeedTabs(
                        showAll: widget.showAll,
                        onMyIncidents: widget.onShowMine,
                        onAllIncidents: widget.onShowAll,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        key: const ValueKey('incident-search'),
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          hintText: 'Search incidents...',
                          prefixIcon: Icon(Icons.search_rounded),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: _FilterDropdown(
                              icon: Icons.filter_alt_outlined,
                              value: _categoryFilter,
                              options: [
                                'All Categories',
                                ..._categories.map((category) => category.name),
                              ],
                              onChanged: (value) =>
                                  setState(() => _categoryFilter = value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FilterDropdown(
                              icon: Icons.track_changes_rounded,
                              value: _statusFilter,
                              options: const [
                                'All Statuses',
                                'Pending',
                                'In Progress',
                                'Resolved',
                              ],
                              onChanged: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                          ),
                        ],
                      ),
                      if (!widget.showAll) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Recent reports',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: widget.onShowAll,
                              child: const Text('View all'),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 13),
                        Text(
                          '${incidents.length} ${incidents.length == 1 ? 'incident' : 'incidents'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 7),
                      ],
                    ],
                  ),
                ),
              ),
              if (incidents.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyIncidents(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                  sliver: SliverList.separated(
                    itemCount: incidents.length,
                    itemBuilder: (context, index) => _IncidentCard(
                      incident: incidents[index],
                      onTap: () =>
                          _showIncidentDetails(context, incidents[index]),
                    ),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campus Connect',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Report  ·  Track  ·  Improve',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Create a report',
                onPressed: onReport,
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                ),
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: const Icon(Icons.person, color: _blue, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTabs extends StatelessWidget {
  const _FeedTabs({
    required this.showAll,
    required this.onMyIncidents,
    required this.onAllIncidents,
  });

  final bool showAll;
  final VoidCallback onMyIncidents;
  final VoidCallback onAllIncidents;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EDF5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _FeedTab(
            label: 'My Incidents',
            selected: !showAll,
            onTap: onMyIncidents,
          ),
          _FeedTab(
            label: 'All Incidents',
            selected: showAll,
            onTap: onAllIncidents,
          ),
        ],
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? _blue : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _ink,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: _ink),
          const SizedBox(width: 5),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                items: options
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          option,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) onChanged(selected);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onTap});

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = _categoryFor(incident.category);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: _line.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _IncidentThumbnail(
                category: category,
                photoPath: incident.photoPath,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(category.icon, size: 14, color: category.color),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            incident.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 13,
                          color: _muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatDate(incident.date)}  ·  ${_formatTime(incident.date)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _muted, fontSize: 9),
                          ),
                        ),
                        const SizedBox(width: 5),
                        _StatusBadge(status: incident.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right_rounded, color: _muted, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncidentThumbnail extends StatelessWidget {
  const _IncidentThumbnail({required this.category, this.photoPath});

  final IncidentCategory category;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: 58,
        height: 58,
        child: photoPath != null
            ? Image.file(
                File(photoPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => ColoredBox(
    color: category.color.withValues(alpha: 0.1),
    child: Icon(category.icon, color: category.color, size: 28),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Resolved' => const Color(0xFF178B55),
      'Pending' => const Color(0xFFE98908),
      _ => const Color(0xFF1766C1),
    };
    final background = switch (status) {
      'Resolved' => const Color(0xFFDDF5E9),
      'Pending' => const Color(0xFFFFEFD4),
      _ => const Color(0xFFE0EEFF),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyIncidents extends StatelessWidget {
  const _EmptyIncidents();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: _muted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            const Text(
              'No incidents found',
              style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportWizard extends StatefulWidget {
  const _ReportWizard({
    super.key,
    required this.onClose,
    required this.onSubmit,
  });

  final VoidCallback onClose;
  final ValueChanged<Incident> onSubmit;

  @override
  State<_ReportWizard> createState() => _ReportWizardState();
}

class _ReportWizardState extends State<_ReportWizard> {
  final _descriptionController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  int _step = 0;
  String? _selectedCategory;
  String? _photoPath;
  bool _isPickingPhoto = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _isPickingPhoto = true);
    try {
      final path = await _photoChannel.invokeMethod<String>('pickImage');
      if (path != null && mounted) setState(() => _photoPath = path);
    } on PlatformException {
      if (mounted) _showMessage('Could not open your photo library.');
    } on MissingPluginException {
      if (mounted) _showMessage('Photo attachments are available on Android.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _nextStep() {
    if (_step == 0) {
      if (_selectedCategory == null) {
        _showMessage('Choose an incident category to continue.');
        return;
      }
      if (_descriptionController.text.trim().isEmpty) {
        _showMessage('Add a short description of the incident.');
        return;
      }
    }
    if (_step == 1 &&
        (_buildingController.text.trim().isEmpty ||
            _roomController.text.trim().isEmpty)) {
      _showMessage('Add a building and room or area to continue.');
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _submit() {
    final category = _categoryFor(_selectedCategory!);
    final now = DateTime.now();
    final description = _descriptionController.text.trim();
    widget.onSubmit(
      Incident(
        id: 'CC-${now.microsecondsSinceEpoch % 100000}',
        title: _titleFromDescription(description),
        category: category.name,
        description: description,
        location:
            '${_buildingController.text.trim()} · ${_roomController.text.trim()}',
        date: now,
        status: 'Pending',
        photoPath: _photoPath,
      ),
    );
  }

  String _titleFromDescription(String description) {
    final firstSentence = description.split(RegExp(r'[.!?\n]')).first.trim();
    if (firstSentence.isEmpty) return 'New ${_selectedCategory!.toLowerCase()}';
    if (firstSentence.length <= 48) return firstSentence;
    return '${firstSentence.substring(0, 45).trimRight()}...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WizardHeader(step: _step, onBack: _goBack),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: SingleChildScrollView(
              key: ValueKey(_step),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: _stepContent(),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _nextStep,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _step == 3 ? 'Submit report' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepContent() {
    return switch (_step) {
      0 => _detailsStep(),
      1 => _locationStep(),
      2 => _photoStep(),
      _ => _reviewStep(),
    };
  }

  Widget _detailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Incident Category',
          subtitle: 'Select the type of issue',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = category.name == _selectedCategory;
            return InkWell(
              key: ValueKey('category-${category.name}'),
              onTap: () => setState(() => _selectedCategory = category.name),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE6F7F0)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: selected ? _green : _line,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category.icon, color: category.color, size: 25),
                    const SizedBox(height: 5),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const _SectionTitle(
          title: 'Description',
          subtitle: 'Provide a clear description of the incident',
        ),
        const SizedBox(height: 9),
        TextField(
          key: const ValueKey('incident-description'),
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'What happened? Include any details that may help...',
            alignLabelWithHint: true,
            counterStyle: TextStyle(color: _muted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _locationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Where did it happen?',
          subtitle: 'Help the campus team find the issue quickly',
        ),
        const SizedBox(height: 22),
        const Text('Building', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('incident-building'),
          controller: _buildingController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Science Block',
            prefixIcon: Icon(Icons.apartment_rounded),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Room or area',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('incident-room'),
          controller: _roomController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Room 3B or east hallway',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: _blue, size: 19),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Please be as specific as you can. Your location helps staff respond sooner.',
                  style: TextStyle(color: _blue, fontSize: 12, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Add a photo',
          subtitle: 'A photo can help staff understand the issue (optional)',
        ),
        const SizedBox(height: 20),
        if (_photoPath case final path?) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(path),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: IconButton.filledTonal(
                  tooltip: 'Remove photo',
                  onPressed: () => setState(() => _photoPath = null),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ] else
          InkWell(
            onTap: _isPickingPhoto ? null : _pickPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isPickingPhoto
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(
                          Icons.add_a_photo_outlined,
                          size: 31,
                          color: _blue,
                        ),
                  const SizedBox(height: 10),
                  Text(
                    _isPickingPhoto ? 'Opening photos...' : 'Choose a photo',
                    style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG or PNG from your device',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        const Text(
          'Make sure the image does not include private or sensitive information.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final category = _selectedCategory == null
        ? null
        : _categoryFor(_selectedCategory!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Review your report',
          subtitle: 'Check the details before you send it',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category != null)
                Row(
                  children: [
                    Icon(category.icon, color: category.color, size: 19),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              const Divider(height: 24),
              _ReviewLine(
                icon: Icons.notes_rounded,
                label: 'Description',
                value: _descriptionController.text.trim(),
              ),
              const SizedBox(height: 16),
              _ReviewLine(
                icon: Icons.place_outlined,
                label: 'Location',
                value:
                    '${_buildingController.text.trim()} · ${_roomController.text.trim()}',
              ),
              if (_photoPath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_photoPath!),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Your report will be shared with the campus facilities team.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      widget.onClose();
    }
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _blue,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    tooltip: 'Go back',
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Report an Incident',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: List.generate(4, (index) {
                  final active = index <= step;
                  return Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: active
                              ? _blue
                              : const Color(0xFFE9EEF5),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: active ? Colors.white : _muted,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (index < 3)
                          Expanded(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              color: index < step ? _green : _line,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _muted, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: _ink, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_green, _blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: _green, size: 38),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const ValueKey('profile-logout'),
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 16),
                  label: const Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: const [
              _ProfileRow(
                icon: Icons.shield_outlined,
                title: 'About Campus Connect',
                subtitle: 'Report, track and improve campus facilities',
              ),
              SizedBox(height: 10),
              _ProfileRow(
                icon: Icons.lock_outline_rounded,
                title: 'Your privacy',
                subtitle: 'Only share details relevant to resolving an issue',
              ),
              SizedBox(height: 10),
              _ProfileRow(
                icon: Icons.info_outline_rounded,
                title: 'App information',
                subtitle: 'Campus Connect · Version 1.0',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: _blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showIncidentDetails(BuildContext context, Incident incident) {
  final category = _categoryFor(incident.category);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    incident.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _StatusBadge(status: incident.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(category.icon, color: category.color, size: 18),
                const SizedBox(width: 7),
                Text(
                  category.name,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.description,
              style: const TextStyle(color: _ink, height: 1.5),
            ),
            const SizedBox(height: 18),
            _ReviewLine(
              icon: Icons.place_outlined,
              label: 'Location',
              value: incident.location,
            ),
            const SizedBox(height: 14),
            _ReviewLine(
              icon: Icons.calendar_month_outlined,
              label: 'Reported',
              value:
                  '${_formatDate(incident.date)} · ${_formatTime(incident.date)}',
            ),
            const SizedBox(height: 14),
            Text(
              'Report ID  ${incident.id}',
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
            if (incident.photoPath case final path?) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

IncidentCategory _categoryFor(String name) {
  return _categories.firstWhere(
    (category) => category.name == name,
    orElse: () => _categories.first,
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onLogin});

  final void Function(String name, String email) onLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegistering = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _isRegistering ? _nameController.text.trim() : 'Campus community member';
      final email = _emailController.text.trim();
      widget.onLogin(
        name.isEmpty ? 'Campus community member' : name,
        email.isEmpty ? 'student@campus.edu' : email,
      );
    }
  }

  void _quickDemoLogin() {
    widget.onLogin('Alex Student', 'alex.student@campus.edu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_green, _blue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _green.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Campus Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegistering
                          ? 'Create your account to report & track incidents'
                          : 'Sign in to access your campus incident reports',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _line),
                        boxShadow: [
                          BoxShadow(
                            color: _ink.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isRegistering = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: !_isRegistering ? _blue : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: !_isRegistering ? _blue : _muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isRegistering = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _isRegistering ? _blue : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: _isRegistering ? _blue : _muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_isRegistering) ...[
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              key: const ValueKey('auth-name'),
                              decoration: const InputDecoration(
                                hintText: 'Enter your full name',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: _muted,
                                ),
                              ),
                              validator: (v) {
                                if (_isRegistering && (v == null || v.trim().isEmpty)) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            'Email or Student ID',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            key: const ValueKey('auth-email'),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'e.g. student@campus.edu',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: _muted,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email or student ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            key: const ValueKey('auth-password'),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: _muted,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _muted,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          if (_isRegistering) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: _ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              key: const ValueKey('auth-confirm-password'),
                              obscureText: _obscurePassword,
                              decoration: const InputDecoration(
                                hintText: 'Re-enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: _muted,
                                ),
                              ),
                              validator: (v) {
                                if (_isRegistering &&
                                    v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton(
                            key: const ValueKey('auth-submit'),
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isRegistering ? 'Create Account' : 'Sign In',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      key: const ValueKey('auth-demo-login'),
                      onPressed: _quickDemoLogin,
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        color: _blue,
                        size: 18,
                      ),
                      label: const Text(
                        'Quick Demo Sign In',
                        style: TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: _blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
