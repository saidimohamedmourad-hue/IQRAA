class SchoolModel {
  final String id;
  final String name;
  final String? address;
  final String? description;

  const SchoolModel({required this.id, required this.name, this.address, this.description});

  factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    description: json['description'] as String?,
  );
}

class TrainingCategoryModel {
  final String id;
  final String name;

  const TrainingCategoryModel({required this.id, required this.name});

  factory TrainingCategoryModel.fromJson(Map<String, dynamic> json) => TrainingCategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}

class TrainingSessionModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String status;
  final int maxParticipants;
  final int currentParticipants;
  final double? salary;
  final int viewCount;
  final DateTime trainingDate;
  final DateTime? endDate;
  final SchoolModel? school;
  final TrainingCategoryModel? trainingCategory;
  final DateTime createdAt;

  const TrainingSessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.trainingDate,
    required this.viewCount,
    required this.createdAt,
    this.salary,
    this.endDate,
    this.school,
    this.trainingCategory,
  });

  bool get isFull => currentParticipants >= maxParticipants;

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) => TrainingSessionModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    location: json['location'] as String,
    status: json['status'] as String,
    maxParticipants: (json['maxParticipants'] as num).toInt(),
    currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
    salary: json['salary'] != null ? (double.tryParse(json['salary'].toString()) ?? 0.0) : null,
    viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    trainingDate: DateTime.parse(json['trainingDate'] as String),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    school: json['school'] != null ? SchoolModel.fromJson(json['school'] as Map<String, dynamic>) : null,
    trainingCategory: json['training_category'] != null
        ? TrainingCategoryModel.fromJson(json['training_category'] as Map<String, dynamic>)
        : null,
  );
}

class TrainingApplicationModel {
  final String id;
  final String status;
  final int? aiGeneratedScore;
  final String? aiGeneratedFeedback;
  final TrainingSessionModel? trainingSession;
  final DateTime appliedAt;

  const TrainingApplicationModel({
    required this.id,
    required this.status,
    required this.appliedAt,
    this.aiGeneratedScore,
    this.aiGeneratedFeedback,
    this.trainingSession,
  });

  factory TrainingApplicationModel.fromJson(Map<String, dynamic> json) => TrainingApplicationModel(
    id: json['id'] as String,
    status: json['status'] as String,
    aiGeneratedScore: json['aiGeneratedScore'] as int?,
    aiGeneratedFeedback: json['aiGeneratedFeedback'] as String?,
    trainingSession: json['training_session'] != null
        ? TrainingSessionModel.fromJson(json['training_session'] as Map<String, dynamic>)
        : null,
    appliedAt: DateTime.parse(json['created_at'] as String),
  );
}
