import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StadiumsListScreen extends StatefulWidget {
  final String sportType;
  const StadiumsListScreen({super.key, required this.sportType});

  @override
  State<StadiumsListScreen> createState() => _StadiumsListScreenState();
}

class _StadiumsListScreenState extends State<StadiumsListScreen> {
  List stadiums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStadiums();
  }

  Future<void> fetchStadiums() async {
    // ملاحظة: استبدل 10.0.2.2 بالـ IP الخاص بجهازك إذا كنت تفحص من هاتف حقيقي
    final url = Uri.parse('http://localhost:57190/stadiums/${widget.sportType}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          stadiums = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ملاعب ${widget.sportType}"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : stadiums.isEmpty 
          ? const Center(child: Text("لا توجد ملاعب مضافة حالياً في هذه الفئة"))
          : ListView.builder(
              itemCount: stadiums.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الصورة الكبيرة للملعب
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(stadiums[i]['image_url']), 
                          fit: BoxFit.cover
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // العنوان والوصف الخفيف
                    Text(
                      stadiums[i]['name'], 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stadiums[i]['description'], 
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)
                    ),
                    const Divider(height: 30, thickness: 1),
                  ],
                ),
              ),
            ),
    );
  }
}