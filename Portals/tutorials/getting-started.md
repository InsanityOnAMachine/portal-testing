# Getting started

Welcome to my Godot smooth portal system! You probably want to use them, and here's how:
	
	- use them.
	
and if you want some detail, here:
	
	- some detail
	
Aight here's a real tutorial:
	
## The basics

The portal system has four main Nodes: 
	
	- PortalOrigin ("you", in a sense. Portals are drawn with this as the viewpoint)
	- PortalRoom (groups portals together and provided a render texture)
	- Portal (used to draw what you can see thru it, plus teleport Portables)
	- Portable (anything that can go thru Portals. It remembers the current PortalRoom it's in)
	
When a PortalOrigin is called to generate those fancy look-through-portal things, it looks at all the Portals
in the current room it's in and tests which of them it can see. It then obtains a mesh from each one, which has a texture recorded from the room the Portal looks into, thus giving the illusion of the room being right there.

The PortalRoom exists to record footage of what's inside it to display on the meshes sticking out of Portals.
You could forego this and make 1 PortalRoom for each Portal, but you'd be recording the same area with multiple cameras.
It sort of batches them, if you think about it.

The PortalOrigin is also inherited from Portable, which is a Node that remembers what room it's in and handles teleporting itself.
It has a function called get_move() that takes in a Vector2 you want to move along (i.e. you would normally add this vector to the node's position)
and returns a RoomMovement, which contains:
	- room (the room you end up in. Could be the one you're already in, unless you walk through a portal)
	- pos (where in the world you end up)
	- rot (what direction you end up facing (in degrees))
which you can use to position yourself accordingly.

That is pretty much it.

## Tutorial

Let's make your first portal setup. First, you're gonna need a world. 

- (Create a new empty scene)

If your scene is empty, you won't be able to tell what you're lookin' at thru a Portal, because
it'll look the same as everything else. The best background for now would just be some random image.

- (Add a Sprite with a good-sized image in it)

Now, create an instance of the portal_room.tscn scene.
You will notice that the debug setting is on, and should see a yellow rectangle.
Manipulate the PortalRoom's position and size property in the inspector, so that it contains the image.
Preferably it goes a bit beyond the edges of the image; it don't need to be precise at all.

- (Create and size an instance of the portal_room.tscn scene)

Now, create two Portals. These should not be children of the PortalRoom;
because when you want to resize the room's bounds, the top left corner is changed by moving
the room's global position, which would drag the portals around too. You should be able to find them
in the Create New Node menu, just like you would when creating any other type of node.

You should see that the debug setting for each of these is on, too, and there should be a visual
representation of the portsl; i.e. a line showing the portal plane and a little line showing what direction
the portal is facing. When you walk into a portal, this line is pointing towards you. It is the "front" of the portal.

You can rotate portals to change their direction, and change their size via their width setting in the inspector
(NOT by scaling them; they ignore their scale in the scene.)
Place them somewhere in the room bounds, not too near the edges, and point them wherever.

- (Create and place two portals)

Now go to the PortalRoom (hopefully ya haven't turned debug off!) and click the 'Collect all Portals within bounds'
button. This automatically does what it says, so ya don't gotta add each portal to the room's portals Array manually.
You should see a red dot over each Portal.

- (Connect the Portals to the PortalRoom)

Now go to one of the Portals, and set its 'other' setting to be the other Portal. Your setup is complete, 
and you should see a solid green line connecting the two.

- (Link the Portals)

Movement in the portals sytem is about as hard as making a character controller (pretty easy, but a teensy struggle).
For this tutorial, instantiate the player.tscn scene in the /demo folder.
This comes with a Camera2D that follows it and a Sprite that rotates. It moves using WASD.

- (Create the Player)

Now finally go to the Player and set its current_room setting to be the PortalRoom.

- (Link the Player to the PortalRoom)

You should now be able to run your scene and walk around, and look through the portals, and walk thru them too.
If not, buy a new computer and try again (and of course I am joking?)
