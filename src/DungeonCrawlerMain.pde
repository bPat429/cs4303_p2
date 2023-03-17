import java.util.Random;
import java.util.ArrayList;

final int   tile_size = 50,
            dungeon_dimension_step = 1,
            dungeon_size = 20;

DungeonLevelHandler dungeon_handler;
InventoryHandler inventory_handler;
CombatHandler combat_handler;
GameOverHandler game_over_handler;
// Use game_state to select which screen we want to display
// 0 = Start screen
// 1 = Dungeon screen
// 2 = Inventory screen
// 3 = Combat screen
// 4 = Game over screen
int game_state = 0;
// Used for backtracking after showing the inventory
int prev_game_state = 0;
Random rand;
float prev_frame_millis;
float frame_duration;
// Add a cooldown to the inventory toggle to avoid spamming
float inventory_cooldown;
Player player;
// Create an array list to use as a queue for all monsters encountered within one frame of running DungeonLevelHandler
// If the list is populated then resolve them one by one in the CombatHandler until the list is empty and combat is finished.
private ArrayList<Monster> combat_queue;

// Array of Booleans used to track user inputs
// corresponding to:
// a pressed, d pressed, w pressed, s pressed, q pressed, e pressed, f pressed
boolean[] input_array = new boolean[]{false, false, false, false, false, false, false, false};
// Show inventory toggle
boolean show_inventory = false;

void setup() {
    fullScreen();
    rand = new Random();
    player = new Player();
    dungeon_handler = new DungeonLevelHandler(tile_size, dungeon_dimension_step, dungeon_size, rand, player);
    inventory_handler = new InventoryHandler(player);
    combat_handler = new CombatHandler(player);
    game_over_handler = new GameOverHandler(player);
    combat_queue = new ArrayList<Monster>();
    game_state = 0;
}

void enterDungeonScreen() {
    prev_frame_millis = millis();
    game_state = 1;
}

// The gameloop function
void draw() {
    // If the player is initialised then check if they have died
    if (player != null && player.getHealth() <= 0) {
        // Game over
        game_state = 4;
    }
    switch (game_state) {
        case 0:
            enterDungeonScreen();
            break;
        case 1:
            if (combat_queue.size() > 0) {
                game_state = 3;
            } else {
                frame_duration = (millis() - prev_frame_millis)/1000;
                dungeon_handler.run(combat_queue, input_array, frame_duration);
                break;
            }
        case 2:
            inventory_handler.run(input_array);
            break;
        case 3:
            if (combat_queue.size() > 0) {
                combat_handler.run(combat_queue, input_array, rand);
            } else {
                game_state = 1;
            }
            break;
        case 4:
            if (game_over_handler.run(input_array)) {
                enterDungeonScreen();
                setup();
            }
            break;
        default:
            // Default to main menu
    }
    prev_frame_millis = millis();
}

void keyPressed() {
    if (key == 'a' || key == 'A') {
        input_array[0] = true;
    }
    if (key == 'd' || key == 'D') {
        input_array[1] = true;
    }
    if (key == 'w' || key == 'W') {
        input_array[2] = true;
    }
    if (key == 's' || key == 'S') {
        input_array[3] = true;
    }
    if (key == 'q' || key == 'Q') {
        input_array[4] = true;
    }
    if (key == 'e' || key == 'E') {
        input_array[5] = true;
    }
    if (key == 'f' || key == 'F') {
        input_array[6] = true;
    }
    if (key == 'r' || key == 'R') {
        input_array[7] = true;
    }
    if (key == 'i' || key == 'I') {
        // i is reserved for the inventory screen, toggles on and off
        // Only allow using the inventory after the dungeon is initialised, and add a 500 ms cooldown
        if (game_state > 0 && (millis() - inventory_cooldown) > 500) {
            show_inventory = (!show_inventory);
            if (show_inventory) {
                prev_game_state = game_state;
                game_state = 2;
            } else {
                game_state = prev_game_state;
            }
            inventory_cooldown = millis();
        }
    }
}

void keyReleased() {
    if (key == 'a' || key == 'A') {
        input_array[0] = false;
    }
    if (key == 'd' || key == 'D') {
        input_array[1] = false;
    }
    if (key == 'w' || key == 'W') {
        input_array[2] = false;
    }
    if (key == 's' || key == 'S') {
        input_array[3] = false;
    }
    if (key == 'q' || key == 'Q') {
        input_array[4] = false;
    }
    if (key == 'e' || key == 'E') {
        input_array[5] = false;
    }
    if (key == 'f' || key == 'F') {
        input_array[6] = false;
    }
    if (key == 'r' || key == 'R') {
        input_array[7] = false;
    }
}
