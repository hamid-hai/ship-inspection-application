import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shipping_inspection_app/main.dart';
import 'package:shipping_inspection_app/sectors/drawer/settings/settings_channels.dart';
import 'package:shipping_inspection_app/sectors/drawer/settings/settings_sound.dart';
import 'package:shipping_inspection_app/sectors/drawer/settings/settings_username.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shipping_inspection_app/sectors/drawer/drawer_globals.dart'
    as globals;

import '../../utils/app_colours.dart';
import 'settings/settings_history.dart';

class MenuSettings extends StatefulWidget {
  const MenuSettings({Key? key}) : super(key: key);

  @override
  State<MenuSettings> createState() => _MenuSettingsState();
}

class _MenuSettingsState extends State<MenuSettings> {
  bool isSwitched = false;

  bool cameraSwitch = false;
  bool micSwitch = false;

  String usernameSubtext = "";

  Future<void> updateSwitches() async {
    var cameraStatus = await Permission.camera.status;
    if (mounted) {
      setState(() {
        if (cameraStatus.isGranted) {
          cameraSwitch = true;
        } else {
          cameraSwitch = false;
        }
      });
    }

    var micStatus = await Permission.microphone.status;
    if (mounted) {
      setState(() {
        if (micStatus.isGranted) {
          micSwitch = true;
        } else {
          micSwitch = false;
        }
      });
    }
  }

  void updateText() {
    setState(() {
      usernameSubtext = "Currently '" + globals.getUsername() + "'";
    });
  }

