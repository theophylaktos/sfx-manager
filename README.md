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

## Available Settings per label:
	
Bus - The Audio Bus for the audio to be played on.

Stream - The AudioStream to be played.

Volume - Volume in decibels.

Volume Variance - Random volume variance per AudioStreamPlayer.

Pitch Variance - Random pitch variance per AudioStreamPlayer.

Min Delay - Minimum time between when sounds using the same label can be played.


## Available Functions:

play() - Adds an AudioStreamPlayer playing parameter label. Can be loopable, and have per stream volume and pitch modulation

play_random() - Same as play, but selects a random sound from a parameter array

The nine following functions all can fade in / fade out, with a optional parameter for the length of the fade

unpause_one(), pause_one(), clear_one() - Unpause, Pause, or Clear one stream

unpause_type(), pause_type(), clear_type() - Unpause, Pause, or Clear all streams with one label

unpause_all(), pause_all(), clear_all() - Unpause, Pause, or Clear all streams

play_2d() - Adds an AudioStreamPlayer2D playing parameter label to parameter node

play_3d() - Adds an AudioStreamPlayer3D playing parameter label to parameter node

## Miscellaneous:

DEBUG_MESSAGES - Optionally print a message each time one of the functions under Available Functions is called
