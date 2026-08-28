import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.school, size: 72),
                SizedBox(height: 12),
                Text('Muhammad Aqil Azami', style: TextStyle(fontSize: 24)),
                Text('Pemrograman Mobile - Minggu 1'),
                SizedBox(height: 12),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.badge, size: 18),
                  SizedBox(width: 6),
                  Text('NIM: 244107020128'),
                ]),
                SizedBox(height: 6),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.computer, size: 18),
                  SizedBox(width: 6),
                  Text('Teknik Informatika'),
                ]),
                SizedBox(height: 6),
                Text('muhaaqil6002@gmail.com',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              ]),
            ),
          ),
        ),
        ),
     );
  }
}