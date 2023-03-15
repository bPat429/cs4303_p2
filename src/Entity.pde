// Superclass for all entities that move and collide
public class Entity {
    // Use a float to allow the player to move in smaller increments without needing to 'step' across tiles.
    private PVector location;
    private PImage entity_image;
    // Interact radius used to tune the size of the entity
    private float interact_radius;
    // Orientation value between -pi, pi
    private float orientation;
    // Rotation speed
    final float rotation_const;
    // Entity speed
    private float entity_speed;
    // 2D movement vector, movement_vector[0] = x axis, movement_vector[1] = y axis
    private PVector movement_vector;

    // Entity game stats
    int level;
    // Max health calculated using constitution and level
    // Balance stats by aiming for the player to kill the monster on the third turn
    int current_health;
    int base_constitution = 5;
    int base_dexterity = 5;
    int base_damage = 5;
    int dexterity() {
        return base_dexterity + level;
    }
    int constitution() {
        return base_constitution + level;
    }
    int maxHealth() {
        return 100 + constitution() * level;
    }
    // Dodge chance calculated from dexterity and level, between 0 and 1
    float dodge_chance(int enemy_dex, int enemy_level) {
        float dodge_diff = ((dexterity() * level) - (enemy_dex * enemy_level))/100;
        dodge_diff = (dodge_diff > 0.1) ? dodge_diff : 0.1;
        return (float) Math.tanh(dodge_diff);
    }
    // We also have strength, reserved for monsters, and intelligence which is reserved for the player

    private String type;

    Entity(int spawn_x, int spawn_y, int level, String type) {
        this.location = new PVector(spawn_x, spawn_y);
        this.orientation = 0;
        this.movement_vector = new PVector(0, 0);
        this.interact_radius = 0.25;
        this.rotation_const = 0.1;
        this.entity_speed = 4;
        this.level = level;
        this.current_health = maxHealth();
        this.type = type;
    }

    int getLevel() {
        return level;
    }

    void setLevel(int new_level) {
        level = new_level;
    }

    String getType() {
        return type;
    }

    int getHealth() {
        return current_health;
    }

    void setHealth(int new_health) {
        current_health = new_health;
        current_health = (current_health < 0) ? 0 : current_health;
    }

    PVector getLocation() {
        return location;
    }

    // Get euclidean distance
    float getDistance(Entity other_entity) {
        return this.location.dist(other_entity.getLocation());
    }

    // Method used to help monsters pathfind to the player
    // This is necessary because a tile's true position is the top left corner of what is displayed,
    // so we need to adjust positions relative to tiles accordingly
    int[] getDisplayTileLocation() {
        float x_pos_on_tile = location.x % 1;
        float y_pos_on_tile = location.y % 1;
        int x_tile = (x_pos_on_tile < 0.5) ? Math.round(location.x - 0.5) : Math.round(location.x + 0.5);
        int y_tile = (y_pos_on_tile < 0.5) ? Math.round(location.y - 0.5) : Math.round(location.y + 0.5);
        return new int[]{x_tile, y_tile};
    }
    
    int[] getTileLocation() {
        return new int[]{Math.round(location.x), Math.round(location.y)};
    }

    void setLocation(int x, int y) {
        this.location.set(x,y);
    }

    float getInteractRadius() {
        return interact_radius;
    }

    float getOrientation() {
        return orientation;
    }

    void setImage(PImage image) {
        this.entity_image = image;
    }

    PImage getImage() {
        return this.entity_image;
    }

    void rotateEntity(float rotation) {
        orientation = orientation + rotation;
        // Ensure orientation remains in limits
        orientation = (orientation > (float) Math.PI) ? orientation - (float) Math.PI * 2 : orientation;
        orientation = (orientation < -1 * (float) Math.PI) ? orientation + (float) Math.PI * 2 : orientation;
    }

    // Player movement vector comes from user inputs
    // Monster movement vector comes from pathfinding function
    void moveEntity(float frame_duration) {
        if (movement_vector.x != 0 || movement_vector.y != 0) {
            movement_vector.normalize();
            float heading_diff = movement_vector.heading() - orientation + (float) (0.5 * Math.PI);
            // Always rotate the shortest distance necessary
            if (heading_diff > (float) Math.PI) {
                heading_diff = heading_diff - (float) (2 * Math.PI);
            } else if (heading_diff < -1 * (float) Math.PI) {
                heading_diff = (float) (2 * Math.PI) + heading_diff;
            }

            // Slow down rotation in direction of travel to look smooth
            rotateEntity(heading_diff/10);
            // Update location
            movement_vector.setMag(entity_speed);
            location.add(movement_vector.x * frame_duration, movement_vector.y * frame_duration);
        }   
    }

