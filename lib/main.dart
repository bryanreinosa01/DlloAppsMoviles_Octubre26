import 'package:flutter/material.dart';

import 'pages/baggage_list_page.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'database/app_database.dart';
import 'services/baggage_event_remote_service.dart';
import 'repositories/baggage_event_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final repository = BaggageEventRepository(
      local: AppDatabase(),
      remote: BaggageEventRemoteService(FirebaseFirestore.instance));
  runApp(BaggageTrackApp(repository: repository));
}

class BaggageTrackApp extends StatelessWidget {
  final BaggageEventRepository repository;
  const BaggageTrackApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaggageTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BaggageListPage(repository: repository),
    );
  }
}
