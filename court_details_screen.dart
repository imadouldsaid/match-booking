
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourtDetailsScreen extends StatefulWidget {
  final int courtId;
  const CourtDetailsScreen({Key? key, required this.courtId}) : super(key: key);

  @override
  _CourtDetailsScreenState createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen> {
  Map? courtData;
  List<int> bookedHours = [];
  bool isLoading = true;
  String errorMessage = '';
  int? selectedHour;

  // الساعات الافتراضية المتاحة للحجز في اليوم من 4 مساءً إلى 11 ليلاً
  final List<int> availableHours = [16, 17, 18, 19, 20, 21, 22, 23];

  @override
  void initState() {
    super.initState();
    fetchCourtAvailability();
  }

  // جلب تفاصيل الملعب والساعات المحجوزة له من السيرفر الفعلي
  Future<void> fetchCourtAvailability() async {
    // نمرر الـ ID الخاص بالملعب وتاريخ اليوم للسيرفر ليقوم بفحص التوفر في جدول bookings
    final String url = 'http://localhost:57190/courts/${widget.courtId}/availability?date=2026-05-17';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courtData = data['court_details'];
          // تحويل قائمة الساعات المحجوزة القادمة من السيرفر إلى List<int>
          bookedHours = List<int>.from(data['booked_hours']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'خطأ في قراءة بيانات الملعب';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'تعذر الاتصال بالسيرفر لجلب التفاصيل!';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    if (errorMessage.isNotEmpty || courtData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 16))),
      );
    }

    // تجهيز قائمة الصور: الصورة الرئيسية مدمجة مع الصور الإضافية في شريط واحد متحرك
    List allImages = [courtData!['main_image']];
    if (courtData!['additional_images'] != null) {
      allImages.addAll(courtData!['additional_images']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(courtData!['name'], style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16162A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. شريط عرض الصور المتحرك المعتمد بالكامل على قاعدة البيانات
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return Image.asset(allImages[index], fit: BoxFit.cover, width: double.infinity);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courtData!['name'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        courtData!['price_per_hour'] == 0 
                            ? "السعر: مجاني" 
                            : "السعر: ${courtData!['price_per_hour']} DA/ساعة", 
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      Text("السعة: ${courtData!['capacity']}", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  const Text("الوصف التفصيلي:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(courtData!['description'] ?? 'لا يوجد وصف متاح لهذا الملعب.', style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.4)),
                  const SizedBox(height: 16),
                  
                  // زر الموقع الجغرافي
                  ElevatedButton.icon(
                    onPressed: () { /* كود فتح الرابط الجغرافي عند الحاجة */ },
                    icon: const Icon(Icons.map_outlined, color: Colors.white),
                    label: const Text("موقع الملعب على Google Maps", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 45)),
                  ),
                  
                  const Divider(color: Colors.white24, height: 32),
                  const Text("اختر ساعة الحجز المتاحة:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // 2. شبكة الساعات المرتبطة بمصفوفة الحجوزات من الـ FastAPI الفعلي
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2
                    ),
                    itemCount: availableHours.length,
                    itemBuilder: (context, index) {
                      int hour = availableHours[index];
                      bool isBooked = bookedHours.contains(hour); // إذا كان الرقم موجود في bookedHours يصبح معطلاً تلقائياً
                      bool isSelected = selectedHour == hour;

                      String hourLabel = hour > 12 ? "${hour - 12}:00 مساءً" : "$hour:00";

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBooked 
                              ? Colors.grey.withOpacity(0.15) 
                              : (isSelected ? Colors.greenAccent : const Color(0xFF222240)),
                          foregroundColor: isBooked ? Colors.white24 : (isSelected ? Colors.black : Colors.white),
                          elevation: isBooked ? 0 : 2,
                        ),
                        onPressed: isBooked ? null : () { 
                          setState(() { selectedHour = hour; });
                        },
                        child: Text(hourLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: selectedHour == null ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال طلب حجز لـ ${courtData!['name']} الساعة $selectedHour:00!'))
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                    child: const Text("تأكيد الحجز الآن", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}