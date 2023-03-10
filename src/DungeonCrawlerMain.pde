
import java.util.Random;

// Use game_state to select which screen we want to display
// 0 = Start screen
// 1 = Dungeon screen
// 2 = Inventory screen
// 3 = Combat screen

final int   tile_size = 10,
            dungeon_dimension_step = 1,
            dungeon_size = 20;

DungeonLevelHandler dungeon_handler;
int game_state = 0;
Random rand;

void setup() {
    fullScreen();
    rand = new Random();
    dungeon_handler = new DungeonLevelHandler(tile_size, dungeon_dimension_step, dungeon_size, rand);
}

// The gameloop function
void draw() {
    switch (game_state) {
        case 0:
            game_state = 1;
            break;
        case 1:
            dungeon_handler.run();
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            // Default to main menu
    }
}
