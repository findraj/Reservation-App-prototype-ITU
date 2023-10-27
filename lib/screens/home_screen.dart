import 'package:flutter/material.dart';
import 'package:vyperto/components/colors.dart';
import 'package:vyperto/components/fetch_reservations.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the left
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ahoj, Marko!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Zostatok : XXXX",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Čas vyprať ?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 2,
            thickness: 1,
            color: Colors.black,
          ),
          const Expanded(
            child: FetchApiWidget(),
          ),
        ],
      ),
      backgroundColor: primaryColor,
    );
  }
}
