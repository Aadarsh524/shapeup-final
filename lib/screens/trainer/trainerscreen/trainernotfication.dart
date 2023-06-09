import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class TrainerNotify extends StatefulWidget {
  const TrainerNotify({Key? key}) : super(key: key);

  @override
  State<TrainerNotify> createState() => _TrainerNotifyState();
}

class _TrainerNotifyState extends State<TrainerNotify> {
  late Box dataBox;
  @override
  void initState() {
    // TODO: implement initState
    dataBox = Hive.box('storage');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 28, 28, 30),
        elevation: 0,
        title: Text("NOTIFICATION",
            style: GoogleFonts.montserrat(
                letterSpacing: .5,
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
         children: [
          //ListView.builder(itemBuilder: )
         ], 
        ),
        ),
    );
  }
}
