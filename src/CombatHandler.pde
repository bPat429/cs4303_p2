import java.util.Random;
import java.util.ArrayList;

final class CombatHandler {
    private Player player;
    private int combat_rect_width = displayWidth/5;
    private int combat_rect_height = (displayHeight/5)/2;
    private int combat_rect_spacing = displayWidth/20;
    private int left_offset = displayWidth/5;
    private int selected_slot;
    private PImage execute_label;
    private PImage cooldown_label;
    private PImage dodge_label;
    private PImage flee_label;
    // Slow down rate of inputs
    private float input_cooldown;
    private String player_last_action;
    private String monster_last_action;
    int current_turn;

    CombatHandler(Player player) {
        this.player = player;
        selected_slot = 0;
        execute_label = loadImage("Execute.png");
        cooldown_label = loadImage("onCooldown.png");
        dodge_label = loadImage("Dodge.png");
        flee_label = loadImage("Flee.png");
        current_turn = 0;
    }

    void resetCombat() {
        combat_queue.remove(0);
        current_turn = 0;
        player.resetSpellCooldowns();
        player_last_action = null;
        monster_last_action = null;
        return;
    }

    void runCombatTurn(ArrayList<Monster> combat_queue, Monster monster, Random rand) {
        boolean monster_tries_to_dodge = (rand.nextFloat() <= 0.1);
        int column_index = selected_slot % 3;
        if (column_index < 2) {
            int spell_index = (selected_slot > 2) ? column_index + 2 : column_index;
            // Try to cast a spell
            int damage = player.castSpell(spell_index, current_turn);
            if (damage > -1) {
                player_last_action = "Cast spell, ";
                // If the monster is trying to dodge then ignore player stats
                float monster_dodge_chance = (monster_tries_to_dodge) ? monster.dodge_chance(0, 0) : monster.dodge_chance(player.dexterity(), player.getLevel());
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
            // If dodging resolve it in the monster's turn
            if (selected_slot == 2) {
                player_last_action = "Player tries to dodge";
            } else if (selected_slot == 5) {
                // Try to flee
                player_last_action = "Player tries to flee";
                // Player escape chance is always 0.5, tying it to stats will make it harder for the player to flee when they should be running
                // e.g. the monster is a higher level
                if (rand.nextFloat() <= 0.5) {
                    // On successful flee just remove the mosnter from the queue. This avoids awarding the player xp
                    resetCombat();
                }
            }
        }
        // Monster's turn
        if (monster_tries_to_dodge) {
            monster_last_action = "Monster tries to dodge";
        } else {
            int damage = monster.calculateDamage();
            // If player is dodging then ignore the monster's stats
            float player_dodge_chance = (selected_slot == 2) ? player.dodge_chance(0, 0) : player.dodge_chance(monster.dexterity(), monster.getLevel());
            boolean player_dodges = (rand.nextFloat() <= player_dodge_chance);
            monster_last_action = "Attacks the player, ";
            if (player_dodges) {
                monster_last_action = monster_last_action + "Player dodges the attack";
            } else {
                monster_last_action = monster_last_action + "Hits for " + Integer.toString(damage) + " damage!";
                player.setHealth(player.getHealth() - damage);
            }
        }
        current_turn++;
    }

    void run(ArrayList<Monster> combat_queue, boolean[] input_array, Random rand) {
        if (millis() - input_cooldown > 100) {
            // Use input_cooldown to give a slight delay before defeating the monster/game over
            if (player.getHealth() <= 0) {
                // Game over
                return;
            }
            if (combat_queue.get(0).getHealth() <= 0) {
                int exp = combat_queue.get(0).calculateExperience();
                player.addExperience(exp);
                resetCombat();
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
                runCombatTurn(combat_queue, combat_queue.get(0), rand);
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
        PImage entity_image = entity.getImage();
        if (entity.getType() == "Mimic") {
            Mimic mimic = (Mimic) entity;
            entity_image = mimic.getMimicRevealedImage();
        }
        entity_image.resize(0, (y_segment - small_step * 4) / 2);
        image(entity_image, x_offset + small_step * 2 + ((x_segment * 2 - small_step * 4) - entity_image.width) / 2, small_step * 4);
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
        text(entity.getType() + ", Level: " + Integer.toString(entity.getLevel()), x_offset + small_step * 2, y_segment - small_step * 3.5);
        text("Log: " + last_action, x_offset + small_step * 2, y_segment - small_step * 2);
        
    }

    void drawComponent() {
        background(150);
        // Upper half of the screen display the player, the monster, the health bars and the actions taken
        int small_step = displayWidth/100;
        int x_segment = displayWidth/7;
        int y_segment = displayHeight/2 - small_step * 4;
        drawCharacter(x_segment, player);
        // If the player has fled don't draw the enemy
        if (combat_queue.size() > 0) {
            drawCharacter(x_segment * 4, combat_queue.get(0));
        }

        // Display current turn
        fill(0);
        textSize(small_step * 2);
        text("Turn: " + Integer.toString(current_turn), displayWidth / 2 - small_step * 3, (y_segment + small_step * 4));

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
                        // SpellPage image is a little too large so shift it down
                        if (player.getSpellLevel(i + 2 * j) == 1) {
                            image(spell_image, x_pos + (combat_rect_width - spell_image.width)/2, y_pos + small_step);
                        } else {
                            image(spell_image, x_pos + (combat_rect_width - spell_image.width)/2, y_pos);
                        }
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
                } else if (j == 0) {
                    dodge_label.resize(combat_rect_width/2, 0);
                    image(dodge_label, x_pos + combat_rect_width/2 - small_step * 4.5, y_pos - small_step * 2); 
                } else {
                    flee_label.resize(combat_rect_width/2, 0);
                    image(flee_label, x_pos + combat_rect_width/2 - small_step * 4.5, y_pos - small_step * 2); 
                }
                if (selected_slot == i + 3 * j) {
                    // Use opacity to show which option is selected
                    image(execute_label, x_pos, y_pos - combat_rect_spacing, combat_rect_width, combat_rect_spacing);                  
                }
            }
        }
    }
}
