import '../constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {

  final bool isEnable;
  final String labelText;
  final String value;
  final int maxLine;
  final TextInputAction inputAction;
  final Function(String term) onFieldSubmitted;
  final Function() onEditingComplete;
  final Function(String value) onValidate;
  final Function(String value) onChanged;
  final TextInputType textInputType;
  final bool isPassword;
  final bool autoFocus;
  final TextDirection textDirection;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> textInputFormatter;
  final Widget prefixIcon;

  AppTextField({ this.maxLine, this.autoFocus, this.inputAction , this.textCapitalization, this.onFieldSubmitted, this.onEditingComplete, this.onValidate, @required this.labelText, this.textInputType, this.isPassword, this.textDirection, this.value, this.onChanged, this.textInputFormatter, this.isEnable, this.prefixIcon});

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {

  TextEditingController controller;
  bool isEmpty;

  @override
  void initState() {
    super.initState();

    controller = new TextEditingController();
    isEmpty = controller.text.isEmpty;
    controller.addListener(() {
      if (isEmpty != controller.text.isEmpty) {
        setState(() {
          isEmpty = controller.text.isEmpty;
        });
      }
    });

    if(widget.value != null){
      controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(3),
      child: Directionality(
        textDirection: widget.textDirection != null ? widget.textDirection : TextDirection.ltr,
        child: TextFormField(
          controller: controller,
          enabled: widget.isEnable != null ? widget.isEnable : true,
          cursorColor: AppColors.primaryColor,
          style: TextStyle(fontSize: 17, color: Colors.grey[700]),
          maxLines: widget.maxLine != null ? widget.maxLine : 1,
          textInputAction: widget.inputAction != null ? widget.inputAction : TextInputAction.next,
          autofocus: widget.autoFocus != null ? widget.autoFocus : false,
          keyboardType: widget.textInputType != null ? widget.textInputType : TextInputType.text,
          obscureText: widget.isPassword != null ? widget.isPassword : false,
          textCapitalization: widget.textCapitalization != null ? widget.textCapitalization : TextCapitalization.none,
          onFieldSubmitted: (term){
            widget.onFieldSubmitted != null ? widget.onFieldSubmitted(term) : FocusScope.of(context).nextFocus();
          },
          onEditingComplete: (){
            widget.onEditingComplete != null ?? widget.onEditingComplete();
          },
          onChanged: (value){
            widget.onChanged(value);
          },
          autocorrect: false,
          enableSuggestions: false,
          validator: (value) {
            return widget.onValidate != null ? widget.onValidate(value) : null;
          },
          inputFormatters: widget.textInputFormatter != null ? widget.textInputFormatter : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(20, 17, 0, 17),
            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            errorMaxLines: 1,
            errorStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(
                borderSide:  BorderSide(color: AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            focusedBorder:OutlineInputBorder(
                borderSide:  BorderSide(color: AppColors.primaryColor, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            prefixIcon: widget.prefixIcon != null ? widget.prefixIcon : null,
            suffixIcon: controller.text.isNotEmpty ? removeButton() : null,
          ),
        ),
      ),
    );
  }

  Widget removeButton(){
    return GestureDetector( onTap: (){ controller.clear(); widget.onChanged(''); }, child: Icon(Icons.cancel, size: 21, color: Colors.grey[400]));
  }
}