  @override
  Widget build(BuildContext context) {
    updateSwitches();
    updateText();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globals.getAppbarColour(),
        iconTheme: const IconThemeData(
          color: AppColours.appPurple,
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              'Common',
              style: globals.getSettingsTitleStyle(),
            ),
            tiles: [
              SettingsTile(
                title: const Text('Language'),
                leading:
                    const Icon(Icons.language, color: AppColours.appPurple),
                value: const Text('English'),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.navigation(
                title: const Text('History'),
                leading: const Icon(Icons.history, color: AppColours.appPurple),
                onPressed: (BuildContext context) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const SettingsHistory()));
                },
              ),
              SettingsTile.navigation(
                title: const Text('Channels'),
                leading:
                    const Icon(Icons.video_call, color: AppColours.appPurple),
                onPressed: (BuildContext context) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const SettingsChannels()));
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Tutorial'),
                leading: const Icon(Icons.book, color: AppColours.appPurple),
                activeSwitchColor: AppColours.appPurple,
                initialValue: globals.tutorialEnabled,
                onToggle: (bool value) {
                  globals.setTutorialEnabled(value);
                  if (globals.getTutorialEnabled()) {
                    globals.addRecord("settings-enable", globals.getUsername(),
                        DateTime.now(), "AR Tutorial");
                  } else {
                    globals.addRecord("settings-disable", globals.getUsername(),
                        DateTime.now(), "AR Tutorial");
                  }
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Use System Theme'),
                activeSwitchColor: AppColours.appPurple,
                leading: const Icon(Icons.phone_android,
                    color: AppColours.appPurple),
                onPressed: (BuildContext context) {},
                initialValue: globals.systemThemeEnabled,
                onToggle: (bool value) {
                  globals.systemThemeEnabled = !globals.systemThemeEnabled;
                  if (globals.systemThemeEnabled) {
                    themeNotifier.value = ThemeMode.system;
                    if (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark) {
                      globals.darkModeEnabled = true;
                    } else {
                      globals.darkModeEnabled = false;
                    }
                  } else {} //Changes subtext colour on home page
                  setState(() {});
                  globals.savePrefs();
                  value = globals.systemThemeEnabled;
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Dark Mode'),
                activeSwitchColor: AppColours.appPurple,
                enabled: !globals.systemThemeEnabled,
                leading: Icon(Icons.dark_mode,
                    color: globals.getIconColourCheck(AppColours.appPurpleLight,
                        !globals.systemThemeEnabled)),
                onPressed: (BuildContext context) {},
                initialValue: globals.darkModeEnabled,
                onToggle: (bool value) {
                  globals.darkModeEnabled = !globals.darkModeEnabled;
                  if (globals.darkModeEnabled) {
                    themeNotifier.value = ThemeMode.dark;
                  } else {
                    themeNotifier.value = ThemeMode.light;
                  } //Changes subtext colour on home page
                  setState(() {});
                  globals.savePrefs();
                  value = globals.darkModeEnabled;
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Account',
              style: globals.getSettingsTitleStyle(),
            ),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Username'),
                leading:
                    const Icon(Icons.text_format, color: AppColours.appPurple),
                value: Text(usernameSubtext),
                onPressed: (BuildContext context) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const SettingsUsername()));
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'System',
              style: globals.getSettingsTitleStyle(),
            ),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('Camera'),
                activeSwitchColor: AppColours.appPurple,
                leading:
                    const Icon(Icons.camera_alt, color: AppColours.appPurple),
                onToggle: (bool value) async {
                  var status = await Permission.camera.status;
                  if (status.isDenied) {
                    if (await Permission.camera.request().isGranted) {
                      globals.addRecord("settings-permission-add",
                          globals.getUsername(), DateTime.now(), "Camera");
                      await FirebaseFirestore.instance
                          .collection("History_Logging")
                          .add({
                            'title': "Adding camera permissions",
                            'username': globals.getUsername(),
                            'time': DateTime.now(),
                            'permission': 'Camera',
                          })
                          .then((value) => debugPrint("Record has been added"))
                          .catchError((error) =>
                              debugPrint("Failed to add record: $error"));
                      globals.savePrefs();
                      globals.homeStateUpdate();
                      cameraSwitch = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Camera Permission Granted!')),
                      );
                    } else {
                      cameraSwitch = false;
                      openAppSettings();
                    }
                  } else {
                    openAppSettings();
                  }
                  setState(() {
                    value = cameraSwitch;
                  });
                },
                initialValue: cameraSwitch,
              ),
              SettingsTile.switchTile(
                title: const Text('Microphone'),
                activeSwitchColor: AppColours.appPurple,
                leading: const Icon(Icons.mic, color: AppColours.appPurple),
                onToggle: (bool value) async {
                  var status = await Permission.microphone.status;
                  if (status.isDenied) {
                    if (await Permission.microphone.request().isGranted) {
                      globals.addRecord("settings-permission-add",
                          globals.getUsername(), DateTime.now(), "Microphone");
                      await FirebaseFirestore.instance
                          .collection("History_Logging")
                          .add({
                            'title': "Adding microphone permissions",
                            'username': globals.getUsername(),
                            'time': DateTime.now(),
                            'permission': 'Microphone',
                          })
                          .then((value) => debugPrint("Record has been added"))
                          .catchError((error) =>
                              debugPrint("Failed to add record: $error"));
                      globals.savePrefs();
                      globals.homeStateUpdate();
                      micSwitch = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Microphone Permission Granted!')),
                      );
                    } else {
                      micSwitch = false;
                      openAppSettings();
                    }
                  } else {
                    openAppSettings();
                  }
                  setState(() {
                    value = micSwitch;
                  });
                },
                initialValue: micSwitch,
              ),
              SettingsTile.navigation(
                title: const Text('Sound'),
                leading:
                    const Icon(Icons.volume_up, color: AppColours.appPurple),
                onPressed: (BuildContext context) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const SettingsSound()));
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text("AR Model Credits:"),
            tiles: [
              SettingsTile.navigation(
                title: const Text(
                  '"Fire Extinguisher" (https://skfb.ly/onUZp) by oooFFFFEDDMODELS is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              SettingsTile.navigation(
                title: const Text(
                  '"Valve II" (https://skfb.ly/6zxYE) by Víctor Hernández is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              SettingsTile.navigation(
                title: const Text(
                  '"Lifeboat Compact" (https://skfb.ly/o6SXv) by jeffgeoff95 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
