import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ProfileService {
  static const _keyCompanyName = 'company_name';
  static const _keyPhone = 'phone';
  static const _keyPix = 'pix';
  static const _keyLogoPath = 'logo_path';

  Future<ProfessionalProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfessionalProfile(
      companyName: prefs.getString(_keyCompanyName) ?? 'Sua Empresa (Edite em Ajustes)',
      phone: prefs.getString(_keyPhone) ?? '(00) 00000-0000',
      pixKey: prefs.getString(_keyPix) ?? 'seu@pix.com',
      logoPath: prefs.getString(_keyLogoPath), // Nullable
    );
  }

  Future<void> saveProfile(ProfessionalProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, profile.companyName);
    await prefs.setString(_keyPhone, profile.phone);
    await prefs.setString(_keyPix, profile.pixKey);
    if (profile.logoPath != null) {
      await prefs.setString(_keyLogoPath, profile.logoPath!);
    } else {
      await prefs.remove(_keyLogoPath);
    }
  }
}
