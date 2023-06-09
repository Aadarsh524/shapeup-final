import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shapeup/screens/user/premium/trainersPlanList.dart';

import '../../../models/profile/trainer_profile_model.dart';

import '../../../services/profile/trainer_profile_service.dart';
import '../dashboard/dashboardscreen.dart';

class TrainerProfile extends StatefulWidget {
  final String docId;

  TrainerProfile({
    Key? key,
    required this.docId,
  }) : super(key: key);

  @override
  State<TrainerProfile> createState() => _TrainerProfileState();
}

class _TrainerProfileState extends State<TrainerProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  final dio = Dio();
  late final Box dataBox;
  late bool hasTrainer;
  late String myTrainer;
  @override
  void initState() {
    super.initState();
    dataBox = Hive.box('storage');
    hasTrainer = dataBox.get('hasTrainer');
    myTrainer = dataBox.get('myTrainer');
  }

  String chatRoom(String trainee, String trainer) {
    if (trainee.toLowerCase().compareTo(trainer.toLowerCase()) > 0) {
      return "$trainee$trainer";
    } else {
      return "$trainer$trainee";
    }
  }

  void sendPushNotification(String trainerDeviceToken) async {
    const String serverKey =
        'AAAATDAzS6c:APA91bFZhr4WPrr1tqt9iZ-s4MS0gODumBAJwl5TAL6czX0BtYrN_qj7-gaedAlILR87vaflnG1Ok7IhfPSHP1aTmbA-woxuMg_tUEaouLtiugUV6ZLEqFD_RipGY52DF2r87elf4eJM';

    Map<String, dynamic> notification = {
      'notification': {
        'title': 'New Client',
        'body': 'You have a new Trainee.',
      },
      'to': trainerDeviceToken,
      'data': {'type': 'message', 'id': '123'}
    };

    try {
      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'key=$serverKey';

      final response = await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: notification,
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully.');
      } else {
        print(
            'Failed to send push notification. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<void> _showAlertDialog(
      String name, String tID, String trainerDeviceToken) async {
    String chatRoomID = chatRoom(
      user!.uid,
      tID,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Appoint $name As Trainer",
            style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Are you sure ?",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Yes",
                style: GoogleFonts.notoSansMono(
                    color: Color.fromARGB(255, 190, 227, 57),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(tID)
                    .update({
                      'clients': FieldValue.arrayUnion([user!.uid])
                    })
                    .then((value) => {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .update({
                            'myTrainer': tID,
                            'hasTrainer': true
                          }).then((value) => {
                                    dataBox.put('hasTrainer', true),
                                    dataBox.put('myTrainer', tID)
                                  }),
                        })
                    .then((value) => {
                          FirebaseFirestore.instance
                              .collection('chatrooms')
                              .doc(chatRoomID)
                              .set({
                                'trainer': tID,
                                'trainee': user!.uid,
                                "timestamp": Timestamp.now(),
                              })
                              .then((value) => {
                                    sendPushNotification(trainerDeviceToken),
                                  })
                              .then((value) => Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: const DashBoardScreen(
                                        selectedIndex: 0,
                                      ))))
                        });
              },
            ),
            TextButton(
              child: Text(
                "No",
                style: GoogleFonts.notoSansMono(
                    color: Color.fromARGB(255, 190, 227, 57),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 28, 28, 30),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 28, 28, 30),
          elevation: 0,
          toolbarHeight: 60,
          title: Text("Trainer Profile",
              style: GoogleFonts.montserrat(
                  letterSpacing: .5,
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600)),
          leading: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10),
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 114, 97, 89),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: IconButton(
                    color: Colors.black,
                    iconSize: 12,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        // ignore: sized_box_for_whitespace
        body: SafeArea(
          child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 10),
                    child: FutureBuilder<TrainerProfileModel>(
                      future:
                          TrainerProfileService().trainerProfile(widget.docId),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text("Something went wrong"));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          final trainerProfile = snapshot.data!;
                          print(trainerProfile.id);
                          print(myTrainer);
                          print(trainerProfile.id == myTrainer);

                          final trainerClients = trainerProfile.clients;

                          List<String> clients =
                              List<String>.from(trainerClients);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: const Color.fromARGB(
                                              255, 190, 227, 57),
                                        ),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.network(
                                            trainerProfile.userImage,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_circle_sharp,
                                          size: 20,
                                          color: Color.fromARGB(
                                              255, 166, 181, 106),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${trainerProfile.firstName}${trainerProfile.lastName}",
                                          style: GoogleFonts.montserrat(
                                            letterSpacing: .5,
                                            color: const Color.fromARGB(
                                                255, 166, 181, 106),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 20,
                                          color: Color.fromRGBO(
                                              142, 153, 183, 0.5),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          trainerProfile.email,
                                          style: GoogleFonts.montserrat(
                                            letterSpacing: 0,
                                            color: const Color.fromRGBO(
                                                142, 153, 183, 0.5),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 20,
                                          color: Color.fromRGBO(
                                              142, 153, 183, 0.5),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          trainerProfile.phone,
                                          style: GoogleFonts.montserrat(
                                            letterSpacing: 0,
                                            color: const Color.fromRGBO(
                                                142, 153, 183, 0.5),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        trainerProfile.gender == "male"
                                            ? const Icon(
                                                MdiIcons.genderMale,
                                                size: 20,
                                                color: Color.fromRGBO(
                                                    142, 153, 183, 0.5),
                                              )
                                            : const Icon(
                                                MdiIcons.genderFemale,
                                                size: 20,
                                                color: Color.fromRGBO(
                                                    142, 153, 183, 0.5),
                                              ),
                                        const SizedBox(width: 10),
                                        Text(
                                          trainerProfile.gender,
                                          style: GoogleFonts.montserrat(
                                            letterSpacing: 0,
                                            color: const Color.fromRGBO(
                                                142, 153, 183, 0.5),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Center(
                                      child: Text(
                                        trainerProfile.descrp,
                                        style: GoogleFonts.montserrat(
                                          letterSpacing: 0,
                                          color: const Color.fromARGB(
                                              255, 114, 97, 89),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Card(
                                      elevation: 1,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      color: const Color.fromARGB(
                                          255, 114, 97, 89),
                                      child: SizedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Age:",
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                trainerProfile.age,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  letterSpacing: .5,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      elevation: 1,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      color: const Color.fromARGB(
                                          255, 114, 97, 89),
                                      child: SizedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Experience:",
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                trainerProfile.expage,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  letterSpacing: .5,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      elevation: 1,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      color: const Color.fromARGB(
                                          255, 114, 97, 89),
                                      child: SizedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Clients:",
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "${clients.length}",
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.montserrat(
                                                  letterSpacing: .5,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Center(
                                      child: SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    duration: const Duration(
                                                        milliseconds: 250),
                                                    child: TrainersPlansList(
                                                      trainerId:
                                                          trainerProfile.id,
                                                    )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 190, 227, 57),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            textStyle: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 1,
                                              bottom: 1,
                                            ),
                                            child: Text(
                                              "View Plan",
                                              style: GoogleFonts.notoSansMono(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    myTrainer != trainerProfile.id
                                        ? Center(
                                            child: SizedBox(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  String name =
                                                      trainerProfile.firstName;
                                                  String tID =
                                                      trainerProfile.id;
                                                  String trainerDeviceToken =
                                                      trainerProfile
                                                          .deviceToken;
                                                  print(trainerDeviceToken);

                                                  _showAlertDialog(name, tID,
                                                      trainerDeviceToken);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 190, 227, 57),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 14),
                                                  textStyle: const TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 1,
                                                    bottom: 1,
                                                  ),
                                                  child: Text(
                                                    "Appoint",
                                                    style: GoogleFonts
                                                        .notoSansMono(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                              myTrainer != trainerProfile.id
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Note:",
                                            style: GoogleFonts.montserrat(
                                              height: 1.4,
                                              letterSpacing: .4,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: const Color.fromARGB(
                                                  255, 125, 128, 122),
                                            ),
                                          ),
                                          Text(
                                            "You can choose only one trainer and cannot be changed untill your premium subscription is expired, so please choose wisely.",
                                            style: GoogleFonts.montserrat(
                                              letterSpacing: .4,
                                              fontSize: 10,
                                              color: const Color.fromARGB(
                                                  255, 114, 97, 89),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          );
                        } else {
                          // If no data is available, show a message
                          return const Center(child: Text("Loading"));
                        }
                      },
                    )),
              )),
        ));
  }
}
