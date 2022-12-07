capture.output({  ## stops printing outputs on assigning

  test_that("list is created", {
    expect_output(str(constant_speed_model()),
                  "List of 6")
  })

  test_that("class", {
    model <- constant_speed_model()
    expect_is(model, "constant_speed_model")
  })

  test_that("works with default values", {
    expect_error(constant_speed_model(),
                 NA)
  })

  test_that("specific values for default inputs", {
    mod <- constant_speed_model()
    expect_equal(nrow(mod$model), 120)
    expect_equal(round(mod$model$distance[120], 2), 0)
    expect_equal(mod$model$time[120], 2)
  })

}) ## turns printing back on
