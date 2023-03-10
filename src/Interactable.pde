// Interface for all interactable parts of the map
// This includes items on the floor, and staircases
interface Interactable {
  // For items this will be picking up
  // For staircases this will be travelling to the next level
  public void interact();
  // Check if the player is colliding with an object, and therefore if they can interact
  public boolean checkCollision(Player player);
}
