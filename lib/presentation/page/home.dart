import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_flutter_game_with_flame/presentation/notifier/player_notifier.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerFutureProvider = ref.watch(playerNotifierFutureProvider);

    return playerFutureProvider.when(
      data: (state) => Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: state.players.isEmpty
            ? null
            : ListView(
                shrinkWrap: true,
                children: state.players
                    .map(
                      (player) => ListTile(
                        leading: const Text("playerList"),
                        title: Text("id: ${player.id}"),
                        subtitle: Text("name: ${player.name}"),
                      ),
                    )
                    .toList(),
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.plus_one),
          onPressed: () async {
            final int32 = pow(2, 32).toInt();
            final random = Random().nextInt(int32);
            await state.createPlayer(
              name: "user-$random",
              point: random,
            );
          },
        ),
      ),
      error: (e, s) => throw Exception(e),
      loading: () => const CircleAvatar(),
    );
  }
}
