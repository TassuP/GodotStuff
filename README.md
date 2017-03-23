# TassuP's Godot stuff

This repository is for some little things I've made with [Godot engine](https://godotengine.org). Everything here is released under MIT-license, so you can use them in any way you like. No need to give me credit.

## Simplex noise module
A custom c++ module for a Simplex noise function. This only works for Godot 2.x, but can be used with 3.0 with very small changes (instructions in the comments). Only 2D-version for now, since that's apparently not protected by patents. This module reduces 91% of the computing time compared to GDScript implementation.
* Original GDScript version by OvermindDL1: https://github.com/OvermindDL1/Godot-Helpers/tree/master/Simplex
* More info: https://en.wikipedia.org/wiki/Simplex_noise
* How to use custom modules: http://docs.godotengine.org/en/stable/reference/custom_modules_in_c++.html

## Delaunay Triangulator
A basic 2D Delaunay triangulation demo for Godot. This demo just creates a MeshInstance from random points, but the algorithm can be used for generating terrain heightmaps, convex hulls, navmeshes, vectorizing bitmaps, caves in a roguelike, etc.
* Video: https://www.youtube.com/watch?v=bDXLIM_em08
* Ported from this code: https://gist.github.com/miketucker/3795318
* More info: https://en.wikipedia.org/wiki/Delaunay_triangulation

<p align="center">
<img src="/screenshots/delaunay_01.png" alt="Screenshot" width="250px"/>
<img src="/screenshots/delaunay_02.png" alt="Screenshot" width="250px"/>
</p>

## Texture Painter
This is a small demo showing how to paint textures directly to a 3D-model. Something like Texture Paint mode in Blender.
* Video: https://www.youtube.com/watch?v=BwI1kXFER98
* Video v2: https://www.youtube.com/watch?v=VVXb1QbjqYU

<p align="center">
<img src="/screenshots/texturepainter_01.png" alt="Screenshot" width="500px"/>
</p>
