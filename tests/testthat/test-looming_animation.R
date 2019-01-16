
# test --------------------------------------------------------------------

## test does not accept df
df <- data.frame(c(1:3), c(4:6))
expect_error(looming_animation(df))

# test --------------------------------------------------------------------

## test accepts "diameter_model" class
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_message(looming_animation(mod), "diameter_model detected.")

# test --------------------------------------------------------------------

## test accepts "variable_speed_model" class
mod <- variable_speed_model(x = rep(1, 20))
expect_message(looming_animation(mod), "variable_speed_model detected.")

# test --------------------------------------------------------------------

## test accepts "constant_speed_model" class
mod <- constant_speed_model(frame_rate = 30,
                            speed = 500,
                            start_distance = 500)

expect_message(looming_animation(mod), "constant_speed_model detected.")

