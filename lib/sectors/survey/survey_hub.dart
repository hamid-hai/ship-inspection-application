import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shipping_inspection_app/sectors/drawer/drawer_help.dart';
import 'package:shipping_inspection_app/sectors/questions/question_brain.dart';
import 'package:shipping_inspection_app/sectors/survey/survey_section.dart';
import 'package:shipping_inspection_app/utils/colours.dart';
import 'package:shipping_inspection_app/utils/homecontainer.dart';
import '../drawer/drawer_globals.dart' as history_global;

import '../../utils/qr_scanner_controller.dart';

QuestionBrain questionBrain = QuestionBrain();

class SurveyHub extends StatefulWidget {
  const SurveyHub({Key? key}) : super(key: key);

  @override
  _SurveyHubState createState() => _SurveyHubState();
}

class _SurveyHubState extends State<SurveyHub> {
  // Takes the user to the required survey section when pressing on an active survey.
  void loadQuestion(String questionID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveySection(questionID: questionID),
      ),
    );
  }

  // Checks if camera permissions have been granted and takes the user to the QR
  // camera, updating the history page to allow for tracking.
  void openCamera() async {
    if (await Permission.camera.status.isDenied) {
      await Permission.camera.request();
      debugPrint("Camera Permissions are required to access QR Scanner");
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScanner(),
        ),
      );
      // Adds a record of the QR camera being opened to the history page.
      history_global.addRecord(
          'opened', history_global.getUsername(), DateTime.now(), 'QR camera');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                  height: 100,
                  width: screenWidth,
                  padding: const EdgeInsets.all(0.0),
                  decoration: const BoxDecoration(
                      color: LightColors.sPurple,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                      )),
                  child: const Center(
                    child: Text(
                      "AR Hub",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
              ),

              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                          color: LightColors.sPurple,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Text(
                        "QR Camera",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    RawMaterialButton(
                      fillColor: LightColors.sDarkYellow,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: const Text(
                        "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {  },
                    ),

                    const Spacer(),

                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: LightColors.sPurpleL,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                      ),
                      child: const Text(
                        "Open QR Camera",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () async => openCamera()
                    ),
                  ],
                ),
              ),

              const Divider(),

              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        color: LightColors.sPurple,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Text(
                        "Sections",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    RawMaterialButton(
                      fillColor: LightColors.sDarkYellow,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: const Text(
                        "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {  },
                    ),

                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: TextFormField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            hintText: "Search",
                            contentPadding: EdgeInsets.zero
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                          )
                        ),
                      )
                    )
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                  right: 20,
                ),
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        const Text(
                          "Fire & Safety",
                          textScaleFactor: 1,
                        ),
                        Text(
                          "${questionBrain.getAnswerAmount("f&s")} of ${questionBrain.getQuestionAmount("f&s")}",
                          textScaleFactor: 1,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            loadQuestion('f&s');
                          },
                          child: const Text("Open"),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          "Lifesaving",
                          textScaleFactor: 1,
                        ),
                        Text(
                          "${questionBrain.getAnswerAmount("lifesaving")} of ${questionBrain.getQuestionAmount("lifesaving")}",
                          textScaleFactor: 1,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            loadQuestion('lifesaving');
                          },
                          child: const Text("Open"),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Text(
                          "Engine Room",
                          textScaleFactor: 1,
                        ),
                        Text(
                          "${questionBrain.getAnswerAmount("engine")} of ${questionBrain.getQuestionAmount("engine")}",
                          textScaleFactor: 1,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            loadQuestion('engine');
                          },
                          child: const Text("Open"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
