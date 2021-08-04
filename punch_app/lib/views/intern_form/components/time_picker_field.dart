import 'package:flutter/material.dart';
import 'package:punch_app/helpers/message.dart';
import '../../../constants/app_colors.dart';

class TimePickerField extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  final Function(TimeOfDay timeOfDay) onTimePicked;
  final String hint;
  final String helpText;
  final DateTime value;
  final bool enabled;
  final String type;
  final DateTime clockInValue;

  TimePickerField({ this.onTimePicked, this.hint, this.helpText, this.value, this.enabled, this.type, this.clockInValue, this.globalScaffoldKey});

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {

  String selectedTime;

  @override
  void initState() {
    super.initState();

    if(widget.value != null){
      selectedTime = '${widget.hint}: ${ widget.value.hour.toString().padLeft(2, '0')}:${ widget.value.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async{
        if(widget.enabled){

          if(widget.type != null && widget.type == 'out' && widget.clockInValue == null ){
            Message.show(widget.globalScaffoldKey, 'Please set clock in time first');
          }else{
            var time = await getSelectedTime(helpText: widget.helpText);

            if(time == null){
              return;
            }

            if(widget.type == 'out'){
              double cOut = time.hour + time.minute/60.0;
              double cIn = widget.clockInValue.hour + widget.clockInValue.minute/60.0;

              if(cOut <= cIn){
                Message.show(widget.globalScaffoldKey, 'Clock out time shouldn\'t before or equal clock in time');
                setState(() {
                  selectedTime = null;
                });
              }else{
                setState(() {
                  selectedTime = '${widget.hint}: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                });
                widget.onTimePicked(time);
              }
            }else{
              setState(() {
                selectedTime = '${widget.hint}: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              });
              widget.onTimePicked(time);
            }

          }
        }
      },
      onLongPress: (){
        if(widget.enabled){
          setState(() {
            selectedTime = null;
          });
          widget.onTimePicked(null);
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
        child: Center(child: Text(selectedTime != null ? selectedTime : widget.hint, style: TextStyle(fontSize: 13 ,color: selectedTime != null ? Colors.green[500] : Colors.grey[500]))),
      ),
    );
  }

  Future<TimeOfDay> getSelectedTime({ String helpText }){
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: helpText,
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