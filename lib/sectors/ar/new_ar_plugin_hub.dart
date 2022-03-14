import 'package:flutter/material.dart';
// ---------- AR Plugins ----------
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';

import '../questions/question_brain.dart';
import '../survey/survey_section.dart';
import '../drawer/drawer_globals.dart' as history_globals;

QuestionBrain questionBrain = QuestionBrain();

class NewARHub extends StatefulWidget {
  final String questionID;
  final List<String> arContent;
  final bool openThroughQR;
  const NewARHub({
    Key? key,
    required this.questionID,
    required this.openThroughQR,
    required this.arContent,
  }) : super(key: key);

  @override
  _NewARHubState createState() => _NewARHubState();
}

class _NewARHubState extends State<NewARHub> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  void dispose() {
    super.dispose();
    arSessionManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _returnToSectionScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New AR'),
        ),
        body: SafeArea(
          child: Stack(
        children: <Widget>[
        ],
      ),
    );
  }

  // Returns the user to the survey_section screen, ensuring they are returned to the section they are currently surveying.
  void _returnToSectionScreen() async {
    // If the user opened a section through the QR scanner, then only one screen
    // needs to be removed from the stack.
    if (openThroughQR) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SurveySection(questionID: widget.questionID),
        ),
        (Route<dynamic> route) => true,
      );
      // If opened manually, two screens need to be removed otherwise there
      // will be two section screens open with the user needing to close both screens.
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SurveySection(questionID: widget.questionID),
        ),
        (Route<dynamic> route) => true,
      );
    }
    history_globals.addRecord("pressed", history_globals.getUsername(),
        DateTime.now(), 'return to section');
  }
}
