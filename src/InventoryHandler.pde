import java.util.Random;
import java.util.ArrayList;

final class InventoryHandler {
    private Player player;
    private int inventory_square_size = displayWidth/10;
    private int inventory_square_spacing = displayWidth/20;
    private int left_offset = displayWidth/6;
    private int selected_slot;
    private int selected_option;
    private PImage use_label;
    private PImage drop_label;
    private PImage equipped_label;
    // Slow down rate of inputs
    private float input_cooldown;

    InventoryHandler(Player player) {
        this.player = player;
        selected_slot = 0;
        selected_option = 0;
        use_label = loadImage("use.png");
        drop_label = loadImage("drop.png");
        equipped_label = loadImage("equipped.png");
    }

    void run(boolean[] input_array) {
        if (millis() - input_cooldown > 100) {
            input_cooldown = millis();
            int column_index = selected_slot % 5;
            if (input_array[0]) {
                if (column_index > 0) {
                    selected_slot--;
                }
            }
            if (input_array[1]) {
                if (column_index < 4) {
                    selected_slot++;
                }
            }
            if (input_array[2]) {
                selected_slot = (selected_slot - 5 > -1) ? selected_slot - 5 : selected_slot;
            }
            if (input_array[3]) {
                selected_slot = (selected_slot + 5 < player.MAX_INVENTORY) ? selected_slot + 5 : selected_slot;
            }
            if (input_array[4]) {
                player.dropItem(selected_slot);
            }
            if (input_array[5]) {
                player.useItem(selected_slot);
            }
        }
        drawComponent();
    }

    void drawComponent() {
        background(58,33,16);
        int small_step = displayWidth/100;
        for (int j = 0; j < player.MAX_INVENTORY / 5; j++) {
            for (int i = 0; i < 5; i++) {
                int x_pos = inventory_square_spacing * i + inventory_square_size * i + left_offset;
                int y_pos = inventory_square_spacing + j * (inventory_square_spacing + inventory_square_size);
                fill(78,53,36);
                rect(x_pos, y_pos, inventory_square_size, inventory_square_size);
                if (player.getInventory()[i + 5 * j] != null) {
                    PImage item_image = player.getInventory()[i + 5 * j].getImage();
                    if (item_image != null) {
                        image(item_image, x_pos, y_pos, inventory_square_size , inventory_square_size);
                        if (player.isWearing(i + 5 * j)) {
                            tint(255, 175);
                            image(equipped_label, x_pos + small_step, y_pos + small_step/2, small_step * 8, small_step * 8);
                            tint(255, 255);
                        }
                        fill(0);
                        textSize(small_step * 2);
                        text("Rank: " + Integer.toString(player.getInventory()[i + 5 * j].getRank()), x_pos + small_step, y_pos + inventory_square_size - small_step);
                    }
                }
                if (selected_slot == i + 5 * j) {
                    // Use opacity to show which option is selected
                    image(use_label, x_pos, y_pos - inventory_square_spacing, inventory_square_spacing, inventory_square_spacing);
                    image(drop_label, x_pos + (inventory_square_size - inventory_square_spacing), y_pos - inventory_square_spacing, inventory_square_spacing, inventory_square_spacing);                    
                }
            }
        }
        // Use bottom of the screen to show player health and readme messages
        int y_offset = inventory_square_spacing + (inventory_square_spacing + inventory_square_size) * player.MAX_INVENTORY / 5;
        // Display current health
        fill(100, 0, 0);
        rect(inventory_square_spacing, y_offset, displayWidth * 2/3, displayWidth/20);
        fill(255, 0, 0);
        int max_width = displayWidth * 2/3 - small_step * 2;
        rect(inventory_square_spacing + small_step, y_offset + small_step, max_width * player.getHealth() / player.maxHealth(),  displayWidth/20 - small_step * 2);
        fill(0);
        textSize(small_step * 2);
        text("HP: " + Integer.toString(player.getHealth()) + "/" + Integer.toString(player.maxHealth()), inventory_square_spacing + small_step * 2, y_offset + small_step * 3);
        text("Level: " + Integer.toString(player.getLevel()), displayWidth - 2 * inventory_square_size, y_offset);
        text("Int: " + Integer.toString(player.intelligence()), displayWidth - 2 * inventory_square_size, y_offset + small_step * 2);
        text("Dex: " + Integer.toString(player.dexterity()), displayWidth - 2 * inventory_square_size, y_offset + small_step * 4);
        text("Con: " + Integer.toString(player.constitution()), displayWidth - 2 * inventory_square_size, y_offset + small_step * 6);
    }
}
