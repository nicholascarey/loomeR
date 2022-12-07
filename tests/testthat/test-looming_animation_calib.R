capture.output({  ## stops printing outputs on assigning

  test_that("works with default values", {
    skip_on_ci()
    expect_message(looming_animation_calib(),
                   "Creating calibration animation...")
  })

  test_that("odd numbered resolution is modified - width", {
    skip_on_ci()
    expect_message(looming_animation_calib(width = 1279,
                                           height = 1023),
                   "Screen `width` cannot be an odd number.")
  })

  test_that("odd numbered resolution is modified - height", {
    skip_on_ci()
    expect_message(looming_animation_calib(width = 1279,
                                           height = 1023),
                   "Screen `height` cannot be an odd number.")
  })

  test_that("system command runs", {
    skip_on_ci()
    expect_message(looming_animation_calib(),
                   "Encoding movie...")
  })

  # REMOVE RESULTING FILES --------------------------------------------------

  ## This will only work if testing on a Mac
  system("rm animation_calib.mp4")

}) ## turns printing back on
