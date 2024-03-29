import 'package:flutter/material.dart';
import 'package:shapeup/models/exercise/custom_exercise_model.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/trainer/trainerplans/customDayList.dart';

class CustomPlanCard extends StatelessWidget {
  final CustomExerciseModel customPlanmodel;
  final VoidCallback onPressed;
  final VoidCallback onTap;

  const CustomPlanCard(
      {Key? key,
      required this.customPlanmodel,
      required this.onPressed,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CustomDayList(exercisemodel: customPlanmodel))),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                  child: Text(
                    customPlanmodel.planName,
                    style: GoogleFonts.montserrat(
                        color: const Color.fromARGB(255, 226, 226, 226),
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: onPressed, icon: const Icon(Icons.edit)),
                    IconButton(onPressed: onTap, icon: const Icon(Icons.delete))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
