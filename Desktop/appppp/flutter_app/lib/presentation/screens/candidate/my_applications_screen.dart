import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/job_provider.dart';
import '../../providers/training_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/job/job_model.dart';
import '../../../data/models/training/training_model.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes candidatures'),
          bottom: const TabBar(tabs: [Tab(text: 'Emplois'), Tab(text: 'Formations')]),
        ),
        body: TabBarView(
          children: [
            _JobApplicationsList(),
            _TrainingApplicationsList(),
          ],
        ),
      ),
    );
  }
}

class _JobApplicationsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myJobApplicationsProvider);
    return appsAsync.when(
      data: (apps) => apps.isEmpty
          ? const Center(child: Text('Aucune candidature'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (_, i) => _JobAppTile(app: apps[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _TrainingApplicationsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(myTrainingApplicationsProvider);
    return appsAsync.when(
      data: (apps) => apps.isEmpty
          ? const Center(child: Text('Aucune inscription'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (_, i) => _TrainingAppTile(app: apps[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _JobAppTile extends StatelessWidget {
  const _JobAppTile({required this.app});
  final JobApplicationModel app;

  Color get _statusColor => switch (app.status) {
    'shortlisted' => AppColors.success,
    'rejected'    => AppColors.error,
    'reviewed'    => AppColors.warning,
    _             => AppColors.grey,
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: const Icon(Icons.work, color: AppColors.primary)),
      title: Text(app.jobVacancy?.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(app.jobVacancy?.company?.name ?? ''),
          const SizedBox(height: 4),
          if (app.aiGeneratedScore != null)
            Text('Score IA: ${app.aiGeneratedScore}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(app.status, style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}

class _TrainingAppTile extends StatelessWidget {
  const _TrainingAppTile({required this.app});
  final TrainingApplicationModel app;

  Color get _statusColor => switch (app.status) {
    'accepted' => AppColors.success,
    'rejected' => AppColors.error,
    'reviewed' => AppColors.warning,
    _          => AppColors.grey,
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(backgroundColor: AppColors.secondary.withValues(alpha: 0.1), child: const Icon(Icons.school, color: AppColors.secondary)),
      title: Text(app.trainingSession?.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(app.trainingSession?.school?.name ?? ''),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(app.status, style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}
