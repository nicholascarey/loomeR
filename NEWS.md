## loomeR 0.4.0 -- 2022-12-07

- `looming_animation` now checks that the output video has the correct number of frames, and if not gives a warning. This was in response to a user who had discovered their video had dropped frames. Likely this was because they were using an old PC, where - presumably - the hard disk write speeds were too slow to keep up with the images output by the function. See new `pause` input in next change for a solution if this happens. Note this warning is experimental - I have not been able to thoroughly test it on Windows. If you see it, it may not necessarily be true. 

- `looming_animation` has a new `pause` input. This is for users on slow PCs where frames may be dropped because the filesystem is overloaded by having to write so many image files (see above). This operator adds a delay in seconds to the generation of each frame. Generally it should be a small value, but enough that your system doesn't lag behind. For example, with a 600 frame video, 'pause = 0.05' will add an *additional* 30 seconds (600 * 0.05) to the total time taken.

- New `save_images` logical input in `looming_animation` and `looming_animation_calib` to save image files, not delete them. This is useful if you want to create the animation in an application other than `ffmpeg`, or run them through `ffmpeg` yourself.

## loomeR 0.3.0 -- 2019-07-09

- Models from `constant_speed_model` and `variable_speed_model` now contain alpha and da/dt columns calculated for the hypothesised screen viewing distance used to create them. (`diameter_model` objects, where these can't be calculated since there is never a viewing distance specified, also have these columns but they are filled with `NA`).

- Models from `constant_speed_model` and `variable_speed_model` are now slightly changed to end on last row with distance = 0. Just seems more correct to do that, however it means the first distance in row 1 isn't quite at the set `start_distance` (in `constant_speed_model` at least) but a single frame later at the specified speed. Hey, derivatives ¯\_(ツ)_/¯

- Added three internal functions to clean up code (`calc_alpha`, `calc_dadt`, `calc_screen_diam`)

#### `looming_animation` 

- Frame numbers can have custom text added to the start of each using `frame_number_tag`. E.g. A-1, A-2, or 1-1, 1-2, etc. This is super useful if you are creating multiple animations and want to make sure you don't get them mixed up.

- Output videos can have custom names using the `filename` operator. Note, the function will still
overwrite any videos it encounters with an identical filename.

- Distances from the screen edge of frame numbers and marker dots can be changed with the `_inset` operators for each

- Animations can now be looped with the `loop` operator. If this is set to 2 or greater, an additional video file is exported with the animation (including padding, if used) looped this number of times. This way you can create a long video containing multiple (though identical) looms separated by whatever time period you want (set by `pad`). For creating videos with multiple, *different* looms, I am working on an internal solution, but for now it's fairly easy to create multiple videos and join them with ffmpeg or another video editor.

- Padding frames now have their own frame numbers (if `frame_numbers = TRUE`), which are appended with a`P`. These are separate from animation frame numbers, and are specific to padded frames, i.e. they start at zero and end at the number of the final padding frame, followed by the actual animation with frame numbers that start at zero and use their own sequence. This is to assist in experiments where the animation is looped or repeated multiple times, and the user wants to identify the particular moment something happens outside of the animation playback period. For example, when a previously startled specimen returns to the experimental arena. They inherit the same `frame_number_tag` and other characteristics from the frame number settings.


## loomeR 0.2.2 -- 2019-02-05

A couple of important bug fixes related to padding videos. Also lots of minor code changes and also added unit testing code. 

v0.2.2 Changes
- FIX: making animation from a `diameter_model` would fail when padded.
- FIX: padding would sometimes fail because number of frames being added was not an integer.
- `citation("loomeR")` should return a citation. 
- Added unit testing. Most code now covered by `testthat` checks.
- Added numerous console messages and input checks to help with testing.
- Moved internal functions to separate script and removed unused ones.
- Minor changes to pass build checks and prepare for CRAN submission. 
- Minor changes to `get_alt` console print out.
- Revised README to separate code chunks, add `citation()` code, and a hit counter badge.
- Added some URLs to DESCRIPTION.
- Added macOS to Travis build checks.
- Added Appveyor Windows build checks.


## loomeR 0.2.1 -- 2019-01-11

Incorporated some internal testing using `testthat`. No outward facing changes.


## loomeR 0.2.0 -- 2018-05-02

This release introduces the `get_alt()` function. This lets you calculate the Apparent Looming Threshold for a particular response frame, as well as other metrics to analyse escape responses. Also includes various bugfixes and enhancements. 


## loomeR 0.1.3 -- 2018-04-13

### `diameter_model` updated:

- Fix for start diameter not quite correct under `constant_speed` expansion option
- Output no longer includes arbitrary `$distance` vector in `$model`
- Code cleaned up to remove use of arbitrary predator distance and size. 

- New internal fn for shortening vectors - `vect_rm_end`


## loomeR 0.1.2 -- 2018-04-05

Refinement release. Removed requirement for model object input in `looming_animation_calib`


## loomeR 0.1.1 -- 2018-04-05

Maintenance release. Minor edits to documentation.


## loomeR 0.1.0 -- 2018-04-05

Initial release.
