import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SportScreen extends StatefulWidget {
  final String username; // استقبال اسم المستخدم لعرض العبارة الترحيبية

  const SportScreen({super.key, required this.username});

  @override
  State<SportScreen> createState() => _SportScreenState();
}

class _SportScreenState extends State<SportScreen> {
  List<dynamic> filteredCourts = []; // ملاعب الرياضة المحددة
  List<dynamic> allCourts = [];      // جميع الملاعب المتواجدة في قاعدة البيانات (في الأسفل)
  bool isFilteredLoading = true;
  bool isAllLoading = true;
  String selectedSport = 'football'; // الافتراضي بالإنجليزية لتجنب خطأ السيرفر

  // الأيقونات الأربعة مع الكود الإنجليزي للسيرفر والاسم العربي للواجهة
  final List<Map<String, dynamic>> categories = const [
    {
      'id': 'football',
      'title': 'كرة قدم',
      'icon': Icons.sports_soccer,
    },
    {
      'id': 'basketball',
      'title': 'كرة سلة',
      'icon': Icons.sports_basketball,
    },
    {
      'id': 'tennis',
      'title': 'ملاعب تنس',
      'icon': Icons.sports_tennis,
    },
    {
      'id': 'swimming',
      'title': 'مسابح',
      'icon': Icons.pool,
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchFilteredCourts(selectedSport); // جلب ملاعب الرياضة الافتراضية
    fetchAllCourts();                   // جلب جميع الملاعب للقائمة السفلية
  }

  // 1. دالة جلب الملاعب بناءً على الرياضة المحددة (الأزرار الأفقية)
  Future<void> fetchFilteredCourts(String sportType) async {
    setState(() {
      isFilteredLoading = true;
      selectedSport = sportType;
    });

    final url = Uri.parse('http://localhost:57190/courts?sport=$sportType');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          filteredCourts = json.decode(response.body);
          isFilteredLoading = false;
        });
      } else {
        setState(() => isFilteredLoading = false);
      }
    } catch (e) {
      setState(() => isFilteredLoading = false);
    }
  }

  // 2. دالة جلب جميع الملاعب دون أي فلترة (للقائمة السفلية)
  Future<void> fetchAllCourts() async {
    final url = Uri.parse('http://localhost:57190/courts'); // طلب عام لكل الملاعب
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          allCourts = json.decode(response.body);
          isAllLoading = false;
        });
      } else {
        setState(() => isAllLoading = false);
      }
    } catch (e) {
      setState(() => isAllLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // الـ AppBar الترحيبي السابق
      appBar: AppBar(
        title: Text(
          'مرحباً بك، ${widget.username}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 9, 142, 82),
        elevation: 0,
      ),
      body: SingleChildScrollView( // للسماح بالتمرير العمودي لكل الصفحة بسلاسة
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط البحث المخصص السابق
            Padding(
  padding: const EdgeInsets.all(16.0),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
    ),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'ابحث عن ملعب أو موقع...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  ),
),
            // عنوان قائمة الرياضات الأفقية
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'اختر الرياضة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            // شريط الأيقونات الأربعة المخصص الذي يتحكم أفقياً
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedSport == category['id'];

                  return GestureDetector(
                    onTap: () => fetchFilteredCourts(category['id']), // إغلاق برمي صحيح للأقواس وبدون أخطاء
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(255, 9, 142, 82) : Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : const Color.fromARGB(255, 9, 142, 82),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['title'], // عرض الاسم بالعربية
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // الجزء الأول: ملاعب الرياضة المحددة (نتائج الفلترة المتصلة بالسيرفر)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ملاعب الـ ${categories.firstWhere((c) => c['id'] == selectedSport)['title']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            isFilteredLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color.fromARGB(255, 9, 142, 82)))): filteredCourts.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد ملاعب متاحة لهذه الرياضة حالياً')))
                    : ListView.builder(
                        shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCourts.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return _buildCourtCard(filteredCourts[index]);
                        },
                      ),

            const SizedBox(height: 25),

            // الجزء الثاني والأسفل: بطاقة تعرض جميع الملاعب المتواجدة في قاعدة البيانات
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'استكشف جميع الملاعب المتوفرة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),

            isAllLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color.fromARGB(255, 9, 142, 82))))
                : allCourts.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد ملاعب مسجلة في النظام')))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allCourts.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return _buildCourtCard(allCourts[index]); // استخدام نفس التصميم الموحد والجميل
                        },
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // بطاقة عرض تفاصيل الملعب (البطاقة الموحدة السابقة)
  Widget _buildCourtCard(dynamic court) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              court['main_image'] ?? 'img/football1.jpg',
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 170,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court['name'] ?? 'ملعب كابتن',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  court['description'] ?? 'وصف الملعب متاح هنا لحجزه بكل سهولة.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    Text(
                      '${court['price_per_hour']} د.ج / ساعة',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 9, 142, 82),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // هنا سيتم إضافة الانتقال لصفحة تفاصيل الحجز لاحقاً
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('احجز الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}