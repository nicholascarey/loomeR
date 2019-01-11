
# test --------------------------------------------------------------------

## test does not accept df
df <- data.frame(c(1:3), c(4:6))
expect_error(looming_animation(df))


