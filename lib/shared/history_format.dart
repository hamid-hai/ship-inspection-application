import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shipping_inspection_app/sectors/drawer/drawer_globals.dart'
as app_globals;

import '../utils/app_colours.dart';

List<Widget> formatRecords() {

  //Organise records by date
  for (var i = 0; i < app_globals.records.length; i++) {
    app_globals.records.sort((a, b){ //sorting in ascending order
      return a.getDatetime.compareTo(b.getDatetime);
    });
  }


  //Format records into text
  List<Widget> recordListTiles = [const SizedBox(height: 15)];
  for (var i = 0; i < app_globals.records.length; i++) {
    var currentRecord = app_globals.records[i];
    List<String> currentRecordText = List<String>.filled(5, "");
    var blockRecord = false;

    switch (currentRecord.type) {

    // CATEGORY: Section Response Logging
      case "add":
        {
          if (app_globals.historyPrefs[1]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " added a response to section ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Section Entering Logging
      case "enter":
        {
          if (app_globals.historyPrefs[0]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " visited the ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " section at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Communications Logging
      case "call":
        {
          if (app_globals.historyPrefs[4]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " joined channel '";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = "' at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // Unclear usage: For opening via QR
    // CATEGORY: QR Usage Logging
      case "opened":
        {
          if (app_globals.historyPrefs[3]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " opened ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // Unclear Usage: For leaving via QR
    // CATEGORY: QR Usage Logging
      case "pressed":
        {
          if (app_globals.historyPrefs[3]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " pressed ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Settings Change Logging
      case "settings-permission-add":
        {
          if (app_globals.historyPrefs[2]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " added device permissions for the ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Settings Change Logging
      case "settings-username-change":
        {
          if (app_globals.historyPrefs[2]) {
            currentRecordText[1] = " changed the device's username to ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Settings Change Logging
      case "settings-language-change":
        {
          if (app_globals.historyPrefs[2]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " changed the device's language to ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Settings Change Logging
      case "settings-enable":
        {
          if (app_globals.historyPrefs[2]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " enabled setting ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Settings Change Logging
      case "settings-disable":
        {
          if (app_globals.historyPrefs[2]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " disabled setting ";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = " at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Channel Logging
      case "channels-new":
        {
          if (app_globals.historyPrefs[5]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " saved channel '";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = "' at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Channel Logging
      case "channels-edit":
        {
          if (app_globals.historyPrefs[5]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " edited channel '";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = "' at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Channel Logging
      case "channels-generate":
        {
          if (app_globals.historyPrefs[5]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " generated a channel named '";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = "' at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

    // CATEGORY: Channel Logging
      case "channels-delete":
        {
          if (app_globals.historyPrefs[5]) {
            currentRecordText[0] = currentRecord.user;
            currentRecordText[1] = " deleted channel '";
            currentRecordText[2] = currentRecord.section;
            currentRecordText[3] = "' at ";
            currentRecordText[4] = DateFormat('kk:mm (yyyy-MM-dd)')
                .format(currentRecord.dateTime);
          } else {
            blockRecord = true;
          }
        }
        break;

      default:
        {
          currentRecordText[0] = "NULL RECORD";
          blockRecord = true;
        }
        break;
    }

    if(!blockRecord) {
      recordListTiles.add(RecordWidget(
        record: currentRecordText,
      ));
    }
  }
  return recordListTiles;
}

Widget getHistoryBody() {
  if (app_globals.historyEnabled) {
    if (app_globals.records.isNotEmpty) {
      return ListView(
          padding: const EdgeInsets.all(8),
          children: formatRecords(),
      );
    } else {
      return const Center(
          child: Text("There are currently no actions logged.",
            style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic),
          ),
      );
    }
  } else {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("History logging has been disabled.",
              style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic),),
            SizedBox(
              height: 15,
            ),
            Text("Navigate to Settings to re-enable this feature.",
              style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic),),
          ],
        )
    );
  }
}

class RecordWidget extends StatelessWidget {
  const RecordWidget({Key? key, required this.record}) : super(key: key);

  final List<String> record;

  final TextStyle bold = const TextStyle(fontWeight: FontWeight.bold);
  final String formattedDate = "";

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColours.appPurple),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: ListTile(
              title: Text.rich(
                TextSpan(text: "User ", children: <TextSpan>[
                  TextSpan(text: record[0], style: const TextStyle(fontStyle: FontStyle.italic, color: AppColours.appPurpleLight)),
                  TextSpan(text: record[1]),
                  TextSpan(text: record[2], style: const TextStyle(fontStyle: FontStyle.italic, color: AppColours.appPurpleLight)),
                  TextSpan(text: record[3]),
                  TextSpan(text: record[4], style: const TextStyle(fontStyle: FontStyle.italic, color: AppColours.appPurpleLight))
                ]),
              )),
      ),
    ]);
  }
}