import 'dart:io';
import 'dart:math';

const int gridSize = 10;
const Map<String, int> ships = {
  "fourDeck": 1,
  "threeDeck": 2,
  "twoDeck": 3,
  "oneDeck": 4,
};

class Game {
  List<List<String>> playerGrid;
  List<List<String>> botGrid;
  List<List<String>> botGuessGrid;
  int playerHits = 0;
  int botHits = 0;
  int playerMisses = 0;
  int botMisses = 0;

  Game()
      : playerGrid = List.generate(gridSize, (_) => List.filled(gridSize, '.')),
        botGrid = List.generate(gridSize, (_) => List.filled(gridSize, '.')),
        botGuessGrid = List.generate(gridSize, (_) => List.filled(gridSize, '.'));

  void start() {
    print("Добро пожаловать в игру Морской бой!");
    _setupPlayerGrid();
    _setupBotGrid();
    _playGame();
    _showResults();
    _saveResults();
  }

  void _playGame() {
    bool playerTurn = true;
    while (true) {
      if (playerTurn) {
        playerTurn = _playerTurn();
        if (_isGameOver(botGrid)) {
          print("Вы победили!");
          break;
        }
      } else {
        playerTurn = !_botTurn();
        if (_isGameOver(playerGrid)) {
          print("Бот победил.");
          break;
        }
      }
    }
  }

   bool _playerTurn() {
    print("Ваш ход!");
    _printGrid(botGuessGrid);
    int x = _getCoordinate("Введите координату X для выстрела: ");
    int y = _getCoordinate("Введите координату Y для выстрела: ");
    if (botGrid[x][y] == 'S') {
      print("Попадание!");
      botGrid[x][y] = 'X';
      botGuessGrid[x][y] = 'X';
      if (_isShipSunk(botGrid, x, y)) {
        print("Вы уничтожили корабль!");
        _markSunkShip(botGrid, botGuessGrid, x, y);
      }
      playerHits++;
      return true;
    } else {
      print("Мимо!");
      botGuessGrid[x][y] = 'O';
      playerMisses++;
      return false;
    }
  }

0
0

    bool _botTurn() {
    print("Ход бота...");
    int x, y;
    do {
      x = Random().nextInt(gridSize);
      y = Random().nextInt(gridSize);
    } while (botGuessGrid[x][y] != '.');

    if (playerGrid[x][y] == 'S') {
      print("Бот попал в вашу цель!");
      playerGrid[x][y] = 'X';
      if (_isShipSunk(playerGrid, x, y)) {
        print("Бот уничтожил ваш корабль!");
        _markSunkShip(playerGrid, playerGrid, x, y);
      }
      botHits++;
      return true;
    } else {
      print("Бот промахнулся.");
      botMisses++;
      return false;
    }
  }



  void _setupPlayerGrid() {
    print("Расставьте свои корабли:");
    for (var entry in ships.entries) {
      String shipType = entry.key;
      int count = entry.value;
      int size = _shipSize(shipType);
      for (int i = 0; i < count; i++) {
        _placeShip(playerGrid, size, "Корабль $shipType (${i + 1}/$count):");
      }
    }
  }

  void _setupBotGrid() {
    for (var entry in ships.entries) {
      String shipType = entry.key;
      int count = entry.value;
      int size = _shipSize(shipType);
      for (int i = 0; i < count; i++) {
        _placeShip(botGrid, size);
      }
    }
  }

  int _shipSize(String shipType) {
    switch (shipType) {
      case "fourDeck":
        return 4;
      case "threeDeck":
        return 3;
      case "twoDeck":
        return 2;
      case "oneDeck":
        return 1;
      default:
        return 1;
    }
  }

