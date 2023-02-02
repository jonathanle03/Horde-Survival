# Horde Survival
## Video Demo:  https://www.youtube.com/watch?v=xyIAO01k92s
## Description:
Horde Survival is a survival type game with infinite progression. The goal of the game is to survive for as long a possible. Although enemies get stronger over time, you can purchase upgrades in between runs, making you stronger and stronger.
## Files:
### **lume.lua**
Lume is a library by rxi. In this project, it was used to serialize save data and deserialize it when loading the game. It does have other functions, but I didn't require them.
### **classic.lua**
Classic is another library by rxi. This introduces classes that are similar to other languages and game engines, rather than lua classes. The majority of the other files use this library to implement a base class and multiple derived classes. The inheritance is as follows: entity.lua (base class) -> player.lua, enemy.lua, bullet.lua; textbox.lua (base class) -> button.lua. Generally the derived classes call on the base classes constructors as well as their update and draw functions and build upon them, though sometimes these functions are overriden instead.
### **main.lua**
The bulk of the code is in main. Having access to every file, it can manipulate the properties of each class/object and allows for each object to communicate with one another.
## Design Choices:
Originally, I intended to create a roguelite game with multiple abilities/spells. While I was working on the core gameplay (movement and shooting bullets), I realized that although it wasn't entirely out of the question, I would need to invest a lot of time in learning how to make a procedurally generated dungeon. I decided to just focus on the basics first, which I think was a good decision since even now I still want to polish it a bit more.
I also was planning on not using the Classic library. When I was making different types of entities, I thought it was fine until I had to instantiate many enemies and bullets. That's when I decided to move a lot of my code into separate files and used to Classic library to create classes. I'm very glad that I did because it allowed me to make a separate base class for textboxes which made implementing text and buttons significantly easier.
## Closing Thoughts:
I invested about 15 days in total to learn the Lua language and the Love2D framework and finally create my first project. This project, although very stressful, was also extremely fun and eye opening. Even though it's not very polished, I'm very proud of how far I have come even in just these past 2 weeks. Lastly, I'm very glad that I got to take such a wonderful class and end it with a project of my own. This was CS50!