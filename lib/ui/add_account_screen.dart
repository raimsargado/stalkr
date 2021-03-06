// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stalkr/core/di/service_locator.dart';
import 'package:stalkr/domain/i_account_repo.dart';
import 'package:stalkr/infra/account/account_dao.dart';
import 'package:stalkr/infra/service/i_user_service.dart';
import 'package:stalkr/ui/reusables/router.dart';
import 'package:stalkr/ui/edit_account_screen.dart';
import 'package:stalkr/ui/details_screen2.dart';
import 'package:stalkr/ui/reusables/stalkr_alert_dialog.dart';
import 'package:stalkr/ui/reusables/stalkr_app_bar.dart';
// import 'package:stalkr/storage/prefs.dart';
// import 'storage/user_details.dart';

import '../application/app_stream.dart';
import '../domain/account.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  final String emptyMessage;

  // ignore: prefer_const_constructors_in_immutables
  MainScreen({
    Key? key,
    required this.emptyMessage,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final _nameCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  final _phoneNumberCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  late DateTime _birthdatePicker = DateTime.now();
  var _appStream = AppStream();
  var _accountRepo = locator<IAccountRepo>();
  var _accountService = locator<IUserService>();
  String? _imageLocalPath;
  String? get _statusOutput => _nameCtrl.text.isNotEmpty
      ? "${_nameCtrl.text}, ${_statusCtrl.text}"
      : null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("state lifecycle $state");
    switch (state) {
      case AppLifecycleState.resumed:
        //online
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        //off line
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StalkrAppBar.appBar("Add account"),
      body: SingleChildScrollView(child: _buildContent(Account())),
      /* StreamBuilder(
        initialData: Account(),
        stream: _appStream.valOutput,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.data != null) {
                Account account = snapshot.data ?? Account();
                _nameCtrl.text = account.name;
                _statusCtrl.text = account.status ?? 'No stats';
                _phoneNumberCtrl.text = account.number.toString();
                _birthDateCtrl.text = account.birthDate ?? "11/15";
                return SingleChildScrollView(child: _buildContent(account));
              } else {
                return Container();
              }
          }
          // if (snapshot.data == null &&
          //     snapshot.connectionState != ConnectionState.done) {
          //   return Center(child: CircularProgressIndicator());
          // } else {
          //   Account account = snapshot.data ?? Account();
          //   _nameCtrl.text = account.name;
          //   _statusCtrl.text = account.status ?? 'No stats';
          //   _phoneNumberCtrl.text = account.number.toString();
          //   _birthDateCtrl.text = account.birthDate!;
          //   return SingleChildScrollView(child: _buildContent(account));
          // }
        },
      ), */
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _save();
          // context.toScreen(DetailsScreen());
          // context.toScreen(DetailsScreen());
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.black,
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please fill up all fields"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _save() async {
    if (_statusCtrl.text.isEmpty ||
        _nameCtrl.text.isEmpty ||
        _phoneNumberCtrl.text.length < 12) {
      showDialog(context: context, builder: showAlertDialog(context));
    } else {
      String url =
          "https://avatars.dicebear.com/api/adventurer/${_nameCtrl.text}.svg";

      // await _appStream.saveAccount(Account(
      //   name: _nameCtrl.text,
      //   imageUrl: url,
      //   status: _statusCtrl.text,
      //   number: int.parse(_phoneNumberCtrl.text),
      //   birthDate: _birthDateCtrl.text,
      // ));

      // UNCOMMENT THIS
      /*    _accountRepo.saveAccount(Account(
        name: _nameCtrl.text,
        imageUrl: url,
        status: _statusCtrl.text,
        number: int.parse(_phoneNumberCtrl.text),
        birthDate: _birthDateCtrl.text,
      ));  */
      Account saveAccount = Account(
        name: _nameCtrl.text,
        imageUrl: url,
        status: _statusCtrl.text,
        number: int.parse(_phoneNumberCtrl.text),
        birthDate: _birthDateCtrl.text,
      );

      StalkrAlertDialog.showAlertDialog(context, "Sure to add?", saveAccount);

      //Navigator.pop(context);



      //var accounts = await _accountRepo.getAccounts();
    }
  }

  Widget _buildContent(Account account) {
    return Center(
      child: Container(
        width: 300,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[190],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom:30),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  child: account.imageUrl != null
                      ? SvgPicture.network(account.imageUrl!)
                      // ? Image(_imageLocalPath!)
                      : Container(),
                ),
              ),
            ),
            TextFormField(
              
              controller: _nameCtrl,
              decoration: InputDecoration(hintText: "Name"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                }
              },
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _statusCtrl,
              decoration: InputDecoration(hintText: "Status"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                }
              },
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _phoneNumberCtrl,
              maxLength: 12,
              decoration: InputDecoration(hintText: "Phone Number"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                }
                if (!text.startsWith('63')) {
                  return 'Must start with 63';
                }
                if (text.length < 12) {
                  return 'Must be 12 digits long';
                }
              },
              textAlign: TextAlign.center,
            ),
            // TextFormField(
            //     textInputAction: TextInputAction.done,
            //     controller: _birthDateCtrl,
            //     decoration: InputDecoration(labelText: "Birthdate"),
            //     onFieldSubmitted: (String fieldValue) {
            //       _save();
            //     },
            //     onTap: () async {
            //       DateTime? newDate = await showDatePicker(
            //           context: context,
            //           initialDate: _birthdatePicker,
            //           firstDate: DateTime(1990),
            //           lastDate: DateTime.now());
            //       if (newDate == null)
            //         return;
            //       else {
            //         _birthDateCtrl.text =
            //             "${newDate.month}/${newDate.day}/${newDate.year}";
            //       }
            //     }),
          ],
        ),
      ),
    );
  }
}
