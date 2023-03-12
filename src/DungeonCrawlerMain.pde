
import java.util.Random;

final int   tile_size = 50,
            dungeon_dimension_step = 1,
            dungeon_size = 20;

DungeonLevelHandler dungeon_handler;
// Use game_state to select which screen we want to display
// 0 = Start screen
// 1 = Dungeon screen
// 2 = Inventory screen
// 3 = Combat screen
int game_state = 0;
Random rand;
float prev_frame_millis;
float frame_duration;

// Array of Booleans used to track user inputs
// corresponding to:
// a pressed, d pressed, w pressed, s pressed, q pressed, e pressed, f pressed
boolean[] input_array = new boolean[]{false, false, false, false, false, false, false};

void setup() {
    fullScreen();
    rand = new Random();
    dungeon_handler = new DungeonLevelHandler(tile_size, dungeon_dimension_step, dungeon_size, rand);
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
