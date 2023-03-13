// Goblin type monster
class Kobold extends Monster {
    static final float spawn_chance = 0.33;

    Kobold(int spawn_x, int spawn_y, int level) {
        super(spawn_x, spawn_y, level, "Kobold");
        super.setImage(loadImage("kobold.png"));
    }
}