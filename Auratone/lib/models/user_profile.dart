class UserProfile {
  String? faceShape;
  String? skinTone;
  String? hairType;
  String? hairColor;
  List<String> savedOutfits;

  UserProfile({
    this.faceShape,
    this.skinTone,
    this.hairType,
    this.hairColor,
    this.savedOutfits = const [],
  });

  Map<String, dynamic> toJson() => {
        'faceShape': faceShape,
        'skinTone': skinTone,
        'hairType': hairType,
        'hairColor': hairColor,
        'savedOutfits': savedOutfits,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        faceShape: json['faceShape'],
        skinTone: json['skinTone'],
        hairType: json['hairType'],
        hairColor: json['hairColor'],
        savedOutfits: List<String>.from(json['savedOutfits'] ?? []),
      );
}
