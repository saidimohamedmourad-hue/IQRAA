import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/api_client.dart';

final _schoolDashProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final res = await ApiClient().dio.get('/school/dashboard');
  return res.data as Map<String, dynamic>;
});

class SchoolDashboardScreen extends ConsumerWidget {
  const SchoolDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final dashAsync = ref.watch(_schoolDashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('École — ${user?.name ?? ''}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          }),
        ],
      ),
      body: dashAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                children: [
                  _Stat(label: 'Formations', value: '${data['totalSessions'] ?? 0}', icon: Icons.school, color: AppColors.secondary),
                  _Stat(label: 'Inscriptions', value: '${data['totalApplications'] ?? 0}', icon: Icons.people, color: AppColors.primary),
                  _Stat(label: 'En attente', value: '${data['pendingApplications'] ?? 0}', icon: Icons.pending, color: AppColors.warning),
                  _Stat(label: 'Taux remplissage', value: '-', icon: Icons.bar_chart, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Créer une formation'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () => context.push('/school/sessions/new'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(icon: const Icon(Icons.list), label: const Text('Gérer les formations'), onPressed: () => context.push('/school/sessions')),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: color, size: 26),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ]),
      ],
    ),
  );
}
