# Godot pointcloud viewer

<p align="center">
	<img src="icon.svg" alt="Logo" width="200"/>
<p>


This application can render 3D pointclouds with label support, and you can inspect them (fly around) in first person. Currently the release works only on windows machines. You can try compiling the project yourself on your desired OS. [Video demo](https://www.youtube.com/watch?v=F37Oqu7L1K4)

### Features

+ Render 3D labeled or unlabeled pointclouds (I have not properly limit tested it, but it can run a 500k pointcloud with no issues. Reading the file can take some time, depending on the size of the pointcloud file ~500k labeled points ~20 seconds)
+ Explore the pointcloud in first person, change basic control parameters - speed, sensitivity, boost
+ Change the look of the pointcloud - change each label color, their corresponding point sizes. Change the background color
+ Some basic display settings e.g. FOV, fullscreen,
+ Animation - orbit around the pointcloud (can be used to make good video recordings of the pointcloud with minimal effort)

### How to use

1. Download the latest release
2. Prepare your pointcloud file or try an example one

	2.1. File extension should be *.txt* or *.csv*
	
	2.2. Points should be seperated by a new line
	
	2.3. Each line should be in the following format:
		*x,y,z,label(optional)*
		
	2.3.1. You can choose what seperator you use, but it has to be one symbol - cannot be *comma* + *space* as it's two symbols
		
	2.3.2. label is optional
		
	2.3.3. *z* corresponds to height
	
4. Open the application, select your pointcloud file
5. Basic controls are shown on the screen, settings can be found by pressing the ESC button

If you wish to launch the app from the command prompt, you can do so like this: `godot_point_cloud_viewer_v1_0_1_0.exe --path="C:Templates\building_roof.txt" --separator="," --useLabels=true`

To use whitespace for a seperator, replace it with `%20` and for horizontal indent, replace it with `%09`

### Future work
I don't plan on spending a lot of time on this project, but some features that I still would like to implement:
+ ~~Built in animations (orbit) for easy video recording~~
+ ~~Proper handling of seperators (currently can be buggy)~~
+ Writting a custom shader - currently the points are really 2D squares. Also could probably get some more performance out of this
+ ~~Adding some template pointclouds~~

### Some screenshots

Menu screen:
<p align="center">
	<img src="Screenshots/menu.jpg" alt="menu" width="800"/>
<p>

View + settings:
<p align="center">
	<img src="Screenshots/view.jpg" alt="view" width="800"/>
<p>
