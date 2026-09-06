import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Breakpoint responsif: Layar sempit (< 600) = 1 kolom, Layar lebar (>= 600) = 2 kolom
const double kWideBreakpoint = 600.0;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicOverviewPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicOverviewPage extends StatelessWidget {
  const AcademicOverviewPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        elevation: 0,
        actions: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Semantics(
                label: isDark ? 'Ubah ke tema terang' : 'Ubah ke tema gelap',
                toggled: isDark,
                button: true,
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileHeaderCard(
                name: 'Muhammad Aqil Azami',
                nim: '244107020128',
                kelas: 'TI-3H',
                prodi: 'D4 Teknik Informatika',
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= kWideBreakpoint;
                  final columns = isWide ? 2 : 1;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: isWide ? 2.8 : 2.5,
                    children: const [
                      AcademicInfoCard(
                        title: 'SKS Selesai',
                        value: '68 SKS',
                        icon: Icons.school_outlined,
                        badgeColor: Colors.blue,
                      ),
                      AcademicInfoCard(
                        title: 'IPK Kumulatif',
                        value: '3.88',
                        icon: Icons.insights_rounded,
                        badgeColor: Colors.amber,
                      ),
                      AcademicInfoCard(
                        title: 'Kehadiran Kuliah',
                        value: '98%',
                        icon: Icons.event_available_rounded,
                        badgeColor: Colors.green,
                      ),
                      AcademicInfoCard(
                        title: 'Status Akademik',
                        value: 'Aktif',
                        icon: Icons.verified_rounded,
                        badgeColor: Colors.teal,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget reusable header profil mahasiswa
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.name,
    required this.nim,
    required this.kelas,
    required this.prodi,
    super.key,
  });

  final String name;
  final String nim;
  final String kelas;
  final String prodi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Profil Mahasiswa: $name, NIM: $nim, Kelas: $kelas, Program Studi: $prodi',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.person, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: $nim | Kelas: $kelas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prodi,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget reusable kartu informasi metrik akademik
class AcademicInfoCard extends StatelessWidget {
  const AcademicInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.badgeColor,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Informasi $title, nilai $value',
      readOnly: true,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (badgeColor ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: badgeColor ?? theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
