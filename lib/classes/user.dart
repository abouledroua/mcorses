class User {
  String adresse, fonction, facebook, fullName, phone, email, photo;
  bool isAdmin, isFormateur;
  int idUser, etat, newUser, age;
  User(
      {required this.fonction,
      required this.email,
      required this.facebook,
      required this.age,
      required this.photo,
      required this.newUser,
      required this.fullName,
      required this.phone,
      required this.isFormateur,
      required this.isAdmin,
      required this.adresse,
      required this.idUser,
      required this.etat});
}
