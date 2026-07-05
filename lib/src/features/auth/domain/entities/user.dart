class User {
  final String id;
  final String email;
  final String fullName;
  final String? studentId;
  final String? phoneNumber;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentId,
    this.phoneNumber,
    this.role = 'student',
  });

  factory User.initial() =>
      const User(id: '', email: '', fullName: '', role: 'student');
}
