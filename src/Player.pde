import java.util.Random;

final class Player {
    // Use a float to allow the player to move in smaller increments without needing to 'step' across tiles.
    private float[] location;
    private int tile_size;
    private PImage wizard_img;
    // Interact radius used to tune the range of the player interacting with objects
    private float interact_radius;

    Player(int spawn_x, int spawn_y, int tile_size) {
        this.location = new float[]{spawn_x, spawn_y};
        this.tile_size = tile_size;
        this.wizard_img = loadImage("wizard.png");
    }

    float[] getLocation() {
        return location;
    }

    float getInteractRadius() {
        return interact_radius;
    }

    public void draw() {
        // TODO fix this
        float player_x = tile_size * location[0];
        float player_y = tile_size * location[1];
        image(wizard_img, player_x, player_y, tile_size , tile_size);
    }
}
