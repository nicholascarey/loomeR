
# test --------------------------------------------------------------------

## test list is created
expect_output(str(constant_speed_model()), "List of 6")

# test --------------------------------------------------------------------

## test class
model <- constant_speed_model()
expect_is(model, "constant_speed_model")

# test --------------------------------------------------------------------

## test works with default values
# create model
mod <- constant_speed_model()

# test specific values for default inputs
expect_equal(nrow(mod$model), 121)
expect_equal(round(mod$model$distance[120], 2), 8.33)
expect_equal(mod$model$time[121], 2)



