capture.output({  ## stops printing outputs on assigning

  # test --------------------------------------------------------------------

  test_that("runs with diameter_model", {
    expect_output(str(get_alt(diameter_model(),
                              response_frame = 10,
                              new_distance = 20)),
                  "List of 13")
  })

  test_that("runs with constant speed model", {
    expect_output(str(get_alt(constant_speed_model(),
                              response_frame = 10)),
                  "List of 13")
  })

  test_that("runs with constant speed model", {
    expect_output(str(get_alt(variable_speed_model(x = c(1:100)),
                              response_frame = 10)),
                  "List of 13")
  })

  test_that("stops with wrong classes", {
    lst <- list(c(1:10), c(11:20))
    expect_error(get_alt(lst),
                 "Input must be an object of class 'constant_speed_model', 'variable_speed_model'")
  })

  test_that("stops with missing response_frame", {
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)

    expect_error(get_alt(mod, response_frame = NULL),
                 "A 'response_frame' is required to extract the ALT and associated data.")
  })

  test_that("tops with response_frame = 1", {
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)

    expect_error(get_alt(mod, response_frame = 1),
                 "ALT cannot be extracted from the first frame")
  })

  test_that("stops if response_frame out of range", {
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)

    expect_error(get_alt(mod, response_frame = 31),
                 "The 'response_frame' is greater than the last frame of the animation model.")
  })

  test_that("stops if diameter_model and no new_distance entered", {
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)

    expect_error(get_alt(mod,
                         response_frame = 20,
                         new_distance = NULL),
                 "Extracting data from 'diameter_model' objects requires a screen viewing distance")
  })

  test_that("class", {
    result <- get_alt(variable_speed_model(x = c(1:100)),
                      response_frame = 10)

    expect_is(result, "get_alt")
  })

  test_that("can print result", {
    result <- get_alt(variable_speed_model(x = c(1:100)),
                      response_frame = 10)

    expect_output(print(result))
  })

}) ## turns printing back on
