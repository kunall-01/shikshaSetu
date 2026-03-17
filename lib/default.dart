import 'package:flutter/material.dart';
import 'package:shikshasetutution/portals/account/login.dart';

class Default extends StatelessWidget {
  const Default({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                width: 200,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 130),
              const Text(
                'Who are you ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Login(
                            logintype: 'Parent',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                          //color: const Color.fromARGB(101, 135, 250, 244),
                          color: const Color.fromARGB(255, 182, 255, 251),
                          border: Border.all(
                            color: const Color.fromARGB(255, 79, 233, 241),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/parent_log.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, '/login');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Login(
                            logintype: 'Tutor',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                          //color: const Color.fromARGB(101, 135, 250, 244),
                          color: const Color.fromARGB(255, 182, 255, 251),
                          border: Border.all(
                            color: const Color.fromARGB(255, 79, 233, 241),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/tutor_log.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //Navigator.pushNamed(context, '/login');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Login(
                            logintype: 'Admin',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                          //color: const Color.fromARGB(101, 135, 250, 244),
                          color: const Color.fromARGB(255, 182, 255, 251),
                          border: Border.all(
                            color: const Color.fromARGB(255, 79, 233, 241),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/admin_log.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
