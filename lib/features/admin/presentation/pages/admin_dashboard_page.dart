import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.primaryTextColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            color: AppTheme.primaryTextColor,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                right: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Admin Profile
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          ),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Summer Walker',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Artist & Admin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: AppTheme.primaryColor, height: 1),
                
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard,
                        title: 'Overview',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _NavItem(
                        icon: Icons.music_note,
                        title: 'Add New Song',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _NavItem(
                        icon: Icons.videocam,
                        title: 'Add New Video',
                        isSelected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _NavItem(
                        icon: Icons.photo_library,
                        title: 'Add New Photo',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      _NavItem(
                        icon: Icons.star,
                        title: 'Premium Content',
                        isSelected: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                      _NavItem(
                        icon: Icons.analytics,
                        title: 'Analytics',
                        isSelected: _selectedIndex == 5,
                        onTap: () => setState(() => _selectedIndex = 5),
                      ),
                      _NavItem(
                        icon: Icons.people,
                        title: 'User Management',
                        isSelected: _selectedIndex == 6,
                        onTap: () => setState(() => _selectedIndex = 6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _OverviewTab();
      case 1:
        return _AddSongTab();
      case 2:
        return _AddVideoTab();
      case 3:
        return _AddPhotoTab();
      case 4:
        return _PremiumContentTab();
      case 5:
        return _AnalyticsTab();
      case 6:
        return _UserManagementTab();
      default:
        return _OverviewTab();
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 2.5,
            children: const [
              _StatCard(
                title: 'Total Users',
                value: '2.8M',
                icon: Icons.people,
                color: AppTheme.primaryColor,
              ),
              _StatCard(
                title: 'Premium Subscribers',
                value: '156K',
                icon: Icons.star,
                color: Colors.amber,
              ),
              _StatCard(
                title: 'Total Content',
                value: '89',
                icon: Icons.library_music,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(5, (index) => _ActivityItem(
            title: [
              'New song "Midnight Dreams" uploaded',
              'Premium video "Studio Session #12" added',
              'User "musiclover123" subscribed to annual plan',
              'Photo "Behind the Scenes" uploaded',
              'Monthly analytics report generated'
            ][index],
            subtitle: ['2 hours ago', '4 hours ago', '6 hours ago', '1 day ago', '2 days ago'][index],
            icon: [Icons.music_note, Icons.videocam, Icons.star, Icons.photo_library, Icons.analytics][index],
          )),
        ],
      ),
    );
  }
}

class _AddSongTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Song',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _FormField(
                    label: 'Song Title',
                    hint: 'Enter song title',
                    icon: Icons.music_note,
                  ),
                  const _FormField(
                    label: 'Artist',
                    hint: 'Enter artist name',
                    icon: Icons.person,
                  ),
                  const _FormField(
                    label: 'Album',
                    hint: 'Enter album name',
                    icon: Icons.album,
                  ),
                  const _FormField(
                    label: 'Genre',
                    hint: 'Enter genre',
                    icon: Icons.category,
                  ),
                  const _FormField(
                    label: 'Release Date',
                    hint: 'Select release date',
                    icon: Icons.calendar_today,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // File Upload
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Audio File',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag and drop your audio file here or click to browse',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Song uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Upload Song',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVideoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Video',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _FormField(
                    label: 'Video Title',
                    hint: 'Enter video title',
                    icon: Icons.videocam,
                  ),
                  const _FormField(
                    label: 'Description',
                    hint: 'Enter video description',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const _FormField(
                    label: 'Category',
                    hint: 'Select category',
                    icon: Icons.category,
                  ),
                  const _FormField(
                    label: 'Tags',
                    hint: 'Enter tags (comma separated)',
                    icon: Icons.tag,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Video Upload
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.video_library,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Video File',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag and drop your video file here or click to browse',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Video uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Upload Video',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Photo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _FormField(
                    label: 'Photo Title',
                    hint: 'Enter photo title',
                    icon: Icons.photo_library,
                  ),
                  const _FormField(
                    label: 'Description',
                    hint: 'Enter photo description',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const _FormField(
                    label: 'Location',
                    hint: 'Enter photo location',
                    icon: Icons.location_on,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Photo Upload
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Photo',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Drag and drop your photo here or click to browse',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Photo uploaded successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Upload Photo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumContentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Content Management',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Premium Content Stats
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Premium Users',
                          value: '156K',
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _StatCard(
                          title: 'Monthly Revenue',
                          value: '\$156K',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Content Management
                  Text(
                    'Manage Premium Content',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _PremiumContentItem(
                    title: 'Exclusive Song "Midnight Dreams"',
                    type: 'Song',
                    subscribers: '89K',
                    revenue: '\$8.9K',
                    onEdit: () {},
                    onDelete: () {},
                  ),
                  
                  _PremiumContentItem(
                    title: 'Behind-the-Scenes Studio Session',
                    type: 'Video',
                    subscribers: '67K',
                    revenue: '\$6.7K',
                    onEdit: () {},
                    onDelete: () {},
                  ),
                  
                  _PremiumContentItem(
                    title: 'Exclusive Photo Collection',
                    type: 'Photo',
                    subscribers: '45K',
                    revenue: '\$4.5K',
                    onEdit: () {},
                    onDelete: () {},
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Add New Premium Content
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Premium Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Analytics Dashboard\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'User Management\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
                      color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: maxLines,
            style: const TextStyle(color: AppTheme.primaryTextColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.secondaryTextColor),
              prefixIcon: Icon(icon, color: AppTheme.primaryColor),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumContentItem extends StatelessWidget {
  final String title;
  final String type;
  final String subscribers;
  final String revenue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PremiumContentItem({
    required this.title,
    required this.type,
    required this.subscribers,
    required this.revenue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  subscribers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Subscribers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  revenue,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Revenue',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
