import '../../domain/entities/career_resource.dart';

class CareerResourceModel extends CareerResource {
  const CareerResourceModel({
    required super.resourceId,
    required super.type,
    required super.title,
    required super.content,
    required super.order,
  });

  factory CareerResourceModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return CareerResourceModel(
      resourceId: id,
      type: CareerResourceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CareerResourceType.cvTip,
      ),
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}
