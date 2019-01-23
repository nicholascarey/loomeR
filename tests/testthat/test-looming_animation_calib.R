
# test --------------------------------------------------------------------

## test works with default values
expect_message(looming_animation_calib(), "Creating calibration animation...")


# test --------------------------------------------------------------------

## test odd numbered resolution is modified - width

expect_message(looming_animation_calib(width = 1279,
                                 height = 1023),
               "Screen `width` cannot be an odd number.")

# test --------------------------------------------------------------------

## test odd numbered resolution is modified - height

expect_message(looming_animation_calib(width = 1279,
                                 height = 1023),
               "Screen `height` cannot be an odd number.")




# Skip on travis tests ----------------------------------------------------

# test --------------------------------------------------------------------

## test system command runs
skip_on_travis()
expect_message(looming_animation_calib(),
               "Encoding movie...")


# REMOVE RESULTING FILES --------------------------------------------------

## This will only work if testing on a Mac
system("rm animation_calib.mp4")
