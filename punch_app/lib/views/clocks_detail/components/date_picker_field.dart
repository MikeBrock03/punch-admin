import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class DatePickerField extends StatefulWidget {

  final Function(DateTime dateTime) onDatePicked;
  final String hint;
  final String helpText;
  final DateTime value;
  final bool enabled;

  DatePickerField({ this.onDatePicked, this.hint, this.helpText, this.value, this.enabled });

  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {

  String selectedDate;

  @override
  void initState() {
    super.initState();

    if(widget.value != null){
      selectedDate = '${widget.hint}: ${widget.value.year}-${ widget.value.day.toString().padLeft(2, '0')}-${ widget.value.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async{
        if(widget.enabled){
          var date = await getSelectedDate(helpText: widget.helpText);
          if(date != null){
            setState(() {
              selectedDate = '${widget.hint}: ${widget.value.year}-${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
            });
            widget.onDatePicked(date);
          }
        }
      },
      child: Container(
        height: 53,
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[500],
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(child: Text(selectedDate != null ? selectedDate : widget.hint, style: TextStyle(fontSize: 14 ,color: selectedDate != null ? Colors.green[500] : Colors.grey[500]))),
      ),
    );
  }

  Future<DateTime> getSelectedDate({ String helpText }){

    return showDatePicker(
      context: context,
      initialDate:  widget.value,
      helpText: helpText,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
            buttonTheme: ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: AppColors.primaryColor,
              ),
            ),
          ),
          child: child,
        );
      },
    );
  }
}
