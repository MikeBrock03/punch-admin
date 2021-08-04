import 'package:flutter/material.dart';
import '../../../helpers/app_localizations.dart';
import 'time_picker_field.dart';

class ClockFields extends StatefulWidget {

  final GlobalKey<ScaffoldState> globalScaffoldKey;
  final bool submitSt;
  final DateTime now;
  DateTime dayInTime;
  DateTime dayOutTime;
  final String weekName;
  final int type;
  final String id;
  final Function() onAddTimeField;
  final Function(Widget instance) onRemoveTimeField;
  final Function(String id, DateTime time, int type) onSelect;
  final int index;

  ClockFields({ this.globalScaffoldKey, this.submitSt, this.now,
                this.dayInTime, this.dayOutTime, this.weekName,
                this.onAddTimeField, this.onRemoveTimeField,
                this.type, this.id, this.onSelect, this.index});

  @override
  _ClockFieldsState createState() => _ClockFieldsState();
}

class _ClockFieldsState extends State<ClockFields> {

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: TimePickerField(
            enabled: widget.submitSt,
            onTimePicked: (time){
              setState(() {
                if(time != null){
                  widget.dayInTime = DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute);
                  widget.onSelect(widget.id, DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute), 1);
                }else{
                  widget.dayInTime = null;
                  widget.onSelect(widget.id, null, 1);
                }
              });
            },
            value: widget.dayInTime,
            hint: AppLocalizations.of(context).translate('clock_id'),
            helpText: '${AppLocalizations.of(context).translate(widget.weekName)} ${AppLocalizations.of(context).translate('clock_id')} time',
            type: 'in',
            globalScaffoldKey: widget.globalScaffoldKey,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TimePickerField(
            enabled: widget.submitSt,
            onTimePicked: (time){
              setState(() {
                if(time != null){
                  widget.dayOutTime = DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute);
                  widget.onSelect(widget.id, DateTime(widget.now.year, widget.now.month, widget.now.day, time.hour, time.minute), 2);
                }else{
                  widget.dayOutTime = null;
                  widget.onSelect(widget.id, null, 2);
                }
              });
            },
            value: widget.dayOutTime,
            hint: AppLocalizations.of(context).translate('clock_out'),
            helpText: '${AppLocalizations.of(context).translate(widget.weekName)} ${AppLocalizations.of(context).translate('clock_out')} time',
            type: 'out',
            clockInValue: widget.dayInTime,
            globalScaffoldKey: widget.globalScaffoldKey,
          ),
        ),
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(icon: Icon(widget.type == 1 ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 30, color: widget.type == 1 ? Colors.green : Colors.red),splashColor: Colors.transparent,
            onPressed: (){
              if(widget.type == 1){
                widget.onAddTimeField();
              }else{
                setState(() {
                  widget.dayInTime = null;
                  widget.dayOutTime = null;
                  widget.onRemoveTimeField(widget);
                });
              }
            }
          ),
        ),
      ],
    );
  }
}