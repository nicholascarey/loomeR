
# test --------------------------------------------------------------------

## test it doesn't run without x input
expect_error(variable_speed_model())
expect_error(variable_speed_model(x = NULL))

# test --------------------------------------------------------------------

## test list is created
expect_output(str(variable_speed_model(x = c(1:100))), "List of 6")

# test --------------------------------------------------------------------

## test class
model <- variable_speed_model(x = c(1:100))
expect_is(model, "variable_speed_model")

