import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'court_details_screen.dart';

class SportCourtsScreen extends StatefulWidget {
  final String sportKey; // 'football' أو 'basketball'
  final String sportTitle;

  const SportCourtsScreen({Key? key, required this.sportKey, required this.sportTitle}) : super(key: key);

  @override
  _SportCourtsScreenState createState() => _SportCourtsScreenState();
}

class _SportCourtsScreenState extends State<SportCourtsScreen> {
  List courts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCourtsFromServer();
  }

  // دالة الاتصال بالسيرفر لجلب الملاعب ديناميكياً
  Future<void> fetchCourtsFromServer() async {
    // إذا كنت تستخدم هاتف حقيقي ضع IP حاسوبك هنا بدلاً من 10.0.2.2
    final String url = 'http://localhost:57190/courts?sport=${widget.sportKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          courts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل جلب البيانات من السيرفر: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'تعذر الاتصال بالسيرفر، تأكد من تشغيله! $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(widget.sportTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF16162A),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 16), textAlign: TextAlign.center))
              : courts.isEmpty
                  ? const Center(child: Text("لا توجد ملاعب متاحة حالياً لهذه الرياضة", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courts.length,
                      itemBuilder: (context, index) {
                        final court = courts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CourtDetailsScreen ( courtId: court['id'])),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            color: const Color(0xFF222240),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عرض الصورة المحلية المخزنة في جهازك بناءً على المسار القادم من السيرفر
                                Image.asset(court['main_image'], height: 180, width: double.infinity, fit: BoxFit.cover),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(court['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            court['price_per_hour'] == 0 
                                                ? "السعر: مجاني" 
                                                : "السعر: ${court['price_per_hour']} DA/ساعة", 
                                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
                                          ),
                                          Text("السعة: ${court['capacity']}", style: const TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}