import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../screens/main/tab_manger.dart';
import '../../tools/Palette/theme.dart';
import 'sing_up_tab.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'samii.4reeal@gmail.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Sign in with email and password
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TabMangerScreen(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        String errorMessage = 'An error occurred. Please try again.';

        switch (error.message) {
          case 'Invalid login credentials':
            errorMessage = 'Invalid email or password.';
            break;
          case 'Email not confirmed':
            errorMessage = 'Please check your email and confirm your account.';
            break;
          case 'Invalid email':
            errorMessage = 'Please enter a valid email address.';
            break;
          default:
            errorMessage = error.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Sign in form
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Tajawal',
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Tajawal',
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 48),

                  // Sign in button
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: isLight ? light[500] : dark[500],
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isLight ? light[500]! : dark[500]!,
                                ),
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Forgot password feature coming soon!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Sign up link
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