  void _placeShip(List<List<String>> grid, int size, [String? prompt]) {
    bool validPlacement = false;
    while (!validPlacement) {
      try {
        if (prompt != null) {
          print(prompt);
          _printGrid(grid);
          int x = _getCoordinate("Введите начальную координату X (0-9): ");
          int y = _getCoordinate("Введите начальную координату Y (0-9): ");
          String direction = _getDirection("Введите направление (h - горизонтально, v - вертикально): ");
          validPlacement = _tryPlaceShip(grid, x, y, size, direction);
          if (!validPlacement) print("Невозможно разместить корабль в указанной позиции. Попробуйте снова.");
        } else {
          int x = Random().nextInt(gridSize);
          int y = Random().nextInt(gridSize);
          String direction = Random().nextBool() ? 'h' : 'v';
          validPlacement = _tryPlaceShip(grid, x, y, size, direction);
        }
      } catch (e) {
        print("Ошибка ввода. Попробуйте снова.");
      }
    }
  }

  int _getCoordinate(String prompt) {
    while (true) {
      stdout.write(prompt);
      try {
        int coord = int.parse(stdin.readLineSync()!);
        if (coord >= 0 && coord < gridSize) return coord;
        print("Введите число от 0 до 9.");
      } catch (_) {
        print("Некорректный ввод. Введите число от 0 до 9.");
      }
    }
  }

  String _getDirection(String prompt) {
    while (true) {
      stdout.write(prompt);
      String? input = stdin.readLineSync();
      if (input != null && (input == 'h' || input == 'v')) {
        return input;
      } else {
        print("Введите 'h' для горизонтального направления или 'v' для вертикального.");
      }
    }
  }

  bool _tryPlaceShip(List<List<String>> grid, int x, int y, int size, String direction) {
    if (direction == 'h') {
      if (y + size > gridSize) return false;
      for (int i = 0; i < size; i++) {
        if (!_canPlace(grid, x, y + i)) return false;
      }
      for (int i = 0; i < size; i++) {
        grid[x][y + i] = 'S';
      }
    } else if (direction == 'v') {
      if (x + size > gridSize) return false;
      for (int i = 0; i < size; i++) {
        if (!_canPlace(grid, x + i, y)) return false;
      }
      for (int i = 0; i < size; i++) {
        grid[x + i][y] = 'S';
      }
    } else {
      return false;
    }
    return true;
  }

  bool _canPlace(List<List<String>> grid, int x, int y) {
    if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) return false;
    if (grid[x][y] != '.') return false;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < gridSize && ny < gridSize) {
          if (grid[nx][ny] == 'S') return false;
        }
      }
    }
    return true;
  }

  bool _isShipSunk(List<List<String>> grid, int x, int y) {
    List<List<int>> directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    for (var dir in directions) {
      int nx = x + dir[0];
      int ny = y + dir[1];
      if (nx >= 0 && ny >= 0 && nx < gridSize && ny < gridSize && grid[nx][ny] == 'S') {
        return false;
      }
    }
    return true;
  }

  void _markSunkShip(List<List<String>> grid, List<List<String>> guessGrid, int x, int y) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < gridSize && ny < gridSize) {
          if (grid[nx][ny] == '.') {
            guessGrid[nx][ny] = 'O';
          }
        }
      }
    }
  }

  void _showResults() {
    print("Результаты игры:");
    print("Ваши попадания: $playerHits, промахи: $playerMisses");
    print("Попадания бота: $botHits, промахи: $botMisses");
  }

  void _saveResults() {
    Directory dir = Directory('game_results');
    if (!dir.existsSync()) {
      dir.createSync();
    }

    File file = File('${dir.path}/results.txt');
    file.writeAsStringSync('Результаты игры:\n');
    file.writeAsStringSync('Ваши попадания: $playerHits, промахи: $playerMisses\n', mode: FileMode.append);
    file.writeAsStringSync('Попадания бота: $botHits, промахи: $botMisses\n', mode: FileMode.append);

    print('Результаты игры сохранены в файл ${file.path}');
  }

  void _printGrid(List<List<String>> grid) {
    print("   ${List.generate(gridSize, (i) => i).join(' ')}");
    for (int i = 0; i < gridSize; i++) {
      String row = grid[i].join(' ');
      print("${i.toString().padLeft(2)} $row");
    }
  }

  bool _isGameOver(List<List<String>> grid) {
    for (var row in grid) {
      if (row.contains('S')) return false;
    }
    return true;
  }
}

void main() {
  Game game = Game();
  game.start();
}
