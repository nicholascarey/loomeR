
# test --------------------------------------------------------------------

## test list is created
expect_output(str(diameter_model()), "List of 6")

# test --------------------------------------------------------------------

## test class
model <- diameter_model()
expect_is(model, "diameter_model")

# test --------------------------------------------------------------------

## test number of frames generated matches duration at frame rate
# random duration and frame rate
d <- round(runif(1, min=0, max=20), 2)
f <- floor(runif(1, min = 12, max = 120))
# create model
mod <- diameter_model(duration = d,
                      frame_rate = f)
# check number of frames output equals duration times frame rate rounded up
expect_equal(nrow(mod$model),
             ceiling(mod$duration*mod$frame_rate))



