import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/auth/core/bloc/login_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/input/def_text_field.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
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
          }
          if (state is LoginFailure) {
            AppSnackBar.showErrorSnackBar(context, state.error);
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: _LoginBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  _WelcomeSection(),
                  const SizedBox(height: 20),
                  _LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onLogin: () => _handleLogin(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  final Widget child;

  const _LoginBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade400,
          ],
        ),
      ),
      child: child,
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: AppText(
              title: LocaleKeys.general_welcome.tr(),
              textType: TextType.title,
              color: ColorConstants.white,
            ),
          ),
          const SizedBox(height: 10),
          FadeInUp(
            duration: const Duration(milliseconds: 1300),
            child: AppText(
              title: LocaleKeys.general_welcome_description.tr(),
              textType: TextType.body,
              color: ColorConstants.white,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),
              _InputFields(
                emailController: emailController,
                passwordController: passwordController,
                onLogin: onLogin,
              ),
              const SizedBox(height: 40),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return LoadingWidget();
                  }
                  return _LoginButton(onLogin: onLogin);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _InputFields({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(7, 65, 224, 0.294),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _TextFieldContainer(
              child: DefTextField(
                controller: emailController,
                hintText: LocaleKeys.forms_enter_email.tr(),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return LocaleKeys.errors_required_field.tr();
                  }
                  return null;
                },
              ),
            ),
            _TextFieldContainer(
              child: DefTextField(
                controller: passwordController,
                hintText: LocaleKeys.forms_enter_password.tr(),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return LocaleKeys.errors_required_field.tr();
                  }
                  return null;
                },
                onEditingComplete: onLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFieldContainer extends StatelessWidget {
  final Widget child;

  const _TextFieldContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: child,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoginButton({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: MaterialButton(
        onPressed: onLogin,
        height: 50,
        color: Colors.blue[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Center(
          child: AppText(
            title: LocaleKeys.buttons_login.tr(),
            textType: TextType.body,
            color: ColorConstants.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
