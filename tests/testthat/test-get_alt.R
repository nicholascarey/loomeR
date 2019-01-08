
# test --------------------------------------------------------------------

## test it runs with diameter_model
expect_output(str(get_alt(diameter_model(),
                      response_frame = 10,
                      new_distance = 20)),
              "List of 13")

## test it runs with constant speed model
expect_output(str(get_alt(constant_speed_model(),
                      response_frame = 10)),
              "List of 13")

## test it runs with constant speed model
expect_output(str(get_alt(variable_speed_model(x = c(1:100)),
                      response_frame = 10)),
              "List of 13")



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
