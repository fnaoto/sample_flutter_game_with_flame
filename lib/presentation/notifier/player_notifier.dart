import 'package:sample_flutter_game_with_flame/application/block_app_service.dart';
import 'package:sample_flutter_game_with_flame/application/player_app_service.dart';
import 'package:sample_flutter_game_with_flame/application/dto/player_dto.dart';

export 'package:sample_flutter_game_with_flame/application/dto/player_dto.dart';

final playerNotifier = StateProvider(
  (ref) => PlayerNotifier(
    playerAppService: ref.watch(playerAppService),
    blockAppService: ref.watch(blockAppService),
  ),
);

final top10PlayersProvider = StateProvider.autoDispose(
  (ref) => ref.watch(playerNotifier).top10Players,
);

final playersProvider = StateProvider.autoDispose(
  (ref) => ref.watch(playerNotifier).players,
);

class PlayerNotifier extends StateNotifier<List<PlayerDto>> {
  final PlayerAppService _playerAppService;
  final BlockAppService _blockAppService;

  PlayerNotifier({
    required PlayerAppService playerAppService,
    required BlockAppService blockAppService,
  })  : _playerAppService = playerAppService,
        _blockAppService = blockAppService,
        super([]);

  List<PlayerDto> get players => List.unmodifiable(state);
  List<PlayerDto> get top10Players => List.unmodifiable(state.take(10));

  Future<void> get fetchPlayer async => await _updatePlayers();

  String? id;
  String? name;

  Future<PlayerDto> createPlayer({
    required String name,
    required int point,
  }) async {
    final _player = await _playerAppService.createPlayer(
      name: name,
      point: point,
    );
    await _updatePlayers();
    return players.firstWhere((p) => p.id == _player.id.value);
  }

  Future<void> deletePlayer({required String id}) async {
    await _playerAppService.deletePlayer(id);
    await _updatePlayers();
  }

  Future<void> updatePlayer({
    required String id,
    required String name,
  }) async {
    final _blocks = await _blockAppService.getPlayerBlocks(id);
    if (_blocks.isEmpty) return;
    final _playerPoints =
        _blocks.map((b) => b!.point).toList().fold<int>(0, (p, c) => p + c);
    await _playerAppService.updatePlayerPoint(id: id, point: _playerPoints);
    await _playerAppService.updatePlayerName(id: id, name: name);
    await _updatePlayers();
  }

  Future<void> _updatePlayers() async {
    await _playerAppService.getPlayerList().then((list) => state = list);
  }
}
