import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _identifierController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController();      
  final TextEditingController _emailPasswordController = TextEditingController(); 
  final TextEditingController _usernameController = TextEditingController();   
  final TextEditingController _accountPasswordController = TextEditingController(); 

  bool _isLogin = true; 
  bool _isEmailVerifiedInFirebase = false; 
  String _userRole = 'لاعب'; 
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // ==========================================
        // 1. منطق تسجيل الدخول (المصحح والمربوط بالسيرفر)
        // ==========================================
        String emailToSignIn = _identifierController.text.trim();
        String passwordToSignIn = _accountPasswordController.text.trim();
        
        if (!emailToSignIn.contains('@')) {
          emailToSignIn = '${emailToSignIn.toLowerCase()}@stadium.com';
        }

        // أ: التحقق من الحساب في الفايربيز أولاً
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailToSignIn,
          password: passwordToSignIn,
        );

        // ب: التحقق من السيرفر المحلي وجلب البيانات من PostgreSQL
        final loginUrl = Uri.parse('http://localhost:57190/users/login');
        final loginResponse = await http.post(
          loginUrl,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "email": emailToSignIn,
            "password": passwordToSignIn,
          }),
        );

        if (loginResponse.statusCode == 200) {
          final responseData = json.decode(loginResponse.body);
          String displayName = responseData['user']['username'] ?? emailToSignIn.split('@')[0];

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen(username: displayName)),
            );
          }
        } else {
          final errorData = json.decode(loginResponse.body);
          throw Exception(errorData['detail'] ?? 'فشل التحقق من قاعدة البيانات المحلية');
        }

      } else {
        // ==========================================
        // 2. منطق إنشاء حساب جديد (تم تصحيح الرابط)
        // ==========================================
        if (!_isEmailVerifiedInFirebase) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _emailPasswordController.text.trim(),
          );

          setState(() {
            _isEmailVerifiedInFirebase = true;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت مصادقة البريد بنجاح! يرجى إكمال بيانات حسابك الآن.'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        } else {
          String displayName = _usernameController.text.trim();
          String accountPass = _accountPasswordController.text.trim();

          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePassword(accountPass);// تم تعديل الرابط هنا إلى /users/register ليطابق السيرفر تماماً
            final registerUrl = Uri.parse('http://localhost:57190/users/register'); 
            
            final response = await http.post(
              registerUrl,
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "uid": user.uid, 
                "username": displayName,
                "email": user.email,
                "role": _userRole,
                "account_password": accountPass, 
              }),
            );

            if (response.statusCode == 201 || response.statusCode == 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء الحساب وحفظه في السيرفر بنجاح!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen(username: displayName)),
                );
              }
            } else {
              final errorData = json.decode(response.body);
              throw Exception(errorData['detail'] ?? 'فشل الحفظ في السيرفر المحلي');
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ في النظام";
      if (e.code == 'user-not-found') message = "هذا المستخدم غير موجود";
      if (e.code == 'wrong-password') message = "كلمة المرور المأخوذة خاطئة";
      if (e.code == 'email-already-in-use') message = "البريد الإلكتروني مستخدم ومسجل مسبقاً";
      if (e.code == 'invalid-email') message = "صيغة البريد الإلكتروني غير صحيحة";
      if (e.code == 'weak-password') message = "كلمة المرور ضعيفة جداً";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception:", "")), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.65), 
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.sports_soccer, size: 85, color: Colors.greenAccent),
                    const SizedBox(height: 12),
                    const Text(
                      'STADIUM BOOKING',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'سجل دخولك واحجز ملعبك الآن' : 'أنشئ حسابك الأمني للملاعب',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 35),if (_isLogin) ...[
                      _buildTextField(
                        controller: _identifierController,
                        label: 'اسم المستخدم أو البريد الإلكتروني',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        controller: _accountPasswordController,
                        label: 'كلمة مرور الحساب',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                    ] else ...[
                      if (!_isEmailVerifiedInFirebase) ...[
                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني (Email) إجباري',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: _emailPasswordController,
                          label: 'كلمة مرور الـ Email الخاصة بك',
                          icon: Icons.vpn_key,
                          isPassword: true,
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: _usernameController,
                          label: 'اسم المستخدم للتطبيق',
                          icon: Icons.account_circle,
                        ),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          initialValue: _userRole,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'نوع المستخدم',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.group, color: Colors.greenAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'لاعب', child: Text('لاعب')),
                            DropdownMenuItem(value: 'قائد', child: Text('قائد فريق')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _userRole = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: _accountPasswordController,
                          label: 'كلمة مرور الحساب للتطبيق (للدخول مستقبلاً)',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                      ],
                    ],

                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                            )
                          : Text(
                              _isLogin 
                                  ? 'دخول' 
                                  : (!_isEmailVerifiedInFirebase ? 'تأكيد ومصادقة الـ Email' : 'إتمام وإنشاء الحساب'),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _isEmailVerifiedInFirebase = false; 
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isLogin ? 'ليس لديك حساب؟ إنشاء حساب جديد' : 'لديك حساب بالفعل؟ سجل دخولك الآن',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.greenAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'هذا الحقل إجباري، يرجى ملء البيانات';
        if (isPassword && val.length < 6) return 'يجب أن لا تقل كلمة المرور عن 6 رموز';
        return null;
      },
    );
  }
}
