import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  UserRole? _selectedRole;
  bool _obscurePin = true;
  bool _isLoading = false;
  
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Widget _buildRoleCard(UserRole role) {
    final isSelected = _selectedRole == role;
    final theme = Theme.of(context);
    
    Color roleColor;
    IconData roleIcon;
    String roleDescription;
    
    switch (role) {
      case UserRole.asha:
        roleColor = AppTheme.ashaColor;
        roleIcon = Icons.volunteer_activism_rounded;
        roleDescription = 'Community Health Worker';
        break;
      case UserRole.anm:
        roleColor = AppTheme.anmColor;
        roleIcon = Icons.medical_services_rounded;
        roleDescription = 'Auxiliary Nurse Midwife';
        break;
      case UserRole.phc:
        roleColor = AppTheme.phcColor;
        roleIcon = Icons.local_hospital_rounded;
        roleDescription = 'Primary Health Centre';
        break;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              roleColor.withOpacity(0.1),
              roleColor.withOpacity(0.05),
            ],
          ) : null,
          color: isSelected ? null : AppTheme.surfaceColor,
          border: Border.all(
            color: isSelected ? roleColor : AppTheme.neutralGray.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: roleColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [roleColor, roleColor.withOpacity(0.8)],
                ) : null,
                color: isSelected ? null : AppTheme.neutralGray.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: roleColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                roleIcon,
                color: isSelected ? Colors.white : AppTheme.neutralGray,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              role.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? roleColor : AppTheme.neutralGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              roleDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? roleColor.withOpacity(0.8) : AppTheme.neutralGray.withOpacity(0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please select your role'),
            ],
          ),
          backgroundColor: AppTheme.warningAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your PIN'),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(_pinController.text, _selectedRole!);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Invalid PIN or role combination'),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // App Logo and Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.strongShadow,
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'ASHA EHR',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Rural Healthcare Management',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.neutralGray,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.successGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Sahayak Sangam',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Role Selection Section
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.elevatedCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Role',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Choose your role to access the appropriate dashboard',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralGray,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(child: _buildRoleCard(UserRole.asha)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildRoleCard(UserRole.anm)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildRoleCard(UserRole.phc)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // PIN Input
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter PIN',
                            hintText: '••••',
                            counterText: '',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                color: AppTheme.neutralGray,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePin = !_obscurePin;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppTheme.neutralGray.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppTheme.neutralGray.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isLoading || authProvider.isLoading) ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: (_isLoading || authProvider.isLoading)
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Signing in...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Help text
                        Center(
                          child: Text(
                            'Default PIN: 1234 for all roles',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.neutralGray.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Empowering Rural Healthcare',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.health_and_safety_rounded,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ministry of Health & Family Welfare',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}