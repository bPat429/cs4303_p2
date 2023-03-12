
import java.util.Random;

final int   tile_size = 50,
            dungeon_dimension_step = 1,
            dungeon_size = 20;

DungeonLevelHandler dungeon_handler;
InventoryHandler inventory_handler;
// Use game_state to select which screen we want to display
// 0 = Start screen
// 1 = Dungeon screen
// 2 = Inventory screen
// 3 = Combat screen
int game_state = 0;
// Used for backtracking after showing the inventory
int prev_game_state = 0;
Random rand;
float prev_frame_millis;
float frame_duration;
// Add a cooldown to the inventory toggle to avoid spamming
float inventory_cooldown;
Player player;

// Array of Booleans used to track user inputs
// corresponding to:
// a pressed, d pressed, w pressed, s pressed, q pressed, e pressed, f pressed
boolean[] input_array = new boolean[]{false, false, false, false, false, false, false};
// Show inventory toggle
boolean show_inventory = false;

void setup() {
    fullScreen();
    rand = new Random();
    player = new Player(tile_size);
    dungeon_handler = new DungeonLevelHandler(tile_size, dungeon_dimension_step, dungeon_size, rand, player);
    inventory_handler = new InventoryHandler(player);
}

void enterDungeonScreen() {
    prev_frame_millis = millis();
    game_state = 1;
}

// The gameloop function
void draw() {
    background(0);
    switch (game_state) {
        case 0:
            enterDungeonScreen();
            break;
        case 1:
            frame_duration = (millis() - prev_frame_millis)/1000;
            dungeon_handler.run(input_array, frame_duration);
            break;
        case 2:
            inventory_handler.run(input_array);
            break;
        case 3:
            break;
        default:
            // Default to main menu
    }
    prev_frame_millis = millis();
}

void keyPressed() {
    if (key == 'a') {
        input_array[0] = true;
    }
    if (key == 'd') {
        input_array[1] = true;
    }
    if (key == 'w') {
        input_array[2] = true;
    }
    if (key == 's') {
        input_array[3] = true;
    }
    if (key == 'q') {
        input_array[4] = true;
    }
    if (key == 'e') {
        input_array[5] = true;
    }
    if (key == 'f') {
        input_array[6] = true;
    }
    if (key == 'i') {
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
    if (key == 'a') {
        input_array[0] = false;
    }
    if (key == 'd') {
        input_array[1] = false;
    }
    if (key == 'w') {
        input_array[2] = false;
    }
    if (key == 's') {
        input_array[3] = false;
    }
    if (key == 'q') {
        input_array[4] = false;
    }
    if (key == 'e') {
        input_array[5] = false;
    }
    if (key == 'f') {
        input_array[6] = false;
    }
}
