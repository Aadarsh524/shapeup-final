import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shapeup/screens/trainer/trainerplans/exercises.dart';
import 'package:shapeup/screens/trainer/trainerscreen/trainerscreen.dart';

import 'package:shapeup/screens/trainer/trainerscreen/workoutplan.dart';

import '../../../models/diet/day_model.dart';

class DayListCustom extends StatefulWidget {
  final String planUid;

  const DayListCustom({Key? key, required this.planUid}) : super(key: key);

  @override
  State<DayListCustom> createState() => _DayListCustomState();
}

class _DayListCustomState extends State<DayListCustom> {
  List<String> days = ['1', '2', '3', '4', '5', '6', '7'];
  void handleDayTap(String day) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddExercise(
                  dayIndex: day,
                  planUid: widget.planUid,
                )));
    print(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 28, 28, 30),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TrainerPage()));
          },
        ),
        title: Text('Days',
            style: GoogleFonts.montserrat(
                letterSpacing: .5,
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromARGB(255, 28, 28, 30),
      ),
      body: SafeArea(
          child: DayCard(
        days: days,
        onTap: handleDayTap,
      )),
    );
  }
}
