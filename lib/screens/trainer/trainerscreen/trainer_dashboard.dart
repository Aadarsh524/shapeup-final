import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shapeup/screens/trainer/trainerscreen/traineesprofile.dart';
import 'package:shapeup/screens/trainer/trainerscreen/trainerprofile.dart';
import 'package:shapeup/services/exercise/exercise_service.dart';
import 'package:shapeup/services/profile/trainee_profile_service.dart';

import '../../../components/trainerPlanCard.dart';
import '../../../models/exercise/custom_exercise_model.dart';
import '../../../models/profile/trainee_profile_model.dart';
import '../../../models/profile/trainer_profile_model.dart';
import '../../../services/notification/notification_services.dart';
import '../../../services/profile/trainer_profile_service.dart';

class HomePageT extends StatefulWidget {
  const HomePageT({Key? key}) : super(key: key);

  @override
  State<HomePageT> createState() => _HomePageTState();
}

class _HomePageTState extends State<HomePageT> {
  late final Box dataBox;
  User? trainerId = FirebaseAuth.instance.currentUser;
  String? week;
  String? day;
  String? month;
  DateTime date = DateTime.now();
  late String firstName;

  @override
  void initState() {
    super.initState();
    setState(() {
      week = DateFormat('EEEE').format(date);
      day = DateFormat('d').format(date);
      month = DateFormat('MMMM').format(date);
    });
    dataBox = Hive.box('storage');
    firstName = dataBox.get("firstName");
    NotificationServices().requestNotificationPermission();
    NotificationServices().firebaseNotificationInit(context);
    NotificationServices().setUpInteractMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 28, 28, 30),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header section
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        color: const Color.fromARGB(255, 190, 227, 57),
                        iconSize: 24,
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.person_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrainerProfile(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hey, $firstName", //firebase trainer name
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Color.fromARGB(255, 190, 227, 57),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "$week, $day $month",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trainees List
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 20, 30, 10),
                child: Text(
                  'Trainees List',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Color.fromARGB(255, 190, 227, 57),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(6.0),
                child: FutureBuilder<TrainerProfileModel?>(
                  future:
                      TrainerProfileService().trainerProfile(trainerId!.uid),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data != null) {
                      final trainerProfile = snapshot.data!;
                      final trainerClients = trainerProfile.clients;
                      List<String> clients = List<String>.from(trainerClients);

<<<<<<< HEAD
                          List<String> clients =
                              List<String>.from(trainerClients);
                          print(clients);
                          return Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: clients.length,
                              itemBuilder: (BuildContext context, int index) {
                                final traineeId = clients[index];
                                print(traineeId);

                                return FutureBuilder<TraineeProfileModel?>(
                                  future: TraineeProfileService()
                                      .traineeProfile(traineeId),
                                  builder: (BuildContext context, snapshot) {
                                    print(snapshot);
                                    if (snapshot.hasData) {
                                      final traineeData = snapshot.data!;
                                      final traineeName = traineeData.firstName;
                                      final userImage = traineeData.userImage;
                                      final lastName = traineeData.lastName;
                                      print(traineeName);
                                      print(userImage);
                                      print(lastName);

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.fade,
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  child: TraineeProfile(
                                                    docId: traineeData.id,
                                                  )));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 85,
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Card(
                                            elevation: 5,
                                            color: const Color.fromARGB(
                                                255, 114, 97, 89),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
=======
                      return ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: clients.length,
                        itemBuilder: (BuildContext context, int index) {
                          final traineeId = clients[index];
                          return FutureBuilder<TraineeProfileModel?>(
                            future: TraineeProfileService()
                                .traineeProfile(traineeId),
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.hasData) {
                                final traineeData = snapshot.data!;
                                final traineeName = traineeData.firstName;
                                final userImage = traineeData.userImage;
                                final lastName = traineeData.lastName;

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: TraineeProfile(
                                            docId: traineeData.id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        28, 10, 30, 1),
                                    width: double.infinity,
                                    height: 85,
                                    child: Card(
                                      elevation: 5,
                                      color: const Color.fromARGB(
                                          255, 114, 97, 89),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Image.network(
                                                  userImage,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 25),
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
>>>>>>> ca959460b2b71a9d5cdcb6f7c79025c9733477cf
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "$traineeName $lastName",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      letterSpacing: .5,
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text('No clients');
                              } else {
                                return ListTile(
                                  title: Text('Loading...'),
                                );
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading trainer'));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              // Trainer Plans List
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 10, 30, 10),
                child: Text(
                  'Your Plans',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Color.fromARGB(255, 190, 227, 57),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Trainer Plans List
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: FutureBuilder<List<CustomExerciseModel>>(
                  future: ExerciseService().trainerPlanList(trainerId!.uid),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return TrainerPlanCard(
                            customPlanmodel: snapshot.data![index],
                          );
                        },
                      );
                    } else {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
