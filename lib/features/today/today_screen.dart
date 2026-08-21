import 'package:flutter/material.dart';

import '../../shared/widgets/neu_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Bugün',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Bugünkü antrenmanın',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KUVVET A',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Full Body • ~35 dakika'),
              const SizedBox(height: 24),
              const Text('Antrenman verisi birazdan buraya bağlanacak.'),
            ],
          ),
        ),
      ],
    );
  }
}