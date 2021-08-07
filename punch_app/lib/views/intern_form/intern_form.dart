import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:provider/provider.dart';
import 'components/clock_fields.dart';
import 'components/avatar_picker.dart';
import '../../models/clock_field_model.dart';
import '../../view_models/interns_view_model.dart';
import '../../view_models/companies_view_model.dart';
import '../../services/firebase_storage.dart';
import '../../helpers/loading_dialog.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../view_models/user_view_model.dart';
import '../../helpers/fading_edge_scrollview.dart';
import '../../helpers/app_text_field.dart';
import '../../config/app_config.dart';
import '../../helpers/app_localizations.dart';
import '../../helpers/message.dart';

class InternForm extends StatefulWidget {
  final UserModel userModel;
  final Function() onFinish;

  InternForm({this.userModel, this.onFinish});

  @override
  _InternFormState createState() => _InternFormState();
}

class _InternFormState extends State<InternForm> {
  final _formKey = GlobalKey<FormState>();
  final _globalScaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  String companyID, companyName, firstName, lastName, email, imageUrl;

  DateTime satInTime,
      satOutTime,
      sunInTime,
      sunOutTime,
      monInTime,
      monOutTime,
      tusInTime,
      tusOutTime,
      wedInTime,
      wedOutTime,
      thiInTime,
      thiOutTime,
      friInTime,
      friOutTime;

  final now = new DateTime.now();

  bool submitSt = true;

  List<ClockFieldModel> sunModelList = [];
  List<ClockFieldModel> monModelList = [];
  List<ClockFieldModel> tusModelList = [];
  List<ClockFieldModel> wedModelList = [];
  List<ClockFieldModel> thiModelList = [];
  List<ClockFieldModel> friModelList = [];
  List<ClockFieldModel> satModelList = [];

