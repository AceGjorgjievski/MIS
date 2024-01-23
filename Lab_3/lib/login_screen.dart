import 'package:exam_schedule/exam_schedule.dart';
import 'package:exam_schedule/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _email = "";
  String _password = "";
  String _errorMessage = '';

  void _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      print("User Logged In: ${userCredential.user!.email}");
      // setState(() {
      //   _errorMessage = '';
      // });
      _errorMessage = '';
    } on FirebaseAuthException catch (e) {
      // setState(() {
      //   _errorMessage = e.message!;
      // });
      _errorMessage = e.message!;
      print("Error During Login: $e");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                  validator: validateEmail,
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                  validator: validatePassword,
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Center(
                      child: Text(_errorMessage,
                          style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        //back stack na activities !!
                        if (_formKey.currentState!.validate()) {
                          // _handleLogin();
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text);
                            _errorMessage = '';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExamSchedule(
                                  subjectName: "",
                                  dateTime: DateTime.now(),
                                ),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            _errorMessage = e.message!;
                          }
                          setState(() {

                          });
                        }
                      },
                      child: const Text("Login"),
                    ),
                    const Text('Do not have an account yet? Register!'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ), (route) => route.isFirst
                        );
                      },
                      child: const Text("Register"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'E-mail address is required.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Invalid E-mail Address format.';

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Password is required.';

  return null;
}
