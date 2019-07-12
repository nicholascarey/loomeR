skip_on_cran()

# test --------------------------------------------------------------------

## test it runs with diameter_model
expect_output(str(get_alt(diameter_model(),
                      response_frame = 10,
                      new_distance = 20)),
              "List of 13")

# test --------------------------------------------------------------------
## test it runs with constant speed model
expect_output(str(get_alt(constant_speed_model(),
                      response_frame = 10)),
              "List of 13")

# test --------------------------------------------------------------------

## test it runs with constant speed model
expect_output(str(get_alt(variable_speed_model(x = c(1:100)),
                      response_frame = 10)),
              "List of 13")


# test --------------------------------------------------------------------

## test it stops with wrong classes
lst <- list(c(1:10), c(11:20))
expect_error(get_alt(lst), "Input must be an object of class 'constant_speed_model', 'variable_speed_model',
           or 'diameter_model'.")

# test --------------------------------------------------------------------

## test it stops with missing response_frame
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_error(get_alt(mod, response_frame = NULL), "A 'response_frame' is required to extract the ALT and associated data.")


# test --------------------------------------------------------------------

## test it stops with response_frame = 1
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_error(get_alt(mod, response_frame = 1), "ALT cannot be extracted from the first frame because it is a derivative and is calculated
           between the response_frame and the previous frame.")

# test --------------------------------------------------------------------

## test it stops if response_frame out of range
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_error(get_alt(mod, response_frame = 31), "The 'response_frame' is greater than the last frame of the animation model.")


# test --------------------------------------------------------------------

## test it stops if diameter_model and no new_distance entered
mod <- diameter_model(start_diameter = 10,
                      end_diameter = 9.5,
                      duration = 1,
                      frame_rate = 30)

expect_error(get_alt(mod,
                     response_frame = 20,
                     new_distance = NULL),
             "Extracting data from 'diameter_model' objects requires a screen viewing distance.
             This should be entered as 'new_distance'.")



# test --------------------------------------------------------------------

## test class
result <- get_alt(variable_speed_model(x = c(1:100)),
                 response_frame = 10)

expect_is(result, "get_alt")



# test --------------------------------------------------------------------

## test can print result
result <- get_alt(variable_speed_model(x = c(1:100)),
                  response_frame = 10)

expect_output(print(result))
