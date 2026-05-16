import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/training_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/training_repository.dart';

class SessionFormScreen extends ConsumerStatefulWidget {
  const SessionFormScreen({super.key, this.sessionId});
  final String? sessionId;

  @override
  ConsumerState<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends ConsumerState<SessionFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _maxParticipants = TextEditingController();
  String _status = 'draft';
  String? _trainingCategoryId;
  DateTime? _startDate;
  bool _loading = false;
  bool get _isEdit => widget.sessionId != null;

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _location.dispose(); _maxParticipants.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_startDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choisissez une date'))); return; }
    setState(() => _loading = true);
    try {
      final data = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'location': _location.text.trim(),
        'maxParticipants': int.parse(_maxParticipants.text),
        'trainingDate': _startDate!.toIso8601String().substring(0, 10),
        'status': _status,
        'trainingCategoryId': _trainingCategoryId,
      };
      if (_isEdit) {
        await TrainingRepository().updateSession(widget.sessionId!, data);
      } else {
        await TrainingRepository().createSession(data);
      }
      ref.invalidate(schoolSessionsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEdit ? 'Modifier la formation' : 'Nouvelle formation')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Titre'), validator: (v) => v?.isEmpty == true ? 'Requis' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4, validator: (v) => v?.isEmpty == true ? 'Requis' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Lieu', prefixIcon: Icon(Icons.location_on_outlined)), validator: (v) => v?.isEmpty == true ? 'Requis' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _maxParticipants, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nombre maximum de participants', prefixIcon: Icon(Icons.people_outline)), validator: (v) => (v == null || int.tryParse(v) == null) ? 'Nombre invalide' : null),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              title: Text(_startDate == null ? 'Date de début' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.lightGrey)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Brouillon')),
                DropdownMenuItem(value: 'open', child: Text('Ouverte')),
                DropdownMenuItem(value: 'closed', child: Text('Fermée')),
                DropdownMenuItem(value: 'cancelled', child: Text('Annulée')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            ref.watch(trainingCategoriesProvider).when(
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _trainingCategoryId,
                decoration: const InputDecoration(labelText: 'Catégorie de formation'),
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _trainingCategoryId = v),
                validator: (v) => v == null ? 'Choisissez une catégorie' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Impossible de charger les catégories: $e', style: const TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isEdit ? 'Enregistrer' : 'Créer la formation'),
            ),
          ],
        ),
      ),
    ),
  );
}
