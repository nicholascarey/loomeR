# loomeR 0.4.0 - 2022_12_07

- `looming_animation` now checks that the output video has the correct number of frames, and if not gives a warning. This was in response to a user who had discovered their video had dropped frames. Likely this was because they were using an old PC, where - presumably - the hard disk write speeds were too slow to keep up with the images output by the function. See new `pause` input in next change for a solution if this happens. Note this warning is experimental - I have not been able to thoroughly test it on Windows. If you see it, it may not necessarily be true. 

- `looming_animation` has a new `pause` input. This is for users on slow PCs where frames may be dropped because the filesystem is overloaded by having to write so many image files (see above). This operator adds a delay in seconds to the generation of each frame. Generally it should be a small value, but wnough that your system doesn't lag behind. For example, with a 600 frame video, 'pause = 0.05' will add an *additional* 30 seconds (600 * 0.05) to the total time taken.

- New `save_images` logical input in `looming_animation` and `looming_animation_calib` to save image files, not delete them. This is useful if you want to create the animation in an application other than `ffmpeg`, or run them through `ffmpeg` yourself.