    // Method used for checking if the entity's central point is inside a wall
    boolean wallContainsPoint(int[] wall_coords, PVector char_loc) {
        float loc_x = char_loc.x + 0.5;
        float loc_y = char_loc.y - 0.5;
        return (loc_x < wall_coords[0] + 0.5 && loc_x > wall_coords[0] - 0.5
            && loc_y < wall_coords[1] + 0.5 && loc_y > wall_coords[1] - 0.5);
    }
    
    // Method used for checking if the entity intersects a wall
    // Using function from https://stackoverflow.com/a/1084899
    // Code adapted and reused from P1 shell collision detection
    boolean line_intersects(PVector E, PVector L, PVector C, float r) {
        r = 0.25;
        PVector d = PVector.sub(L, E);
        PVector f = PVector.sub(E, C);
        float a = d.dot(d);
        float b = 2*f.dot(d);
        float c = f.dot(f) - (float) (Math.pow(r, 2));

        float discriminant = b*b-4*a*c;
        if( discriminant < 0 ) {return false;}
        else
        {
        discriminant = (float) Math.sqrt( discriminant );
        float t1 = (-b - discriminant)/(2*a);
        float t2 = (-b + discriminant)/(2*a);
        if( t1 >= 0 && t1 <= 1 )
        {return true ;}
        if( t2 >= 0 && t2 <= 1 )
        {return true ;}
        return false ;
        }
    }

    // Method used to check if the entity has moved into a wall
    // Adapting solution suggested by https://stackoverflow.com/a/402019
    // Code reused from P1 shell collision detection
    boolean wallIntersectsCharacter(int[] wall_coords) {
        PVector bl = new PVector(wall_coords[0] - 0.5, wall_coords[1] - 0.5);
        PVector br = new PVector(wall_coords[0] + 0.5, wall_coords[1] - 0.5);
        PVector tl = new PVector(wall_coords[0] - 0.5, wall_coords[1] + 0.5);
        PVector tr = new PVector(wall_coords[0] + 0.5, wall_coords[1] + 0.5);

        return wallContainsPoint(wall_coords, location) 
        ||  line_intersects(bl, br, location, interact_radius)
        ||  line_intersects(br, tr, location, interact_radius)
        ||  line_intersects(tr, tl, location, interact_radius)
        ||  line_intersects(bl, tl, location, interact_radius);
    }

    // Handle collisions after updating entity location
    // Separated moving the entity, and handling collisions to allow for monsters which can walk through walls
    void handleWallCollisions(int[][] level_tile_map) {
        // Check for any walls the character is penetrating, then resolve penetration by moving them back along the direction of travel
        // The character's location, rounded to the nearest integer corresponds to the current tile.
        int[] closest_tile = this.getTileLocation();
        // Check each of the tiles adjacent to the closest tile for walls and penetration
        for (int x = closest_tile[0] - 1; x <= closest_tile[0] + 1; x ++) {
            if (x >= 0 && x < level_tile_map.length) {
                for (int y = closest_tile[1] - 1; y <= closest_tile[1] + 1; y ++) {
                    if (y >= 0 && y < level_tile_map[x].length) {
                        // If the tile is blocked
                        if (level_tile_map[x][y] != 1 && level_tile_map[x][y] != 3) {
                            // Ignore diagonal tiles, these shouldn't be necessary
                            if (closest_tile[0] == x || closest_tile[1] == y) {
                                // Check if the character penetrates
                                if (wallIntersectsCharacter(new int[]{x, y})) {
                                    // Move the character in the x or y direction enough to resolve the collision
                                    // Move in the x direction if the tile is below/above, y direction if the tile is left/right of the character's tile
                                    float offset;
                                    if (closest_tile[0] == x) {
                                        if (location.y < y) {
                                        // Calculate offset
                                            offset = -1 * (interact_radius - (y - location.y - 0.5));
                                            // Avoid 'sticky' behaviour by zeroing out the offset if it is pulling towards the wall
                                            offset = (offset > 0) ? 0 : offset;
                                        } else {
                                            offset = (interact_radius - (location.y - y - 0.5));
                                            offset = (offset < 0) ? 0 : offset;
                                        }
                                        location.add(0,  offset);
                                    } else {
                                        if (location.x < x) {
                                        // Calculate offset
                                            offset = -1 * (interact_radius - (x - location.x - 0.5));
                                            offset = (offset > 0) ? 0 : offset;
                                        } else {
                                            offset = (interact_radius - (location.x - x - 0.5));
                                            offset = (offset < 0) ? 0 : offset;
                                        }
                                        location.add(offset,  0);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }

    public void drawComponent(int tile_size) {
        float entity_x = tile_size * location.x;
        float entity_y = tile_size * location.y;
        pushMatrix();
        translate(entity_x + tile_size/2, entity_y + tile_size/2);
        rotate(orientation);
        if (entity_image != null) {
            image(entity_image, -tile_size/2, -tile_size/2, tile_size , tile_size);
        } else {
            // Default to a black circle in case of no image
            fill(0);
            circle(0, 0, interact_radius * tile_size * 2);
        }
        popMatrix();
    }
}