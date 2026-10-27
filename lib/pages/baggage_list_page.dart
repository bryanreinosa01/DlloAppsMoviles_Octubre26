import 'package:flutter/material.dart';
import '../data/baggage_seed.dart';
import '../models/baggage.dart';
import '../models/event_history.dart';
import '../models/event_rules.dart';
import '../repositories/baggage_event_repository.dart';
import '../widgets/baggage_card.dart';
import 'baggage_detail_page.dart';

class BaggageListPage extends StatefulWidget {
  final BaggageEventRepository repository;
  const BaggageListPage({super.key, required this.repository});
  @override
  State<BaggageListPage> createState() => _BaggageListPageState();
}

class _BaggageListPageState extends State<BaggageListPage> {
  late List<Future<EventHistory>> _histories;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _histories = baggageSeed
        .map((baggage) => widget.repository.getEventsForBaggage(baggage.id))
        .toList();
  }

  Future<void> _openDetail(Baggage baggage) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BaggageDetailPage(
            baggage: baggage, repository: widget.repository)));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.luggage_outlined),
          SizedBox(width: 10),
          Text('BaggageTrack'),
        ]),
        actions: [
          IconButton(
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(_reload))
        ],
      ),
      body: SafeArea(
          child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: baggageSeed.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final baggage = baggageSeed[index];
          return FutureBuilder<EventHistory>(
              future: _histories[index],
              builder: (context, snapshot) {
                String status = 'Cargando...';
                if (snapshot.hasError) {
                  status = 'No disponible';
                } else if (snapshot.connectionState == ConnectionState.done) {
                  status =
                      latestEvent(snapshot.data!.events, baggage.id)?.type ??
                          'Sin eventos';
                }
                return BaggageCard(
                    baggage: baggage,
                    status: status,
                    usingLocal:
                        snapshot.connectionState == ConnectionState.done &&
                            (snapshot.data?.usingLocal ?? false),
                    onTap: () => _openDetail(baggage));
              });
        },
      )),
    );
  }
}
