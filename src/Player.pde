import java.util.Random;

final class Player {
    // Use a float to allow the player to move in smaller increments without needing to 'step' across tiles.
    private PVector location;
    private int tile_size;
    private PImage wizard_img;
    // Interact radius used to tune the range of the player interacting with objects, must be less than 0.5
    private float interact_radius;
    // Orientation value between -pi, pi
    private float orientation;
    private final float rotation_const = 0.1;
    private final float player_speed = 7.5;
    // 2D movement vector, movement_vector[0] = x axis, movement_vector[1] = y axis
    private PVector movement_vector;

    Player(int spawn_x, int spawn_y, int tile_size) {
        this.location = new PVector(spawn_x, spawn_y);
        this.tile_size = tile_size;
        this.wizard_img = loadImage("wizard.png");
        this.orientation = 0;
        this.movement_vector = new PVector(0, 0);
        this.interact_radius = 0.25;
    }

    PVector getLocation() {
        return location;
    }

    float getInteractRadius() {
        return interact_radius;
    }

    float getOrientation() {
        return orientation;
    }

    void rotatePlayer(float rotation) {
        orientation = orientation + rotation;
        // Ensure orientation remains in limits
        orientation = (orientation > (float) Math.PI) ? orientation - (float) Math.PI * 2 : orientation;
        orientation = (orientation < -1 * (float) Math.PI) ? orientation + (float) Math.PI * 2 : orientation;
    }

    void handleInput(boolean[] input_array, float frame_duration) {
        // Apply rotation from q and e. This isn't directly functional but allows the player to 'look' with their character
        if (input_array[5]) {
            rotatePlayer(rotation_const);
        }
        if (input_array[4]) {
            rotatePlayer(rotation_const * -1);
        }
        // Zero out movement vector
        movement_vector.set(0, 0);
        // Use kinematic motion for movement, where w,a,s,d all cause movement in their own directions. We rotate the player to face the direction of travel.
        if (input_array[0]) {
            movement_vector.sub(1, 0);
        }
        if (input_array[1]) {
            movement_vector.add(1, 0);
        }
        if (input_array[2]) {
            movement_vector.sub(0, 1);
        }
        if (input_array[3]) {
            movement_vector.add(0, 1);
        }
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
            rotatePlayer(heading_diff/10);
            // Update location
            movement_vector.setMag(player_speed);
            location.add(movement_vector.x * frame_duration, movement_vector.y * frame_duration);
        }
    }

    boolean wallContainsPoint(int[] wall_coords, PVector char_loc) {
        float loc_x = char_loc.x + 0.5;
        float loc_y = char_loc.y - 0.5;
        return (loc_x < wall_coords[0] + 0.5 && loc_x > wall_coords[0] - 0.5
            && loc_y < wall_coords[1] + 0.5 && loc_y > wall_coords[1] - 0.5);
    }
    
    // Using function from https://stackoverflow.com/a/1084899
    // Code reused from P1 shell collision detection
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

    // Handle collisions after updating player location
    void handleWallCollisions(int[][] level_tile_map) {
        // Check for any walls the character is penetrating, then resolve penetration by moving them back along the direction of travel
        // The character's location, rounded to the nearest integer corresponds to the current tile.
        int[] closest_tile = new int[]{Math.round(location.x), Math.round(location.y)};
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

    public void draw() {
        // TODO fix this
        float player_x = tile_size * location.x;
        float player_y = tile_size * location.y;
        pushMatrix();
        translate(player_x + tile_size/2, player_y + tile_size/2);
        //translate(-tile_size/2, -tile_size/2);
        rotate(orientation);
        image(wizard_img, -tile_size/2, -tile_size/2, tile_size , tile_size);
        fill(0);
        circle(0, 0, interact_radius * tile_size * 2);
        popMatrix();
        //rotate(-1 * orientation);
    }
}