import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/bloc/cubit/settings_cubit.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/auth/core/bloc/login_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/input/def_text_field.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'LoginRoute')
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginCubit loginCubit;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    loginCubit = LoginCubit();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    loginCubit.close();
    super.dispose();
  }

  final router = getIt<AppRouter>();
  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      loginCubit.login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: loginCubit,
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            router.replaceAll([const MainRoute()]);
            context.read<SettingsCubit>().getSettings();
          }
          if (state is LoginFailure) {
            AppSnackBar.showErrorSnackBar(context, state.error);
          }
        },
        child: Scaffold(
          backgroundColor: ColorConstants.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 48.0),
                      _buildEmailField(),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(),
                      const SizedBox(height: 32.0),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          child: Image.asset(AssetConstants.logo.png, height: 100),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          duration: const Duration(milliseconds: 1200),
          child: AppText(
            title: LocaleKeys.general_welcome.tr(),
            textType: TextType.title24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        FadeInUp(
          duration: const Duration(milliseconds: 1300),
          child: AppText(
            title: LocaleKeys.general_welcome_description.tr(),
            textType: TextType.body,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: DefTextField(
        controller: _emailController,
        hintText: LocaleKeys.forms_enter_email.tr(),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(
          hintText: LocaleKeys.forms_enter_email.tr(),
          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return LocaleKeys.errors_required_field.tr();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1500),
      child: DefTextField(
        controller: _passwordController,
        hintText: LocaleKeys.forms_enter_password.tr(),
        obscureText: true,
        maxLines: 1,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        decoration: _inputDecoration(
          hintText: LocaleKeys.forms_enter_password.tr(),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return LocaleKeys.errors_required_field.tr();
          }
          return null;
        },
        onEditingComplete: () => _handleLogin(context),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return FadeInUp(
          duration: const Duration(milliseconds: 1600),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handleLogin(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : AppText(
                      title: LocaleKeys.buttons_login.tr(),
                      textType: TextType.body,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.bold,
                    ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
