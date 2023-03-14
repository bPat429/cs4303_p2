import java.util.Random;

final class Player extends Entity {
    final int MAX_INVENTORY = 10;
    private int inventory_space = MAX_INVENTORY;
    private Interactable[] inventory;
    // Indexes of all equipped items
    // index: 0 = head, 1 = chest, 2 = weapon
    private int[] equipped_items;

    // External stat modifiers, all initialise to 0:
    private int con_modifier;
    private int dex_modifier;
    private int int_modifier;
    // Weapon modifier is added to base damage
    private int weapon_modifier;
    // Player stats
    int maxHealth() {
        return 100 + constitution() * level;
    }
    private int base_intelligence;
    int intelligence() {
        return base_intelligence + int_modifier + level;
    }
    int dexterity() {
        return base_dexterity + dex_modifier + level;
    }
    int constitution() {
        return base_constitution + con_modifier + level;
    }

    // Calculate damage for the player's attack
    // spell_modifier is a % value
    int calculateDamage(int spell_modifier) {
        return intelligence() * (base_damage + weapon_modifier) * (spell_modifier/100);
    }

    Player() {
        super(0, 0, 1, "player");
        super.setImage(loadImage("wizard.png"));
        super.entity_speed = super.entity_speed * 1.5;
        inventory = new Interactable[MAX_INVENTORY];
        base_intelligence = 5;
        this.setHealth(1);
        equipped_items = new int[]{-1, -1, -1};
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

    boolean isWearing(int item_index) {
        if (inventory[item_index].getType() == 0) {
            Equipment equipment = (Equipment) inventory[item_index];
            return (item_index == equipped_items[equipment.get_equipment_type()]);
        }
        return false;
    }

    void unequip(int item_index) {
        if (inventory[item_index].getType() == 0) {
            Equipment equipment = (Equipment) inventory[item_index];
            if (item_index == equipped_items[equipment.get_equipment_type()]) {
                // Unequip item
                equipped_items[equipment.get_equipment_type()] = -1;
                // revert stat modifier changes
                equipment.removeBuffs(this);
                return;
            }
        }
    }

    void dropItem(int item_index) {
        // If the item is equipment make sure to unequip it first
        unequip(item_index);
        inventory[item_index] = null;
    }

    void useItem(int item_index) {
        // Check if the item is equippable
        if (inventory[item_index].getType() == 0) {
            Equipment equipment = (Equipment) inventory[item_index];
            if (item_index == equipped_items[equipment.get_equipment_type()]) {
                unequip(item_index);
            } else {
                // Equip the item and apply the stat modifier changes
                equipment.applyBuffs(this);
                equipped_items[equipment.get_equipment_type()] = item_index;
            }
        }
        if (inventory[item_index].use(this)) {
            inventory[item_index] = null;
        }
    }

    // Restore a percentage of the user's health
    void restoreHealth(float val) {
        int new_health = this.getHealth() + (int) (val * this.maxHealth());
        new_health = (new_health > this.maxHealth()) ? this.maxHealth() : new_health;
        this.setHealth(new_health);
    }


    // Methods for equipment to buff/debuff the player
    void addInt(int val) {
        this.int_modifier = this.int_modifier + val;
    }

    void removeInt(int val) {
        this.int_modifier = this.int_modifier - val;
    }

    void addDex(int val) {
        this.dex_modifier = this.dex_modifier + val;
    }

    void removeDex(int val) {
        this.dex_modifier = this.dex_modifier - val;
    }

    void addCon(int val) {
        this.con_modifier = this.con_modifier + val;
    }

    void removeCon(int val) {
        this.con_modifier = this.con_modifier - val;
    }

    Interactable[] getInventory() {
        return inventory;
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