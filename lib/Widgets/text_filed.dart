import 'package:flutter/material.dart';

class CTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final InputDecoration inputDecoration;

  const CTextField({
    Key? key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.textInputType,
    this.textInputAction,
    this.validator,
    this.inputDecoration = const InputDecoration(),
  }) : super(key: key);

  @override
  _CTextFieldState createState() => _CTextFieldState();
}

class _CTextFieldState extends State<CTextField> {
  bool _showpassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialValue,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      keyboardType: widget.textInputType,
      validator: widget.validator,
      decoration: widget.inputDecoration.copyWith(
        hintText: widget.hintText,
      ),
    );
  }
}
