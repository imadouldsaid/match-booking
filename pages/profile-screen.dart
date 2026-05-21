import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // تأكد من إضافتها في pubspec.yaml لرفع الصور

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile; // متغير لحفظ الصورة المختارة من قبل المستخدم
  final ImagePicker _picker = ImagePicker();

  // دالة تفتح للمستخدم الاستوديو ليختار صورته الشخصية
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // لتقليل حجم الصورة والحفاظ على الأداء
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("خطأ في اختيار الصورة: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية هادئة مريحة للعين
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1️⃣ الكارت الأخضر العلوي (مستوحى من تصميمك وبدون نظام XP)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, right: 20, left: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0F8A4B), // اللون الأخضر الرياضي المعتمد
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // مكان الصورة الشخصية التفاعلي مع زر التعديل
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: _pickImage, // عند الضغط يفتح الاستوديو فوراً
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFF0F8A4B),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // اسم المستخدم والبريد الإلكتروني
                  const Text(
                    'Abdoo',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'silarbiabdoo5@gmail.com',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  // شارة المركز في الفريق
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'قائد الفريق ⚽',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // إحصائيات رقمية نظيفة وعملية للمستخدم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('0', 'المباريات'),
                      Container(height: 30, width: 1, color: Colors.white30),
                      _buildStatItem('Lvl 1', 'المستوى'),
                      Container(height: 30, width: 1, color: Colors.white30),
                      _buildStatItem('0', 'الحجوزات'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2️⃣ قسم إدارة الحجوزات (أشياء عملية مفيدة)
            _buildSectionTitle('📅 إدارة الحجوزات'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.calendar_month,
                    title: 'جدول حجوزاتي القادمة',
                    subtitle: 'تتبع مواعيد وتفاصيل الملاعب المحجوزة',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildListTile(
                    icon: Icons.person_search,
                    title: 'البحث عن لاعبين للحجز',
                    subtitle: 'نقصكم لاعب؟ ابحث عن شخص يكمل معكم المباراة',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 3️⃣ قسم تواصل الفريق (مهم جداً للتنسيق والدردشة)
            _buildSectionTitle('👥 تواصل الفريق'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'مجموعة الفريق الخاصة',
                    subtitle: 'دردش مع أصدقائك لتحديد موعد التحدي القادم',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildListTile(
                    icon: Icons.campaign_outlined,
                    title: 'إعلانات وتنبيهات القائد',
                    subtitle: 'آخر القرارات وتحديثات تشكيلة الفريق الأساسية',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // زر الخروج أو إنشاء فريق جديد بلون أحمر متناسق وهادئ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.group_add, color: Colors.white),
                label: const Text(
                  'إنشاء مجموعة فريق جديدة',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ودجت فرعية لبناء عناصر الإحصائيات داخل الجزء الأخضر
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // ودجت لبناء عناوين الأقسام الرئيسية
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.topRight, // لتتناسب مع اللغة العربية
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          
        ),
      ),
    );
  }

  // ودجت مخصصة لبناء الخيارات العملية داخل الأقسام بشكل فخم
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F8A4B).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF0F8A4B), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}