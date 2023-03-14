import java.util.Random;
import java.util.ArrayList;

final class CombatHandler {
    private Player player;
    private int combat_rect_width = displayWidth/5;
    private int combat_rect_height = displayHeight/5;
    private int combat_rect_spacing = displayWidth/20;
    private int left_offset = displayWidth/5;
    private int selected_slot;
    private int selected_option;
    private PImage use_label;
    private PImage drop_label;
    // Slow down rate of inputs
    private float input_cooldown;

    CombatHandler(Player player) {
        this.player = player;
        selected_slot = 0;
        selected_option = 0;
        use_label = loadImage("use.png");
        drop_label = loadImage("drop.png");
    }

    void run(ArrayList<Monster> combat_queue, boolean[] input_array) {
        if (millis() - input_cooldown > 50) {
            input_cooldown = millis();
            int column_index = selected_slot % 3;
            if (input_array[0]) {
                if (column_index > 0) {
                    selected_slot--;
                }
            }
            if (input_array[1]) {
                if (column_index < 2) {
                    selected_slot++;
                }
            }
            if (input_array[2]) {
                selected_slot = (selected_slot > 2) ? selected_slot - 3 : selected_slot;
            }
            if (input_array[3]) {
                selected_slot = (selected_slot < 3) ? selected_slot + 3 : selected_slot;
            }
            if (input_array[6]) {
                // Select option
            }
        }
        //combat_queue.remove(0);
        drawComponent();
    }

    void drawComponent() {
        background(150);
        for (int j = 0; j < 2; j++) {
            for (int i = 0; i < 3; i++) {
                int x_pos = combat_rect_spacing * i + combat_rect_width * i + left_offset;
                int y_pos = combat_rect_spacing + j * (combat_rect_spacing + combat_rect_height);
                fill(78,53,36);
                rect(x_pos, y_pos, combat_rect_width, combat_rect_height);
                // if (player.getInventory()[i + 5 * j] != null) {
                //     PImage item_image = player.getInventory()[i + 5 * j].getImage();
                //     if (item_image != null) {
                //         image(item_image, x_pos, y_pos, combat_square_size , combat_square_size);
                //     }
                // }
                if (selected_slot == i + 3 * j) {
                    // Use opacity to show which option is selected
                    image(use_label, x_pos, y_pos - combat_rect_spacing, combat_rect_spacing, combat_rect_spacing);
                    image(drop_label, x_pos + (combat_rect_width - combat_rect_spacing), y_pos - combat_rect_spacing, combat_rect_spacing, combat_rect_spacing);                    
                }
            }
        }
        // Use bottom of the screen to show player health and readme messages
        int y_offset = combat_rect_spacing + (combat_rect_spacing + combat_rect_height) * 2;
        int small_step = displayWidth/100;
        // Display current health
        fill(100, 0, 0);
        rect(combat_rect_spacing, y_offset, displayWidth * 2/3, displayWidth/20);
        fill(255, 0, 0);
        int max_width = displayWidth * 2/3 - small_step * 2;
        rect(combat_rect_spacing + small_step, y_offset + small_step, max_width * player.getHealth() / player.maxHealth(),  displayWidth/20 - small_step * 2);
        fill(0);
        textSize(small_step * 2);
        text("HP: " + Integer.toString(player.getHealth()) + "/" + Integer.toString(player.maxHealth()), combat_rect_spacing + small_step * 2, y_offset + small_step * 3);
        text("Level: " + Integer.toString(player.getLevel()), displayWidth - 2 * combat_rect_width, y_offset + small_step * 3);
    }
}
