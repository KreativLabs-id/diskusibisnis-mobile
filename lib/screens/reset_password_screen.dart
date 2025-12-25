import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // We need to call an API endpoint to reset password using the token
      // Currently ApiService might not have this specific method wrapper for the token-based reset
      // Let's implement the call directly or add it to ApiService.
      // Based on typical structure, checks if we can use ApiService or need to add it.
      // Checking backend controller: resetPassword endpoint expects { token, newPassword }

      await _api.resetPassword(widget.token, _newPasswordController.text);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Sukses'),
            content: const Text(
                'Password berhasil direset. Silakan login dengan password baru Anda.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close ResetPasswordScreen
                  // Optional: Navigate to Login if not already there, but usually popping back to initial route works
                },
                child: const Text('Login Sekarang'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat Password Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan password baru Anda di bawah ini.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isObscureNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNew ? LucideIcons.eye : LucideIcons.eyeOff,
                    ),
                    onPressed: () =>
                        setState(() => _isObscureNew = !_isObscureNew),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(LucideIcons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm ? LucideIcons.eye : LucideIcons.eyeOff,
                    ),
                    onPressed: () =>
                        setState(() => _isObscureConfirm = !_isObscureConfirm),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
