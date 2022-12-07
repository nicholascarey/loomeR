# library(testthat)

capture.output({  ## stops printing outputs on assigning

  # test --------------------------------------------------------------------

  test_that("does not accept df", {
    skip_on_ci()
    df <- data.frame(c(1:3), c(4:6))
    expect_error(looming_animation(df),
                 "Input must be an object of class 'constant_speed_model', 'variable_speed_model', or 'diameter_model'")
  })

  # test --------------------------------------------------------------------

  test_that("accepts 'diameter_model' class",{
    skip_on_ci()
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)
    expect_message(looming_animation(mod),
                   "diameter_model detected.")
  })

  # test --------------------------------------------------------------------

  test_that("accepts 'variable_speed_model' class", {
    skip_on_ci()
    mod <- variable_speed_model(x = rep(1, 20))
    expect_message(looming_animation(mod),
                   "variable_speed_model detected.")
  })

  test_that("accepts 'constant_speed_model' class", {
    skip_on_ci()
    mod <- constant_speed_model(frame_rate = 30,
                                speed = 500,
                                start_distance = 500)

    expect_message(looming_animation(mod,
                                     frame_number = TRUE,
                                     frame_number_position = "bl"),
                   "constant_speed_model detected.")
  })

  test_that("exports data", {
    skip_on_ci()
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)
    looming_animation(mod,
                      save_data = TRUE,
                      frame_number = TRUE)

    test_path("ANIM_from_x_30fps_1280x1024.csv")
    # REMOVE RESULTING FILE
    ## This will only work if testing on a Mac
    system("rm ANIM_from_x_30fps_1280x1024.csv")
  })

  x <- diameter_model(start_diameter = 10,
                              end_diameter = 9.5,
                              duration = 1,
                              frame_rate = 29.97)

  test_that("padding works", {
    skip_on_ci()
    expect_error(looming_animation(x, pad = 1),
                 NA)
  })

  test_that("padding blank works", {
    skip_on_ci()
    expect_error(looming_animation(x, pad = 1, pad_blank = TRUE),
                 NA)
  })


  test_that("dots", {
    skip_on_ci()
    expect_error(looming_animation(x, dots = TRUE, dots_position = "tl"),
                 NA)
    expect_error(looming_animation(x, dots = TRUE, dots_position = "br"),
                 NA)
  })

  test_that("null correction", {
    skip_on_ci()
    expect_error(looming_animation(x, correction = NULL),
                 NA)
  })

  test_that("odd numbered resolution is modified - width", {
    skip_on_ci()
    expect_message(looming_animation(x,
                                     width = 1279,
                                     height = 1023),
                   "Screen `width` cannot be an odd number.")
  })


  test_that("odd numbered resolution is modified - height", {
    skip_on_ci()
    expect_message(looming_animation(x,
                                     width = 1279,
                                     height = 1023),
                   "Screen `height` cannot be an odd number.")
  })

  test_that("system command runs", {
    skip_on_ci()
    mod <- diameter_model(start_diameter = 10,
                          end_diameter = 9.5,
                          duration = 1,
                          frame_rate = 30)

    expect_message(looming_animation(mod,
                                     frame_number = TRUE,
                                     frame_number_position = "bl"),
                   "Encoding movie...")
  })

  ## This will only work if testing on a Mac
  system("rm animation.mp4")


}) ## turns printing back on
