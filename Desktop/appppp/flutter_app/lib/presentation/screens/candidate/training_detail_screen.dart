import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/training_provider.dart';
import '../../widgets/apply_bottom_sheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/training/training_model.dart';
import '../../../data/repositories/training_repository.dart';

class TrainingDetailScreen extends ConsumerWidget {
  const TrainingDetailScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(trainingDetailProvider(sessionId));
    return sessionAsync.when(
      data: (s) => _TrainingDetailBody(session: s),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
    );
  }
}

class _TrainingDetailBody extends ConsumerStatefulWidget {
  const _TrainingDetailBody({required this.session});
  final TrainingSessionModel session;

  @override
  ConsumerState<_TrainingDetailBody> createState() => _TrainingDetailBodyState();
}

class _TrainingDetailBodyState extends ConsumerState<_TrainingDetailBody> {
  bool _applying = false;

  Future<void> _apply() async {
    final selection = await showApplyBottomSheet(context);
    if (selection == null || !selection.isValid) return;

    setState(() => _applying = true);
    try {
      await TrainingRepository().applySession(
        widget.session.id,
        resumeId: selection.resumeId,
        filePath: selection.filePath,
        fileName: selection.fileName,
        fileBytes: selection.fileBytes,
      );
      ref.invalidate(myTrainingApplicationsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Inscription envoyée ! L\'analyse IA est en cours (consultez « Mes candidatures »).'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Voir',
              textColor: Colors.white,
              onPressed: () => context.push('/my-applications'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr');
    final s = widget.session;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: const Center(child: Icon(Icons.school, size: 64, color: Colors.white54)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(s.school?.name ?? '', style: const TextStyle(fontSize: 15, color: AppColors.grey)),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.location_on_outlined, label: s.location),
                    _InfoRow(icon: Icons.calendar_today_outlined, label: 'Début: ${fmt.format(s.trainingDate)}'),
                    if (s.endDate != null) _InfoRow(icon: Icons.event_outlined, label: 'Fin: ${fmt.format(s.endDate!)}'),
                    _InfoRow(icon: Icons.people_outline, label: '${s.currentParticipants}/${s.maxParticipants} participants'),
                    if (s.salary != null && s.salary! > 0) _InfoRow(icon: Icons.attach_money, label: '${s.salary!.toStringAsFixed(0)} DA'),
                    if (s.trainingCategory != null) _InfoRow(icon: Icons.category_outlined, label: s.trainingCategory!.name),
                    const SizedBox(height: 24),
                    const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(s.description, style: const TextStyle(height: 1.6)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]),
            child: ElevatedButton(
              onPressed: (s.isFull || _applying) ? null : _apply,
              style: s.isFull ? ElevatedButton.styleFrom(backgroundColor: AppColors.grey) : null,
              child: _applying
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(s.isFull ? 'Formation complète' : "S'inscrire"),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}
