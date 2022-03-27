import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shipping_inspection_app/sectors/drawer/drawer_globals.dart'
    as globals;
import 'package:shipping_inspection_app/utils/colours.dart';

import '../../communication/channel.dart';

class SettingsChannels extends StatefulWidget {
  const SettingsChannels({Key? key}) : super(key: key);

  @override
  State<SettingsChannels> createState() => _SettingsChannelsState();
}

class _SettingsChannelsState extends State<SettingsChannels> {
  SettingsTile channelTile(Channel channel) {
    FontStyle emptyFont = FontStyle.normal;
    Row optionsRow = Row();

    if (channel.empty == false) {
      emptyFont = FontStyle.normal;
      optionsRow = Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              editChannel(channel, true);
              setState(() {});
            },
          ),
          IconButton(
            onPressed: () {
              deleteChannel(channel.channelID);
              globals.savePrefs();
              setState(() {});
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      );
    } else {
      emptyFont = FontStyle.italic;
      optionsRow = Row(children: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            editChannel(channel, false);
          },
        ),
      ]);
    }

    return SettingsTile(
      title: Text(
        channel.name,
        style: TextStyle(fontStyle: emptyFont),
      ),
      leading: const Icon(Icons.bookmark, color: LightColors.sPurple),
      trailing: optionsRow,
    );
  }

  void deleteChannel(int channelID) {
    globals.savedChannels[channelID] = " ";
  }

  void editChannel(Channel channel, bool edit) {
    final dialogController = TextEditingController();
    String title = "";

    if (edit) {
      dialogController.text = channel.name;
      title = "Edit Channel";
    } else {
      title = "New Channel";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(title),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                onChanged: (value) {},
                controller: dialogController,
                decoration: InputDecoration(
                    hintText: "Enter Channel Here",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: globals.getTextColour(), width: 0.5),
                    ),
                ),
              ),
            ]),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    globals.savedChannels[channel.channelID] =
                        dialogController.text;
                    globals.savePrefs();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('Submit')),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Channel> channels = getDisplayChannels(globals.savedChannels);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: globals.getAppbarColour(),
          iconTheme: const IconThemeData(
            color: LightColors.sPurple,
          ),
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: globals.getSettingsBgColour(),
            height: 100,
            child: NumericStepButton(
              onChanged: (value) {

              },
            ),
          ),
          SettingsList(shrinkWrap: true, sections: [
            SettingsSection(
              title: Text(
                'Saved Channels',
                style: TextStyle(
                    color: globals.getTextColour(),
                    decorationColor: LightColors.sPurple,
                    decorationThickness: 2,
                    decoration: TextDecoration.underline),
              ),
              tiles: [
                channelTile(channels[0]),
                channelTile(channels[1]),
                channelTile(channels[2]),
              ],
            )
          ]),
          Expanded(
              child: Container(
                color: globals.getSettingsBgColour(),
              )
          )
        ]));
  }
}

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final ValueChanged<int> onChanged;

  const NumericStepButton(
      {Key? key,  this.minValue = 0, this.maxValue = 10, required this.onChanged}) : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {

  int counter= 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          child: const Icon(
            Icons.remove,
            color: Colors.white,
            size: 32,
          ),
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: LightColors.sPurple,
            elevation: 2,
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              if (counter > widget.minValue) {
                counter--;
              }
              widget.onChanged(counter);
            });
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: globals.getTextColour(),
            fontSize: 24.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: LightColors.sPurple,
            elevation: 2,
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              if (counter < widget.maxValue) {
                counter++;
              }
              widget.onChanged(counter);
            });
          },
        ),
      ],
    );
  }
}
