import java.util.Random;

final class Player extends Entity {
    private final int MAX_INVENTORY = 5;
    private int inventory_space = MAX_INVENTORY;
    private Interactable[] inventory;

    Player(int spawn_x, int spawn_y, int tile_size) {
        super(spawn_x, spawn_y, tile_size);
        super.setImage(loadImage("wizard.png"));
        inventory = new Interactable[MAX_INVENTORY];
    }

    boolean pickupItem(Interactable new_item) {
        if (inventory_space == 0) {
            return false;
        } else {
            for (int i = 0; i < MAX_INVENTORY; i++) {
                if (inventory[i] == null) {
                    inventory[i] = new_item;
                    inventory_space = inventory_space -1;
                    return true;
                }
            }
            print("Error, This shouldn't have happened");
            return false;
        }
    }

    void handleInput(boolean[] input_array, float frame_duration) {
        // Apply rotation from q and e. This isn't directly functional but allows the player to 'look' with their character
        if (input_array[5]) {
            super.rotateEntity(super.rotation_const);
        }
        if (input_array[4]) {
            super.rotateEntity(super.rotation_const * -1);
        }
        // Zero out movement vector
        super.movement_vector.set(0, 0);
        // Use kinematic motion for movement, where w,a,s,d all cause movement in their own directions. We rotate the player to face the direction of travel.
        if (input_array[0]) {
            super.movement_vector.sub(1, 0);
        }
        if (input_array[1]) {
            super.movement_vector.add(1, 0);
        }
        if (input_array[2]) {
            super.movement_vector.sub(0, 1);
        }
        if (input_array[3]) {
            super.movement_vector.add(0, 1);
        }
        super.moveEntity(frame_duration);
    }
}