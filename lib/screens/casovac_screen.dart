import "package:flutter/material.dart";

class CasovacScreen extends StatefulWidget {
  const CasovacScreen({super.key});
  @override
  _CasovacScreenState createState() => _CasovacScreenState();
}

class _CasovacScreenState extends State<CasovacScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                    "Čas vysušiť ?",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text('00:00:00', style: TextStyle(fontSize: 60)),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('Start')),
                ElevatedButton(onPressed: () {}, child: Text('Stop')),
                ElevatedButton(onPressed: () {}, child: Text('Reset'))
              ],
            ),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _customTimeTile('7 min'),
            SizedBox(height: 20),
            _customTimeTile('48 min'),
            SizedBox(height: 20),
            _customTimeTile('90 min'),
          ],
        ),
      ),
    );
  }

  Widget _customTimeTile(String time) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color.fromARGB(255, 194, 178, 178), width: 1),
      ),
      child: Text(time),
    );
  }
}
