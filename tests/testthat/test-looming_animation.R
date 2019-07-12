
# test --------------------------------------------------------------------

## test does not accept df
df <- data.frame(c(1:3), c(4:6))
expect_error(looming_animation(df))

test_that("does not accept df",
          expect_error(looming_animation(df)))

# test --------------------------------------------------------------------

## test accepts "diameter_model" class
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_message(looming_animation(mod), "diameter_model detected.")

test_that("accepts diameter_model class",
          expect_message(looming_animation(mod), "diameter_model detected."))

# test --------------------------------------------------------------------

## test accepts "variable_speed_model" class
mod <- variable_speed_model(x = rep(1, 20))
expect_message(looming_animation(mod), "variable_speed_model detected.")

# test --------------------------------------------------------------------

## test accepts "constant_speed_model" class
mod <- constant_speed_model(frame_rate = 30,
                            speed = 500,
                            start_distance = 500)

expect_message(looming_animation(mod,
                                 frame_number = TRUE,
                                 frame_number_position = "bl"),
               "constant_speed_model detected.")




# test --------------------------------------------------------------------

## test exports data
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)
loomeR::looming_animation(mod,
                          save_data = TRUE,
                          frame_number = TRUE)

test_path("ANIM_from_x_30fps_1280x1024.csv")

# REMOVE RESULTING FILE
## This will only work if testing on a Mac
system("rm ANIM_from_x_30fps_1280x1024.csv")



# test --------------------------------------------------------------------

## test padding works
x <- loomeR::diameter_model(start_diameter = 10,
                            end_diameter = 9.5,
                            duration = 1,
                            frame_rate = 29.97)

expect_error(looming_animation(x, pad = 1),
             NA)


# test --------------------------------------------------------------------

## test padding blank works

expect_error(looming_animation(x, pad = 1, pad_blank = TRUE),
             NA)

# test --------------------------------------------------------------------

## test dots

expect_error(looming_animation(x, dots = TRUE, dots_position = "tl"),
             NA)

expect_error(looming_animation(x, dots = TRUE, dots_position = "br"),
             NA)

# test --------------------------------------------------------------------

## test null correction

expect_error(looming_animation(x, correction = NULL),
             NA)


# test --------------------------------------------------------------------

## test odd numbered resolution is modified - width

expect_message(looming_animation(x,
                                 width = 1279,
                                 height = 1023),
               "Screen `width` cannot be an odd number.")



# test --------------------------------------------------------------------

## test odd numbered resolution is modified - height

expect_message(looming_animation(x,
                                 width = 1279,
                                 height = 1023),
               "Screen `height` cannot be an odd number.")


# Skip on travis tests ----------------------------------------------------

# test --------------------------------------------------------------------

## test system command runs
skip_on_travis()
skip_on_appveyor()
skip_on_cran()
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_message(looming_animation(mod,
                                 frame_number = TRUE,
                                 frame_number_position = "bl"),
               "Encoding movie...")


# REMOVE RESULTING FILES --------------------------------------------------

## This will only work if testing on a Mac
system("rm animation.mp4")
