import 'package:flutter/material.dart';
import 'profile-screen.dart';
import 'sport-screen.dart';


class HomeScreen extends StatefulWidget {
  // 1. أضف هذا السطر فقط هنا لاستقبال اسم المستخدم
  final String username; 

  // الجزء الأول: المتغيرات والقائمة
  
 

  // 2. قم بتعديل هذا السطر (الـ Constructor) ليكون هكذا تماماً:
   HomeScreen({super.key, required this.username});
// الجزء الأول: المتغيرات والقائمة
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   int _selectedIndex = 0;
// تحويلها إلى late final وتمرير الاسم باستخدام widget.username
  late final List<Widget> _pages = [
    SportScreen(username: widget.username), // التبويب 0 (الرئيسية)
    const Center(child: Text('الحجوزات')),     // التبويب 1
    const Center(child: Text('الفريق')),       // التبويب 2
     ProfileScreen(),                    // التبويب 3 (البروفايل)
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final List<Map<String, String>> categories = const [
    {'title': 'كرة قدم', 'image': 'https://digiticket.dz/infrastructures/stade-miloud-hadefi-oran-598173e6'},
    {'title': 'كرة سلة', 'image': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=500'},
    {'title': 'ملاعب تنس', 'image': 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=500'},
    {'title': 'مسابح', 'image': 'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?q=80&w=500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. داخل الـ AppBar القديم الخاص بك، قم بتعديل سطر الـ title ليكون هكذا:
      
      
      // 4. اترك الـ body بالكامل ومجموعة الكروت (كرة القدم، السلة، إلخ) 
      // والدوال المساعدة كما كانت في كودك القديم تماماً دون تغيير حرف واحد!
// ...



body: _pages[_selectedIndex], // ✅ هذا السطر الديناميكي الجد

      // الجزء الرابع: شريط التنقل السفلي
      // الجزء الرابع المطور: شريط التنقل السفلي العائم (Floating)
      bottomNavigationBar: Padding(
        // ترك مسافات (هوامش) من جميع الجهات ليطفو الشريط ولا يلامس الحواف
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 10.0),
        child: Container(
          // إضافة تأثير الظل والحواف المائلة الدائرية المحيطة بالشريط
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0), // نسبة ميلان الحواف الزاوية
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // لون خفيف للظل ليبرز الطفو
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5), // اتجاه الظل للأسفل
              ),
            ],
          ),
          child: ClipRRect(
            // قص محتوى الشريط الداخلي ليتناسق مع انحناء الـ Container الخارجي
            borderRadius: BorderRadius.circular(25.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed, 
              backgroundColor: const Color.fromARGB(255, 9, 142, 82),
              selectedItemColor: const Color.fromARGB(255, 169, 217, 194),    
              unselectedItemColor: const Color.fromARGB(255, 92, 181, 117),   
              currentIndex: _selectedIndex,       
              onTap: _onItemTapped,               
              elevation: 0, // نلغي الارتفاع الافتراضي لأننا صنعنا ظلاً مخصصاً بالـ Container
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'الحجوزات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'الفريق',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'الحساب',
                ),
              ],
            ),
          ),
        ),
      ));}
      }