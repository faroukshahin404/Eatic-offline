import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_assets_image.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_paths.dart';
import '../cubit/login_cubit.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

enum _LoginInputField { code, password }

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  _LoginInputField _activeInput = _LoginInputField.code;

  @override
  void initState() {
    super.initState();
    _codeFocusNode.addListener(_updateActiveInput);
    _passwordFocusNode.addListener(_updateActiveInput);
  }

  void _updateActiveInput() {
    if (_passwordFocusNode.hasFocus) {
      _activeInput = _LoginInputField.password;
      return;
    }
    if (_codeFocusNode.hasFocus) {
      _activeInput = _LoginInputField.code;
      return;
    }
  }

  TextEditingController _activeController(LoginCubit cubit) {
    return _activeInput == _LoginInputField.code
        ? cubit.codeController
        : cubit.passwordController;
  }

  void _insertDigit(LoginCubit cubit, String digit) {
    final controller = _activeController(cubit);
    final currentText = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : currentText.length;
    final end = selection.end >= 0 ? selection.end : currentText.length;
    final newText = currentText
        .replaceRange(start, end, digit)
        .replaceAll(RegExp(r'\s'), '');
    final offset = (start + digit.length).clamp(0, newText.length);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  void _backspace(LoginCubit cubit) {
    final controller = _activeController(cubit);
    final text = controller.text;
    if (text.isEmpty) return;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    if (start != end) {
      final newText = text.replaceRange(start, end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      return;
    }
    if (start <= 0) return;
    final newText = text.replaceRange(start - 1, start, '');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start - 1),
    );
  }

  void _enter(LoginCubit cubit) {
    if (_activeInput == _LoginInputField.code) {
      _passwordFocusNode.requestFocus();
      setState(() => _activeInput = _LoginInputField.password);
      return;
    }
    cubit.login();
  }

  @override
  void dispose() {
    _codeFocusNode.removeListener(_updateActiveInput);
    _passwordFocusNode.removeListener(_updateActiveInput);
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    const numericKeyboard = TextInputType.numberWithOptions(
      decimal: false,
      signed: false,
    );
    return Form(
      key: cubit.formKey,
      child: LayoutBuilder(
        builder:
            (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              title: 'add_user_form.code'.tr(),
                              hint: 'add_user_form.code'.tr(),
                              controller: cubit.codeController,
                              focusNode: _codeFocusNode,
                              readOnly: true,
                              isOnlyNumbers: true,
                              keyboardType: numericKeyboard,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted:
                                  (_) => FocusScope.of(context).nextFocus(),
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'validation.required'.tr()
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              title: 'add_user_form.password'.tr(),
                              hint: 'add_user_form.password'.tr(),
                              controller: cubit.passwordController,
                              focusNode: _passwordFocusNode,
                              readOnly: true,
                              isPassword: true,
                              isOnlyNumbers: true,
                              keyboardType: numericKeyboard,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => cubit.login(),
                              maxLines: 1,
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'validation.required'.tr()
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            NumericTouchKeyboardWidget(
                              onDigitTap: (digit) => _insertDigit(cubit, digit),
                              onBackspaceTap: () => _backspace(cubit),
                              onEnterTap: () => _enter(cubit),
                            ),
                            const SizedBox(height: 12),
                            CustomButtonWidget(
                              height: 50,
                              isLoading: cubit.state is LoginLoading,
                              text: 'login',
                              onPressed: () => cubit.login(),
                            ),
                            const SizedBox(height: 12),
                            FutureBuilder<bool>(
                              future: cubit.isUsersTableEmptyFuture,
                              builder: (context, snapshot) {
                                if (snapshot.data != true) {
                                  return const SizedBox.shrink();
                                }
                                return CustomButtonWidget(
                                  height: 50,
                                  text: 'Skip',
                                  onPressed: () {
                                    context.go(AppPaths.main);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomAssetImage(
                            image: AppAssets.loading,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Powered by eatic',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class NumericTouchKeyboardWidget extends StatelessWidget {
  const NumericTouchKeyboardWidget({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    required this.onEnterTap,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback onEnterTap;

  @override
  Widget build(BuildContext context) {
    final keyboardStyle = Theme.of(context).textTheme.titleMedium;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < 9) {
              final value = keys[index];
              return _KeyboardKeyButton(
                label: value,
                textStyle: keyboardStyle,
                onPressed: () => onDigitTap(value),
              );
            }
            if (index == 9) {
              return _KeyboardKeyButton(
                label: 'Enter',
                textStyle: keyboardStyle,
                onPressed: onEnterTap,
              );
            }
            if (index == 10) {
              return _KeyboardKeyButton(
                label: '0',
                textStyle: keyboardStyle,
                onPressed: () => onDigitTap('0'),
              );
            }
            return _KeyboardKeyButton(
              icon: Icons.backspace_outlined,
              onPressed: onBackspaceTap,
            );
          },
        ),
      ],
    );
  }
}

class _KeyboardKeyButton extends StatelessWidget {
  const _KeyboardKeyButton({
    this.label,
    this.textStyle,
    this.icon,
    required this.onPressed,
  });

  final String? label;
  final TextStyle? textStyle;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: icon != null ? Icon(icon) : Text(label!, style: textStyle),
    );
  }
}
