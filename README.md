# How to use this SFX Manager:

## Setup:

Copy all of the files inside of the "globals" folder into your project.

Add the SCENE "sfx_player.tscn" as an autoload in your project.

## Use:

When you want to add a new sound, start by loading the file into Godot.

Add a descriptive name to the enum "Labels" in sfx_player.gd.

This name should be in ALL_CAPS.

Go into the inspector of the node "SfxPlayer" in sfx_player.gd.

In the dictionary "Label to Setting," add a new pair of a key and a setting.

Select your audio file as the "stream."

Make sure to click "Add Key/Value Pair"!!

You can now call SFX.play(SFX.Labels.YOUR_LABEL).
