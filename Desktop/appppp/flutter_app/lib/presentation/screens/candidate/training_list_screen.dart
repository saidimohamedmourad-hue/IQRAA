import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/training_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/training/training_model.dart';

class TrainingListScreen extends ConsumerStatefulWidget {
  const TrainingListScreen({super.key});

  @override
  ConsumerState<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends ConsumerState<TrainingListScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(trainingListProvider((
      search: _search.text.isEmpty ? null : _search.text,
      category: null,
    )));

    return Scaffold(
      appBar: AppBar(title: const Text('Formations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Rechercher une formation...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _search.clear(); setState(() {}); })
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? const Center(child: Text('Aucune formation disponible'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sessions.length,
                      itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final TrainingSessionModel session;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => context.push('/training/${session.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.isFull ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.isFull ? 'Complet' : 'Disponible',
                    style: TextStyle(fontSize: 11, color: session.isFull ? AppColors.error : AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(session.school?.name ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.grey),
                const SizedBox(width: 2),
                Text(session.location, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline, size: 13, color: AppColors.grey),
                const SizedBox(width: 2),
                Text('${session.currentParticipants}/${session.maxParticipants} places', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
