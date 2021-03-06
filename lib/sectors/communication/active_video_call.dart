// ===========================================
// Title: Active Video Screen
//
// Original Author: Hamid Iqbal, Osama Ilyas
// Contributors: Osama Ilyas, Hamid Iqbal,  Nathan Baitup,
//
// Commented By: Osama Ilyas, Hamid Iqbal,  Nathan Baitup,
//
// Created: Feb 16, 2022 15:24
// Last Modified: Mar 31, 2022 12:51
// ===========================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remove_view;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shipping_inspection_app/sectors/communication/keys/credentials.dart';

import '../../utils/app_colours.dart';
import '../questions/question_brain.dart';
import '../survey/survey_hub.dart';
import '../survey/survey_section.dart';

/// APP ID AND TOKEN
/// TOKEN MUST BE CHANGED EVERY 24HRS, IF NOT WORKING GENERATE NEW TOKEN
const appID = appIDAgora;
const agoraToken = tokenAgora;

// Uses the question brain to load questions to display to the surveyor / technical expert.
QuestionBrain questionBrain = QuestionBrain();

// Creates the default selection for the drop down list and automatically changes
// based on the user selection to update the questions being displayed.
String surveySection = 'noSelection';
List<String> displayQuestions = ['No items to display'];

int _mainCameraShown = 0;

class VideoCallFragment extends StatefulWidget {
  final String channelName;
  final String agoraToken;
  final String vesselID;

  const VideoCallFragment(
      {Key? key,
      required this.channelName,
      required this.agoraToken,
      required this.vesselID})
      : super(key: key);

  @override
  _VideoCallFragmentState createState() => _VideoCallFragmentState();
}

class _VideoCallFragmentState extends State<VideoCallFragment> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool muted = false;

  bool issueFlagged = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // Requesting permissions if not already granted from the PermissionHandler dependency
  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();

    // Creating an instance of the Agora Engine.
    RtcEngineContext context = RtcEngineContext(appID);
    var engine = await RtcEngine.createWithContext(context);
    // Event Handling of members joining and leaving.
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      // print('joinChannelSuccess $channel $uid');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      // print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      // print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));

    // Checks if the main camera is being shown, if not flips the camera.
    if (_mainCameraShown == 0) {
      await RtcEngine.instance?.switchCamera();
      setState(() {
        _mainCameraShown = 1;
      });
    }
    // Enabling video within the engine with the permissions granted before hand.
    await engine.enableVideo();
    // CHANNEL CONNECTION INFORMATION
    await engine.joinChannel(widget.agoraToken, widget.channelName, null, 0);
    // add 'widget.channelName' to pass channel name across from selection screen beforehand
    // print('HELLO THIS IS FROM THE CALLING SCREEN ' + widget.channelName);
  }

  // UI elements
  // Generated inside a new MaterialApp to avoid Agora glitches.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColours.appPurple,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _switch = !_switch;
                          });
                        },
                        child: Center(
                          child: _switch
                              ? _renderLocalPreview()
                              : _renderRemoteVideo(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                _issueFlaggedButton()
              ],
            ),
            _videoCallToolbar(),

            // Displays a drop down list to view survey questions and cycle through them.
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [ChooseSurveySection()],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Local device viewfinder.
  Widget _renderLocalPreview() {
    if (_joined) {
      // REFERENCE accessed 26/03/2022 https://stackoverflow.com/a/69237364
      // Used to adda rounded edge to the camera view.
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const rtc_local_view.SurfaceView(),
      );
      // END REFERENCE
    } else {
      return const Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Other participant viewfinder.
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: rtc_remove_view.SurfaceView(
          uid: _remoteUid,
          channelId: "test",
        ),
      );
    } else {
      return const Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }

  //Here is the bottom tool bar for video calling that will show what buttons the user what buttons they will have available to them
  Widget _videoCallToolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //The mute button.
          RawMaterialButton(
            onPressed: _onCallToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : AppColours.appPurple,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? AppColours.appPurple : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          //End call button.
          RawMaterialButton(
            onPressed: () => _onVideoCallEnd(context),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          //Switch camera button (Rear and Front)
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: const Icon(
              Icons.switch_camera,
              color: AppColours.appPurple,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),

          // Takes the user to the survey hub page if no selection has been made
          // or takes the user to a specific survey section page to leave a response.
          RawMaterialButton(
            onPressed: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                  overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => surveySection == 'noSelection'
                      ? SurveyHub(vesselID: widget.vesselID)
                      : SurveySection(
                          vesselID: widget.vesselID,
                          questionID: surveySection,
                          issueFlagged: issueFlagged,
                        ),
                ),
              );
            },
            child: const Icon(
              Icons.list_rounded,
              color: AppColours.appPurple,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ],
      ),
    );
  }

  //This widget is what allows the user to mute their audio stream if they need to. Using RtcEngine.instance?.muteLocalAudioStream()
  //to allow for it to happen.
  void _onCallToggleMute() {
    setState(() {
      muted = !muted;
    });
    RtcEngine.instance?.muteLocalAudioStream(muted);
  }

  //This widget allows the user to leave the channel, and go back to the channel entry page.
  void _onVideoCallEnd(BuildContext context) {
    RtcEngine.instance?.leaveChannel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    Navigator.pop(context);
  }

  //This widget allows the user to  switch from front and rear camera.
  void _onSwitchCamera() {
    RtcEngine.instance?.switchCamera();
  }

  // Creates a button that allows a technical expert to flag if there is an issue when completing a survey.
  Widget _issueFlaggedButton() {
    return Row(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: RawMaterialButton(
            onPressed: () => _onIssueFlagged(),
            elevation: 5.0,
            fillColor: AppColours.appYellow,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(10.0),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 35.0,
              color: Colors.white,
            ),
          ),
        ),
        issueFlagged
            ? const Text('Issue Flagged',
                style: TextStyle(
                  color: Colors.white,
                ))
            : const Text(''),
      ],
    );
  }

  // Creates an int to update if an issue has been flagged or not.
  int issueFlaggedCounter = 0;

  // Checks if the issue button has been pressed to update an issue setting from true to false.
  void _onIssueFlagged() async {
    setState(() {
      if (issueFlaggedCounter == 0) {
        issueFlagged = true;
        issueFlaggedCounter = 1;
      } else {
        issueFlagged = false;
        issueFlaggedCounter = 0;
      }
    });
  }
}