  @override
  void initState() {
    super.initState();

    if (widget.userModel != null) {
      companyID = widget.userModel.companyID;
      companyName = widget.userModel.companyName;
      firstName = widget.userModel.firstName;
      lastName = widget.userModel.lastName;
      email = widget.userModel.email;
      imageUrl =
          widget.userModel.imageURL != null && widget.userModel.imageURL != ''
              ? widget.userModel.imageURL
              : null;

      Iterable sunSchedules = widget.userModel.schedules['sun'];
      sunSchedules.forEach((element) {
        sunModelList.add(ClockFieldModel(
            day: 'sunday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable monSchedules = widget.userModel.schedules['mon'];
      monSchedules.forEach((element) {
        monModelList.add(ClockFieldModel(
            day: 'monday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable tueSchedules = widget.userModel.schedules['tue'];
      tueSchedules.forEach((element) {
        tusModelList.add(ClockFieldModel(
            day: 'tuesday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable wedSchedules = widget.userModel.schedules['wed'];
      wedSchedules.forEach((element) {
        wedModelList.add(ClockFieldModel(
            day: 'wednesday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable thuSchedules = widget.userModel.schedules['thu'];
      thuSchedules.forEach((element) {
        thiModelList.add(ClockFieldModel(
            day: 'thursday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable friSchedules = widget.userModel.schedules['fri'];
      friSchedules.forEach((element) {
        friModelList.add(ClockFieldModel(
            day: 'friday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });

      Iterable satSchedules = widget.userModel.schedules['sat'];
      satSchedules.forEach((element) {
        satModelList.add(ClockFieldModel(
            day: 'saturday',
            clockIn: element['clockIn'] != null
                ? DateTime.parse(element['clockIn'].toDate().toString())
                : null,
            clockOut: element['clockOut'] != null
                ? DateTime.parse(element['clockOut'].toDate().toString())
                : null));
      });
    } else {
      sunModelList
          .add(ClockFieldModel(day: 'sunday', clockIn: null, clockOut: null));

      monModelList
          .add(ClockFieldModel(day: 'monday', clockIn: null, clockOut: null));

      tusModelList
          .add(ClockFieldModel(day: 'tuesday', clockIn: null, clockOut: null));

      wedModelList.add(
          ClockFieldModel(day: 'wednesday', clockIn: null, clockOut: null));

      thiModelList
          .add(ClockFieldModel(day: 'thursday', clockIn: null, clockOut: null));

      friModelList
          .add(ClockFieldModel(day: 'friday', clockIn: null, clockOut: null));

      satModelList
          .add(ClockFieldModel(day: 'saturday', clockIn: null, clockOut: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        key: _globalScaffoldKey,
        appBar: AppBar(
          title: Text(
              widget.userModel != null
                  ? AppLocalizations.of(context).translate('edit') +
                      ' ' +
                      widget.userModel.firstName
                  : AppLocalizations.of(context).translate('add_intern'),
              style: TextStyle(fontSize: 18)),
          centerTitle: true,
          brightness: Brightness.dark,
          actions: [
            TextButton(
              onPressed: () {
                if (submitSt) {
                  if (widget.userModel != null) {
                    updateProfile();
                  } else {
                    submitForm();
                  }
                }
              },
              style: TextButton.styleFrom(
                shape:
                    CircleBorder(side: BorderSide(color: Colors.transparent)),
                primary: Colors.white,
              ),
              child: Text(AppLocalizations.of(context).translate('save'),
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: internFormBody(),
      ),
    );
  }

  Widget internFormBody() {
    return FadingEdgeScrollView.fromSingleChildScrollView(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        controller: scrollController,
        child: FadeInUp(
          from: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            child: Column(
              children: [
                Center(
                    child: SizedBox(
                        width: 180,
                        height: 180,
                        child: AvatarPicker(
                            imageURL: imageUrl,
                            enabled: submitSt,
                            onImageCaptured: (path) {
                              setState(() {
                                imageUrl = path;
                              });
                            }))),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 25),
                        AppTextField(
                          isEnable: submitSt,
                          labelText: AppLocalizations.of(context)
                              .translate('first_name'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: firstName,
                          onValidate: (value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .translate('first_name_empty_validate');
                            }

                            if (value.length < 2) {
                              return AppLocalizations.of(context)
                                  .translate('first_name_len_validate');
                            }

                            return null;
                          },
                          onChanged: (value) {
                            firstName = value;
                          },
                        ),
                        AppTextField(
                          isEnable: submitSt,
                          labelText: AppLocalizations.of(context)
                              .translate('last_name'),
                          inputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          value: lastName,
                          onValidate: (value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .translate('last_name_empty_validate');
                            }

                            if (value.length < 2) {
                              return AppLocalizations.of(context)
                                  .translate('last_name_len_validate');
                            }

                            return null;
                          },
                          onChanged: (value) {
                            lastName = value;
                          },
                        ),
                        widget.userModel == null
                            ? AppTextField(
                                isEnable: submitSt,
                                labelText: AppLocalizations.of(context)
                                    .translate('email'),
                                textInputFormatter: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[ ]'))
                                ],
                                inputAction: TextInputAction.done,
                                textInputType: TextInputType.emailAddress,
                                value: email,
                                onValidate: (value) {
                                  Pattern pattern =
                                      '[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}';

                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)
                                        .translate('email_empty_validate');
                                  }

                                  if (!RegExp(pattern).hasMatch(value)) {
                                    return AppLocalizations.of(context)
                                        .translate('email_validate');
                                  }

                                  return null;
                                },
                                onFieldSubmitted: (value) {
                                  email = value;
                                  FocusScope.of(context).unfocus();
                                },
                                onChanged: (value) {
                                  email = value;
                                },
                              )
                            : Container(),
                        SizedBox(height: 18),
                        Container(
                          width: MediaQuery.of(context).size.width - 90,
                          child: DropdownButtonFormField(
                            value: companyID,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(22, 20, 22, 12),
                              errorMaxLines: 1,
                              errorStyle: TextStyle(fontSize: 12),
                            ),
                            items: Provider.of<CompaniesViewModel>(context,
                                    listen: false)
                                .companyList
                                .map((UserModel model) {
                              return DropdownMenuItem<String>(
                                value: model.uID,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: new Text(model.companyName,
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              );
                            }).toList(),
                            dropdownColor: Colors.white,
                            validator: (value) {
                              if (value == null) {
                                return AppLocalizations.of(context)
                                    .translate('company_select_empty_validate');
                              }
                              return null;
                            },
                            hint: Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('select_company'),
                                  style: TextStyle(color: Colors.grey[500])),
                            ),
                            onChanged: submitSt
                                ? (value) => setState(() => companyID = value)
                                : null,
                          ),
                        ),
                        SizedBox(height: 50),
                        Center(
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('schedules'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold))),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context).translate('sunday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('sunday', sunModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context).translate('monday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('monday', monModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context).translate('tuesday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('tuesday', tusModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate('wednesday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('wednesday', wedModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate('thursday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('thursday', thiModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context).translate('friday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('friday', friModelList),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                              AppLocalizations.of(context)
                                  .translate('saturday'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal)),
                        ),
                        ...getClockFields('saturday', satModelList),
                        SizedBox(height: 50),
                        Center(
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('long_tap_remove_time'),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.normal))),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getClockFields(String day, List<ClockFieldModel> modelList) {
    List<Widget> fieldList = [];
    for (int i = 0; i < modelList.length; i++) {
      fieldList.add(GestureDetector(
        key: UniqueKey(),
        child: ClockFields(
          globalScaffoldKey: _globalScaffoldKey,
          submitSt: submitSt,
          now: now,
          weekName: modelList[i].day,
          dayInTime: modelList[i].clockIn,
          dayOutTime: modelList[i].clockOut,
          type: i == 0 ? 1 : 2,
          onSelect: (id, time, type) {
            if (time != null) {
              double tm = time.hour + time.minute / 60.0;

              bool inSt = false;
              bool outSt = false;

              modelList.forEach((element) {
                if (element.clockIn != null) {
                  double elTime =
                      element.clockIn.hour + element.clockIn.minute / 60.0;
                  if (tm < elTime) {
                    inSt = true;
                  }
                }
              });

              modelList.forEach((element) {
                if (element.clockOut != null) {
                  double elTime =
                      element.clockOut.hour + element.clockOut.minute / 60.0;
                  if (tm < elTime) {
                    outSt = true;
                  }
                }
              });

              if (inSt == false && outSt == false) {
                setState(() {
                  if (type == 1) {
                    modelList[i].clockIn = time;
                  } else {
                    modelList[i].clockOut = time;
                  }
                });
              } else {
                Message.show(_globalScaffoldKey,
                    'Selected time shouldn\'t before other times in the same day');
                setState(() {
                  if (type == 1) {
                    modelList[i].clockIn = null;
                  } else {
                    modelList[i].clockOut = null;
                  }
                });
              }
            } else {
              if (type == 1) {
                modelList[i].clockIn = null;
              } else {
                modelList[i].clockOut = null;
              }
            }
          },
          onRemoveTimeField: (instance) {
            setState(() {
              modelList.removeAt(i);
            });
          },
          onAddTimeField: () {
            setState(() {
              modelList.add(
                  ClockFieldModel(day: day, clockIn: null, clockOut: null));
            });
          },
        ),
      ));
    }
    return fieldList;
  }

  void submitForm() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      Future.delayed(Duration(milliseconds: 250), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialog();
          },
        );
      });

      setState(() {
        submitSt = false;
      });

      try {
        dynamic result =
            await Provider.of<FirebaseAuthService>(context, listen: false)
                .registerWithoutAuth(email: email.trim());

        if (result is UserModel) {
          if (imageUrl != null) {
            dynamic uploadResult =
                await Provider.of<FirebaseStorage>(context, listen: false)
                    .uploadAvatar(imagePath: imageUrl, uID: result.uID);
            result.imageURL =
                uploadResult != null && Uri.tryParse(uploadResult).isAbsolute
                    ? uploadResult
                    : null;
            createProfile(result);
          } else {
            createProfile(result);
          }
        } else {
          setState(() {
            submitSt = true;
          });

          await Future.delayed(Duration(milliseconds: 1500), () {
            Navigator.pop(context);
          });
          await Future.delayed(Duration(milliseconds: 800), () {
            Message.show(_globalScaffoldKey, result.toString());
          });
        }
      } catch (error) {
        if (!AppConfig.isPublished) {
          print('$error');
        }

        setState(() {
          submitSt = true;
        });

        await Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        });
        await Future.delayed(Duration(milliseconds: 800), () {
          Message.show(_globalScaffoldKey,
              AppLocalizations.of(context).translate('intern_add_fail'));
        });
      }
    }
  }

  void createProfile(UserModel model) async {
    try {
      String regCode = model.uID.toUpperCase().substring(0, 6);

      Map<String, dynamic> schedules = {
        'sat': satModelList.map((e) => e.toMap()).toList(),
        'sun': sunModelList.map((e) => e.toMap()).toList(),
        'mon': monModelList.map((e) => e.toMap()).toList(),
        'tue': tusModelList.map((e) => e.toMap()).toList(),
        'wed': wedModelList.map((e) => e.toMap()).toList(),
        'thu': thiModelList.map((e) => e.toMap()).toList(),
        'fri': friModelList.map((e) => e.toMap()).toList(),
      };

      Map<String, dynamic> clocks = {
        'sat': {'clock_in': null, 'clock_out': null},
        'sun': {'clock_in': null, 'clock_out': null},
        'mon': {'clock_in': null, 'clock_out': null},
        'tue': {'clock_in': null, 'clock_out': null},
        'wed': {'clock_in': null, 'clock_out': null},
        'thu': {'clock_in': null, 'clock_out': null},
        'fri': {'clock_in': null, 'clock_out': null},
      };

      UserModel userModel = UserModel(
          uID: model.uID,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          imageURL: model.imageURL != null ? model.imageURL : '',
          companyID: companyID,
          email: email.trim(),
          platform: Platform.operatingSystem,
          registererID: Provider.of<UserViewModel>(context, listen: false).uID,
          createdAt: Timestamp.now(),
          roleID: AppConfig.internUserRole.toDouble(),
          tags: [
            firstName.trim().toLowerCase(),
            lastName.trim().toLowerCase(),
            '${firstName.trim().toLowerCase()} ${lastName.trim().toLowerCase()}',
            email.trim().toLowerCase(),
            regCode
          ],
          schedules: schedules,
          clocks: clocks,
          regCode: regCode,
          status: true,
          verified: false,
          hasPassword: false);

      print('userModel : ${userModel.toString()}');

      await Provider.of<FirestoreService>(context, listen: false)
          .createProfile(userModel: userModel);
      await Provider.of<UserViewModel>(context, listen: false).sendEmail(
          message:
              'Howdy, ${firstName.trim()} ${lastName.trim()}! Your school administrator has signed you up to Punch, a neat time servicing application for internships. iOS click here: https://apps.apple.com/us/app/punch-intern/id1571327393. Android click here: https://play.google.com/store/apps/details?id=com.punch.android.intern&hl=en_US&gl=US. Your registration code is: $regCode',
          email: userModel.email);
      await Provider.of<UserViewModel>(context, listen: false).sendEmail(
          message:
              'Howdy, ${firstName.trim()} ${lastName.trim()}! Your school administrator has signed you up to Punch, a neat time servicing application for internships. iOS click here: https://apps.apple.com/us/app/punch-intern/id1571327393. Android click here: https://play.google.com/store/apps/details?id=com.punch.android.intern&hl=en_US&gl=US. Your registration code is: $regCode',
          email: Provider.of<UserViewModel>(context, listen: false).email);
      //Provider.of<CompaniesViewModel>(context, listen: false).addToList(model: userModel);

      await Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
      await Future.delayed(Duration(milliseconds: 800), () {
        Message.show(_globalScaffoldKey,
            AppLocalizations.of(context).translate('intern_add_success'));
      });
      await Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
    } catch (error) {
      if (!AppConfig.isPublished) {
        print('$error');
      }

      setState(() {
        submitSt = true;
      });

      await Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
      await Future.delayed(Duration(milliseconds: 800), () {
        Message.show(_globalScaffoldKey,
            AppLocalizations.of(context).translate('intern_add_fail'));
      });
    }
  }

  void updateProfile() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      Future.delayed(Duration(milliseconds: 250), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingDialog();
          },
        );
      });

      setState(() {
        submitSt = false;
      });

      try {
        UserModel model = widget.userModel;

        if (imageUrl != null && !imageUrl.startsWith('http')) {
          dynamic uploadResult =
              await Provider.of<FirebaseStorage>(context, listen: false)
                  .uploadAvatar(imagePath: imageUrl, uID: model.uID);
          model.imageURL =
              uploadResult != null && Uri.tryParse(uploadResult).isAbsolute
                  ? uploadResult
                  : null;
        } else {
          model.imageURL = imageUrl;
        }

        model.firstName = firstName.trim();
        model.lastName = lastName.trim();
        model.companyID = companyID;

        Map<String, dynamic> schedules = {
          'sat': satModelList.map((e) => e.toMapForFirebase()).toList(),
          'sun': sunModelList.map((e) => e.toMapForFirebase()).toList(),
          'mon': monModelList.map((e) => e.toMapForFirebase()).toList(),
          'tue': tusModelList.map((e) => e.toMapForFirebase()).toList(),
          'wed': wedModelList.map((e) => e.toMapForFirebase()).toList(),
          'thu': thiModelList.map((e) => e.toMapForFirebase()).toList(),
          'fri': friModelList.map((e) => e.toMapForFirebase()).toList(),
        };

        model.schedules = schedules;

        dynamic result =
            await Provider.of<FirestoreService>(context, listen: false)
                .updateInternProfile(userModel: model);

        if (result is bool && result) {
          Provider.of<InternsViewModel>(context, listen: false)
              .updateList(model: model);

          await Future.delayed(Duration(milliseconds: 1500), () {
            Navigator.pop(context);
          });
          await Future.delayed(Duration(milliseconds: 800), () {
            Message.show(
                _globalScaffoldKey,
                AppLocalizations.of(context)
                    .translate('intern_update_success'));
          });
          await Future.delayed(Duration(milliseconds: 1500), () {
            Navigator.pop(context);
          });
          widget.onFinish();
        } else {
          setState(() {
            submitSt = true;
          });
          widget.onFinish();
          await Future.delayed(Duration(milliseconds: 1500), () {
            Navigator.pop(context);
          });
          await Future.delayed(Duration(milliseconds: 800), () {
            Message.show(_globalScaffoldKey,
                AppLocalizations.of(context).translate('intern_update_fail'));
          });
        }
      } catch (error) {
        if (!AppConfig.isPublished) {
          print('$error');
        }

        setState(() {
          submitSt = true;
        });

        await Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
        });
        await Future.delayed(Duration(milliseconds: 800), () {
          Message.show(_globalScaffoldKey,
              AppLocalizations.of(context).translate('intern_update_fail'));
        });
      }
    }
  }
}
