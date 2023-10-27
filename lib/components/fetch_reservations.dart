import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'colors.dart';

class FetchApiWidget extends StatelessWidget {
  const FetchApiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchReservations(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(snapshot.data![index]['machine'].toString()),
                      subtitle: Text(snapshot.data![index]['date'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_pin),
                          Text(snapshot.data![index]['location'].toString()),
                        ],
                      ),
                      tileColor: primaryColor,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<List<dynamic>> fetchReservations() async {
    var result =
        await http.get(Uri.parse('http://markoshub.com:3000/api/reservations'));
    if (result.statusCode == 200) {
      return jsonDecode(result.body);
    } else {
      throw Exception('Failed to load reservations');
    }
  }
}
