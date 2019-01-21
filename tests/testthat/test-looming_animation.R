
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

## test system command runs
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

skip_on_travis()
expect_message(looming_animation(mod,
                          frame_number = TRUE,
                          frame_number_position = "bl"),
               "Encoding movie...")


# test --------------------------------------------------------------------

## test padding works
x <- loomeR::diameter_model(start_diameter = 10,
                            end_diameter = 9.5,
                            duration = 1,
                            frame_rate = 29.97)

expect_error(looming_animation(x, pad = 1),
                "Something has gone wrong with padding. ") == FALSE





# REMOVE RESULTING FILES --------------------------------------------------

## This will only work if testing on a Mac
system("rm animation.mp4")
