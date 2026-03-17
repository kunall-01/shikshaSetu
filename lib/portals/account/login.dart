import 'package:flutter/material.dart';
import 'package:shikshasetutution/models/paras.dart';
import 'package:shikshasetutution/components/common.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/models/user.dart';

class Login extends StatefulWidget {
  final String logintype;

  const Login({super.key, required this.logintype});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Loginparas formData = Loginparas();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 150,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Text(
                '${widget.logintype} Log In',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25, // Adjust as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 234, 234, 234)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            formData.userid = value;
                          },
                          decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18),
                              border: InputBorder.none,
                              hintText: 'User Id',
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 35, 35, 35),
                                  size: 22,
                                ),
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(179, 137, 136, 136),
                              )),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(179, 25, 25, 25),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 234, 234, 234)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            formData.para2 = value;
                          },
                          decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18),
                              border: InputBorder.none,
                              hintText: 'Password',
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Icon(
                                  Icons.lock,
                                  color: Color.fromARGB(255, 35, 35, 35),
                                  size: 22,
                                ),
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(179, 137, 136, 136),
                              )),
                          obscureText: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(179, 25, 25, 25),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  buildLoginButton(context, user)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context, UserProvider user) {
    return Container(
      height: 45,
      width: 500,
      decoration: BoxDecoration(
        color: widget.logintype == "Admin"
            ? color(blue)
            : widget.logintype == "Parent"
                ? color('#2f474e')
                : color('#2f474e'),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          FocusScope.of(context).unfocus();

          //REMOVE THIS WHEN DEPLOY, THIS IS ONLY FOR TESTING PURPOSE

          formData.para3 = widget.logintype;
          if (widget.logintype == "Admin") {
            formData.userid = "SYSTEM2024";
            formData.para2 = "Ram@123";
            user.loginProcess(context, formData);
          } else if (widget.logintype == "Tutor") {
            formData.userid = "neha99876";
            formData.para2 = "ram@123";
            user.loginProcess(context, formData);
          } else if (widget.logintype == "Parent") {
            formData.userid = "rekha9987";
            formData.para2 = "ram@123";
            user.loginProcess(context, formData);
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_right_alt,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
