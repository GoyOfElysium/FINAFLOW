class ProjectModel {
  final String id;
  final String name;
  final String tag;
  final String? description;

  ProjectModel({
    required this.id,
    required this.name,
    required this.tag,
    this.description,
  });

  factory ProjectModel.fromSupabase(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id_proyek'].toString(),
      name: map['nama_proyek'] ?? '',
      tag: map['tag_proyek'] ?? '',
      description: map['keterangan'],
    );
  }

  Map<String, dynamic> toSupabase(String userId) {
    return {
      'user_id': userId,
      'nama_proyek': name,
      'tag_proyek': tag,
      'keterangan': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
