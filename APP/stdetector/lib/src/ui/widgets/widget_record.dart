import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/record.dart';

class WidgetRecord extends StatefulWidget {
  final Record record;
  final Function onSelected;
  final Function onUnselected;
  final Function onTouch;
  final bool editing;

  WidgetRecord(
      {required this.record,
      required this.onSelected,
      required this.onUnselected,
      required this.onTouch,
      required this.editing});

  @override
  State<StatefulWidget> createState() {
    return WidgetRecordState();
  }
}

class WidgetRecordState extends State<WidgetRecord> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    try {
      if (!widget.editing) {
        selected = false;
      }
    } catch (e) {
      print(e);
    }

    return GestureDetector(
      onLongPress: () {
        if (widget.editing) {
          setState(() {
            selected = false;
          });
        } else {
          widget.onSelected(widget.record);
          HapticFeedback.selectionClick(); ///vibrate
          setState(() {
            selected = true;
          });
        }
        print(">>>>>>>>>>>>>>>>> long press");
        print(selected);
      },
      onTap: () {
        if (widget.editing) {
          if (!selected) {
            setState(() {
              selected = true;
              widget.onSelected(widget.record);
            });
          } else {
            setState(() {
              selected = false;
              widget.onUnselected(widget.record);
            });
          }
        } else {
          setState(() {
            //widget.record.isCompleted = !widget.record.isCompleted;
            widget.onTouch(widget.record);
            //widget.optionController.update(widget.task);
          });

          //print(">>>>>>>>>>>>>>>>>>>>> Completed tast ${widget.task.label}");
        }
      },
      child: Card(
        color: selected ? Colors.deepOrange : Colors.white70,
        child: ListTile(
          leading: Icon( Icons.back_hand,
            color: Colors.grey,
          ),
          title: Text(
            widget.record.filename,
          ),

          ///trailing: Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
