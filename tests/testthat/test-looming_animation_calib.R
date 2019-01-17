
# test --------------------------------------------------------------------

## test works with default values
expect_message(looming_animation_calib(), "Creating calibration animation...")

# REMOVE RESULTING ANIMATION FILE

## This will only work if testing on a Mac
system("rm animation_calib.mp4")





