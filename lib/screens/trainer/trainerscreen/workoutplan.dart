import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shapeup/models/exercise/custom_exercise_model.dart';
import 'package:shapeup/screens/trainer/trainerplans/planName.dart';
import 'package:shapeup/screens/trainer/trainerplans/dayListCustom.dart';
import 'package:shapeup/screens/trainer/trainerscreen/trainerscreen.dart';

import '../../../components/customPlanCard.dart';
import '../../../services/exercise/exercise_service.dart';

class WorkoutPlan extends StatefulWidget {
  const WorkoutPlan();

  @override
  State<WorkoutPlan> createState() => _WorkoutPlanState();
}

class _WorkoutPlanState extends State<WorkoutPlan> {
  //late final Box dataBox;
  bool isTrainerVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // dataBox = Hive.box('storage');
    // isTrainerVerified = dataBox.get('verifiedStatus');

    checkTrainerVerification();
  }

  void checkTrainerVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot trainerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (trainerSnapshot.exists) {
        bool verified = trainerSnapshot.get('isVerified');
        setState(() {
          isTrainerVerified = verified;
          print(isTrainerVerified);
        });
      } else {
        print('Trainer is not verified');
      }
    } else {
      print('User not logged');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 28, 28, 30),
          title: Text("Your Plans",
              style: GoogleFonts.montserrat(
                  letterSpacing: .5,
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TrainerPage()));
            },
          ),
        ),
        body: SafeArea(
          child: SizedBox(
              child: isTrainerVerified
                  ? Column(
                      children: [
                        FutureBuilder<List<CustomExerciseModel>>(
                            future: ExerciseService().customPlanList,
                            builder: ((context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return CustomPlanCard(
                                        customPlanmodel: snapshot.data![index],
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DayListCustom(
                                                        planUid: snapshot
                                                            .data![index].id,
                                                      )));
                                        },
                                      );
                                    });
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.white,
                                ));
                              }
                            })),
                        Card(
                          color: Theme.of(context).colorScheme.secondary,
                          child: ElevatedButton.icon(
                            label: Text(
                              'Create plan',
                              style: GoogleFonts.notoSansMono(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              // padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const PlanName()));
                            },
                          ),
                        )
                      ],
                    )
                  : Container(
                      child: FutureBuilder<bool?>(
                        future: Future.delayed(
                            Duration(seconds: 15)), // Delay for 2 seconds
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Delay in progress, show a loading indicator or any other widget
                            return CircularProgressIndicator();
                          } else {
                            // Delay completed, show the text
                            return Text(
                              'You need to be verified to create a new plan',
                              style: TextStyle(fontSize: 12),
                            );
                          }
                        },
                      ),
                    )),
        ));
  }
}
