import java.util.Random;
import java.util.ArrayList;

final class CombatHandler {
    private Player player;
    private int combat_rect_width = displayWidth/5;
    private int combat_rect_height = (displayHeight/5)/2;
    private int combat_rect_spacing = displayWidth/20;
    private int left_offset = displayWidth/5;
    private int selected_slot;
    private int selected_option;
    private PImage execute_label;
    private PImage cooldown_label;
    // Slow down rate of inputs
    private float input_cooldown;
    private String player_last_action;
    private String monster_last_action;
    int current_turn;

    CombatHandler(Player player) {
        this.player = player;
        selected_slot = 0;
        selected_option = 0;
        execute_label = loadImage("Execute.png");
        cooldown_label = loadImage("onCooldown.png");
        current_turn = 0;
    }

    void runCombatTurn(Monster monster, Random rand) {
        int column_index = selected_slot % 3;
        if (column_index < 2) {
            int spell_index = (selected_slot > 2) ? column_index + 2 : column_index;
            // Try to cast a spell
            int damage = player.castSpell(spell_index, current_turn);
            if (damage > -1) {
                player_last_action = "Cast spell, ";
                float monster_dodge_chance = monster.dodge_chance(player.dexterity(), player.getLevel());
                print(monster_dodge_chance);
                boolean monster_dodges = (rand.nextFloat() <= monster_dodge_chance);
                if (monster_dodges) {
                    player_last_action = player_last_action + monster.getType() + " dodges the attack";
                } else {
                    player_last_action = player_last_action + "Hits for " + Integer.toString(damage) + " damage!";
                    monster.setHealth(monster.getHealth() - damage);
                    if (monster.getHealth() <= 0) {
                        return;
                    }
                }
            } else {
                // Otherwise the spell is on cooldown, or not-slotted so we do nothing
                return;
            }
        } else {
            // TODO implement other actions
            return;
        }
        // Monster's turn
        int damage = monster.calculateDamage();
        float player_dodge_chance = player.dodge_chance(monster.dexterity(), monster.getLevel());
        print("Geh\n");
        print(player_dodge_chance);
        boolean player_dodges = (rand.nextFloat() <= player_dodge_chance);
        monster_last_action = "Attacks the player, ";
        if (player_dodges) {
            monster_last_action = monster_last_action + "Player dodges the attack";
        } else {
            monster_last_action = monster_last_action + "Hits for " + Integer.toString(damage) + " damage!";
            player.setHealth(player.getHealth() - damage);
        }
        current_turn++;
    }

    void run(ArrayList<Monster> combat_queue, boolean[] input_array, Random rand) {
        if (millis() - input_cooldown > 100) {
            // Use input_cooldown to give a slight delay before defeating the monster/game over
            // TODO player defeat
            if (combat_queue.get(0).getHealth() <= 0) {
                int exp = combat_queue.get(0).calculateExperience();
                player.addExperience(exp);
                combat_queue.remove(0);
                current_turn = 0;
                player.resetSpellCooldowns();
                // Return to the dungeon after defeating the last enemy
                if (combat_queue.size() == 0) {
                    return;
                }
            }
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
                runCombatTurn(combat_queue.get(0), rand);
            }
        }
        drawComponent();
    }

    void drawCharacter(int x_offset, Entity entity) {
        int small_step = displayWidth/100;
        int x_segment = displayWidth/7;
        int y_segment = displayHeight/2 - small_step * 4;
        fill(0);
        rect(x_offset, small_step * 2, x_segment * 2, y_segment);
        fill(100);
        rect(x_offset + small_step * 2, small_step * 4, x_segment * 2 - small_step * 4, (y_segment - small_step * 4) / 2);
        // Draw character
        entity.getImage().resize(0, (y_segment - small_step * 4) / 2);
        image(entity.getImage(), x_offset + small_step * 2 + ((x_segment * 2 - small_step * 4) - entity.getImage().width) / 2, small_step * 4);
        // Health bar
        fill(100, 0, 0);
        rect(x_offset + small_step * 2, (y_segment - small_step * 4) / 2 + small_step * 6, x_segment * 2 - small_step * 4, small_step * 3);
        fill(255, 0, 0);
        int max_width = x_segment * 2 - small_step * 6;
        rect(x_offset + small_step * 3, (y_segment - small_step * 4) / 2 + small_step * 6.5, max_width * entity.getHealth() / entity.maxHealth(),  small_step * 2);
        fill(0);
        textSize(small_step);
        text("HP: " + Integer.toString(entity.getHealth()) + "/" + Integer.toString(entity.maxHealth()), x_offset + small_step * 3.5, (y_segment - small_step * 4) / 2 + small_step * 7.5);
        String last_action = (entity.getType() == "player") ? player_last_action : monster_last_action;
        last_action = (last_action == null) ? "Combat begins." : last_action;
        fill(200);
        text("Log: " + last_action, x_offset + small_step * 2, y_segment - small_step * 2);
        
    }

    void drawComponent() {
        background(150);
        // Upper half of the screen display the player, the monster, the health bars and the actions taken
        int small_step = displayWidth/100;
        int x_segment = displayWidth/7;
        int y_segment = displayHeight/2 - small_step * 4;
        drawCharacter(x_segment, player);
        drawCharacter(x_segment * 4, combat_queue.get(0));

        // Lower half of the screen display the options
        int y_offset = displayHeight/2;
        for (int j = 0; j < 2; j++) {
            for (int i = 0; i < 3; i++) {
                int x_pos = combat_rect_spacing * i + combat_rect_width * i + left_offset;
                int y_pos = combat_rect_spacing + j * (combat_rect_spacing + combat_rect_height) + y_offset;
                fill(0);
                rect(x_pos, y_pos, combat_rect_width, combat_rect_height);
                PImage spell_image;
                String spell_name;
                if (i < 2) {
                    spell_image = player.getSpellImage(i + 2 * j);
                    if (spell_image != null) {
                        spell_name = player.getSpellName(i + 2 * j);
                        spell_image.resize(0, combat_rect_height);
                        image(spell_image, x_pos + (combat_rect_width - spell_image.width)/2, y_pos);
                        textSize(small_step);
                        fill(255);
                        text(spell_name, x_pos + small_step * 7, y_pos + small_step * 1);
                        if (!player.isSpellReady(i + 2 * j, current_turn)) {
                            // Spell is on cooldown
                            cooldown_label.resize(combat_rect_width, 0);
                            tint(255, 200);
                            image(cooldown_label, x_pos, y_pos + small_step * 0.5); 
                            tint(255, 255);
                            
                        }
                    }
                }
                if (selected_slot == i + 3 * j) {
                    // Use opacity to show which option is selected
                    image(execute_label, x_pos, y_pos - combat_rect_spacing, combat_rect_width, combat_rect_spacing);                  
                }
            }
        }
    }
}
