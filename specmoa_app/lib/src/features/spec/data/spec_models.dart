class MySpecItem {
  const MySpecItem({
    required this.id,
    required this.status,
    required this.totalStudyMinutes,
    required this.examDate,
    required this.dDay,
    required this.qualificationCode,
    required this.qualificationName,
  });

  final String id;
  final String status;
  final int totalStudyMinutes;
  final String? examDate;
  final int? dDay;
  final String qualificationCode;
  final String qualificationName;

  factory MySpecItem.fromJson(Map<String, dynamic> json) {
    final qualification =
        json['qualification'] as Map<String, dynamic>? ?? const {};

    return MySpecItem(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'preparing',
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      examDate: json['examDate'] as String?,
      dDay: json['dDay'] as int?,
      qualificationCode:
          qualification['code'] as String? ?? json['qualificationCode'] as String? ?? '',
      qualificationName:
          qualification['name'] as String? ?? json['qualificationName'] as String? ?? '',
    );
  }
}
