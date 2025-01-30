import 'package:flutter/material.dart';
import 'package:poultry_management/screens/login_screen.dart';
import 'package:poultry_management/screens/register_screen.dart';
import 'package:poultry_management/theme/theme.dart';
import 'package:poultry_management/widgets/customScaffold.dart';
import 'package:poultry_management/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Customscaffold(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logologo.webp', // Path to your logo image
                  fit: BoxFit.contain,
                  width: 120, // Set the desired width
                  height: 120, // Set the desired height
                ),
              ),
            ),
            // Title and intro text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: 'FEATHERHUB!\n',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Colors.deepPurple,
                        )),
                  ],
                ),
              ),
            ),
            // Add vertical space before buttons
            SizedBox(height: 190),  // Add extra space here to push buttons down
            // Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: LoginScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const RegisterScreen(),
                      color: Colors.white,
                      textColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Extra text (below the buttons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '\nEffortlessly track and optimize your farm’s productivity.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 18, 1, 33),
                      ),
                    ),
                    TextSpan(
                      text: '\n\nGet started by signing in or creating a new account.',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