// Creates a widget that displays a dropdown list of all survey sections currently
// within the application, and displays the related questions to the sections for the
// technical expert and surveyor to see.
class ChooseSurveySection extends StatefulWidget {
  const ChooseSurveySection({Key? key}) : super(key: key);

  @override
  _ChooseSurveySectionState createState() => _ChooseSurveySectionState();
}

class _ChooseSurveySectionState extends State<ChooseSurveySection> {
  int widgetQuestionID = 0;

  @override
  Widget build(BuildContext context) {
    final double cWidth = MediaQuery.of(context).size.width * 0.58;
    return Column(
      children: <Widget>[
        // The container with the drop down list to select a survey section.
        Container(
          width: cWidth,
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: AppColours.appPurple,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Center(
            // The dropdown list taking the surveySection variable as the value
            // to update the list of questions shown.
            child: DropdownButton(
              value: surveySection,
              items: _dropdownItems(),
              style: const TextStyle(
                color: AppColours.appPurple,
              ),
              onChanged: (String? newSelection) {
                setState(
                  () {
                    surveySection = newSelection!;
                    _displaySurveyQuestions(newSelection);
                  },
                );
              },
            ),
          ),
        ),
        // Creates a container widget below the dropdown list to display the area specific questions.
        Column(
          children: <Widget>[
            InkWell(
              child: Container(
                width: cWidth,
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColours.appPurple,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Text(
                  "Question: " + displayQuestions[widgetQuestionID],
                  style: const TextStyle(
                    color: AppColours.appPurple,
                  ),
                ),
              ),
              onTap: () {
                _updateWidgetQuestion();
              },
            )
          ],
        )
      ],
    );
  }

  // Checks if the dropdown value is set to noSelection and sets the displayQuestions
  // list to the default text, else updates the list to include the questions for
  // a section.
  void _displaySurveyQuestions(String questionID) {
    setState(() {
      widgetQuestionID = 0;
      if (questionID == 'noSelection' || questionID == '') {
        widgetQuestionID = 0;
        displayQuestions = [];
        displayQuestions.add('No items to display');
      } else {
        displayQuestions = questionBrain.getQuestions(questionID);
      }
    });
  }

  // Returns a DropdownMenuItem of all questions within the Question Bank, with a
  // text value of the question title, and a value of the question ID.
  List<DropdownMenuItem<String>> _dropdownItems() {
    List<DropdownMenuItem<String>> surveySections = [];
    List<String> surveyIDs = questionBrain.getAllQuestionIDs();
    // Adds the default no selection to the list.
    surveySections.add(
      const DropdownMenuItem(
          child: Text("- Select a Survey -"), value: 'noSelection'),
    );
    // Iterates through the retrieval of all questions to get the question title
    // and ID to display in the dropdown menu.
    for (var questionID in surveyIDs) {
      surveySections.add(
        DropdownMenuItem(
            child: Text(questionBrain.getPageTitle(questionID)),
            value: questionID),
      );
    }
    return surveySections;
  }

  // Allows for questions to be cycled through when interacted with.
  void _updateWidgetQuestion() {
    setState(() {
      int newQuestion = widgetQuestionID + 1;
      if (newQuestion > (displayQuestions.length - 1)) {
        newQuestion = 0;
      }
      widgetQuestionID = newQuestion;
    });
  }
}
