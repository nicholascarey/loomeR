#' @title Determine the Apparent Looming Threshold (ALT) for a given response
#'   frame
#'
#' @description `get_alt` returns the Apparent Looming Threshold (ALT), the rate
#'   of change of the visual angle (alpha, or **a**) of a looming shape
#'   (**da/dt** in radians/s), at a specified frame of the animation. Typically
#'   this is the 'response frame' - the frame at which a specimen responds to
#'   the stimulus.
#'
#'   The model originally used to create the looming animation must be supplied,
#'   along with a specified `response_frame`. The function returns the ALT at
#'   this frame. It also returns the perceived speed and perceived distance of
#'   the looming shape at this frame, as specified by the original model.
#'
#'   The function also allows the results to be 'corrected' in two ways:
#'
#'   - Different viewing distance: If the observing specimen has moved, or is
#'   otherwise at a different distance from the screen as that specified in the
#'   original model, this will affect the perceived ALT, as well as perceived
#'   distance and speed. To account for this, a `new_distance` can be specified,
#'   and the function will correct the ALT for the new viewing distance, as well
#'   as calculate the new perceived speed and distance.
#'
#'   - Visual response latency: The function also allows a visual response
#'   latency to be applied (`latency`, in s). Typically, there is a lag between
#'   an animal responding (voluntarily or involuntarily) to a stimulus, and the
#'   signal to move reaching their musculature. If this latency value is known
#'   or has been quantified, it can be entered as `latency` in seconds and the
#'   results will be returned from the closest matching frame to the
#'   `response_frame` minus this duration (see Details).
#'
#'
#' @details Note, that since **da/dt** is a derivative, its value lies *between*
#'   frames. The function returns the **da/dt** value (rate of change in the
#'   viewing angle) between the given `response_frame` and the previous frame.
#'   If, for whatever reason, you want the **da/dt** between the
#'   `response_frame` and the next frame, simply add 1 to the response frame.
#'
#'   Latency: Latency is applied internally by adjusting the response frame. The
#'   frame rate multiplied by the latency gives the number of frames 'backwards'
#'   from the entered `response_frame` the function goes to extract the results.
#'   In the event the number of frames backwards is not an integer, this is
#'   rounded. For example, with a 60 fps animation and 0.06s latency, the
#'   function would look to go back 3.6 frames; this is rounded to 4.
#'
#'   Diameter model: Note that for a [diameter_model()], the ALT (i.e. **da/dt**
#'   at a particular frame) can be extracted given a viewing distance, but *not*
#'   a perceived distance and speed. This is because the hypothetical size of
#'   the attacker was never specified in creating the model. While the viewing
#'   angle (**a**) and its derivative (**da/dt**) can be calculated, the
#'   perceived distance and/or speed cannot; a small object on screen expanding
#'   rapidly could represent a very small object moving slowly at a close
#'   distance, or a very large object moving rapidly at a far distance. Both of
#'   these can produce an identical **da/dt**, but without a size being
#'   specified the speed and distance cannot be determined. Of course,
#'   expressing the ALT as a **da/dt** value is designed to negate this exact
#'   issue, by focussing purely on the rate of change of the viewing angle. If
#'   these perceived speed and distance parameters may be important to your
#'   study however, the model should be created in [constant_speed_model()] or
#'   [variable_speed_model()]. Note, [diameter_model()] is intended to produce
#'   simple animations purely to induce a response where the precise parameters
#'   are not that important.
#'
#'
#'
#' @seealso [constant_speed_model()], [variable_speed_model()],
#'   [diameter_model()], [looming_animation()]
#'
#' @param x numeric. Object of class `constant_speed_model`,
#'   `variable_speed_model`, or `diameter_model`.
#' @param response_frame integer. The frame at which you want to determine the
#'   ALT.
#' @param new_distance numeric. Distance in cm the specimen is from the screen,
#'   if this is different from that used to create the model.
#' @param latency numeric. Visual response latency in seconds.
#'
#' @return The function returns a `list` object of class `get_alt`. The first
#'   value in the output object (`$alt`) is the ALT in rad/s at the response
#'   frame (with latency correction if entered). It also includes the original
#'   looming animation model (`$original_model`), and an adjusted model for any
#'   `new_distance`  (`$adjusted_model`). It also returns perceived speed and
#'   distance (`$speed_perceived`, `$distance_perceived`) at the response frame
#'   (with latency correction) adjusted for a new viewing distance, and also the
#'   original speed and distance in the model at that same frame without this
#'   correction (`$speed_in_model`, `$distance_in_model`). All angular and
#'   **da/dt** results are returned in radians, as is typically used in the
#'   literature. However the output also includes these in degrees with a `_deg`
#'   suffix (e.g. `$alt` vs. `$alt_deg`). All calculated (**a** & **da/dt**) and
#'   adjusted (perceived speed and distance) parameters are available for every
#'   frame in the `$adjusted_model$model` component. Note, that because
#'   **da/dt** is a derivative, the **da/dt** vector returned in
#'   `adjusted_model$model` will be one value shorter than the total number of
#'   frames, and therefore starts with a blank value (i.e. `NA`). During
#'   processing, values of **da/dt** are determined from the previous frame to
#'   the current frame. Therefore a **da/dt** value for a particular frame is
#'   how the angle changed from the previous frame to that frame.
#'
#' @examples
#' ## create looming animation model
#' loom_model <- constant_speed_model(
#'                      screen_distance = 20,
#'                      frame_rate = 60,
#'                      speed = 500,
#'                      attacker_diameter = 50,
#'                      start_distance = 1000)
#'
#' ## Extract the ALT at frame 100
#' get_alt(loom_model,
#'         response_frame = 100)
#'
#' ## Adjust for different viewing distance and apply a response latency
#' get_alt(loom_model,
#'         response_frame = 100,
#'         new_distance = 25,
#'         latency = 0.06)
#'
#' @author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#' @importFrom utils tail
#'
#' @export

get_alt <-

  function(x,
           response_frame = NULL,
           new_distance = NULL,
           latency = 0){


    # Checks ------------------------------------------------------------------

    ## check class
    if(!any(class(x) %in% c("constant_speed_model", "variable_speed_model", "diameter_model")))
      stop("Input must be an object of class 'constant_speed_model', 'variable_speed_model',
           or 'diameter_model'.")

    if(is.null(response_frame))
      stop("A 'response_frame' is required to extract the ALT and associated data.")

    if(response_frame == 1)
      stop("ALT cannot be extracted from the first frame because it is a derivative and is calculated
           between the response_frame and the previous frame.")

    if(response_frame > tail(x$model$frame, 1))
      stop("The 'response_frame' is greater than the last frame of the animation model.")



    # Diameter model ----------------------------------------------------------

    if(inherits(x, "diameter_model")){

      ## check screen_distance not empty
      if(is.null(new_distance))
        stop("Extracting data from 'diameter_model' objects requires a screen viewing distance.
             This should be entered as 'new_distance'.")

      ## save inputs for inclusion in final output
      original_model <- x
      inputs <- list(
        new_distance = new_distance,
        latency = latency,
        response_frame = response_frame
      )

      ## take out df with frames, animation diameters etc
      adjusted_model <- x$model

      ## set exp parameters
      frame_rate <- x$frame_rate
      screen_dist <- new_distance


      ## latency correction
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(frame_rate*latency))

      ## alpha column - visual angle of shape
      adjusted_model$alpha <- 2*(atan((adjusted_model$diam_on_screen/2)/screen_dist))
      adjusted_model$alpha_deg <- rad2deg(adjusted_model$alpha)

      ## da/dt column
      adjusted_model$dadt <- c(NA, diff(adjusted_model$alpha)*frame_rate)
      adjusted_model$dadt_deg <- rad2deg(adjusted_model$dadt)

      ## EXTRACT ALT
      ## from the ADJUSTED FOR LATENCY response frame
      alt <- adjusted_model$dadt[response_frame_adjusted]
      alt_deg <- rad2deg(alt)

      ## organise adjusted model for output
      temp_list <- original_model
      temp_list$model <- adjusted_model
      adjusted_model <- temp_list

      #### OUTPUT

      output <- list(
        alt = alt,
        alt_deg = alt_deg,

        response_frame = response_frame_original,
        response_frame_adjusted = response_frame_adjusted,
        latency_applied = latency,

        distance_perceived = NULL,
        speed_perceived = NULL,
        distance_in_model = NULL,
        speed_in_model = NULL,
        new_distance_applied = inputs$new_distance,

        adjusted_model = adjusted_model,
        original_model = original_model,
        inputs = inputs
      )
    }


    # Constant speed model ----------------------------------------------------

    if(inherits(x, "constant_speed_model")){

      ## save inputs for inclusion in final output
      original_model <- x
      inputs <- list(
        new_distance = new_distance,
        latency = latency,
        response_frame = response_frame
      )


      ## take out df with frames, animation diameters etc
      adjusted_model <- x$model

      ## take out exp parameters
      attacker_diameter <- x$attacker_diameter
      frame_rate <- x$frame_rate

      ## if new distance entered use it
      ifelse(is.null(new_distance),
             screen_dist <- x$screen_distance,
             screen_dist <- new_distance)

      ## latency correction
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(frame_rate*latency))

      ## alpha column - visual angle of shape
      adjusted_model$alpha <- 2*(atan((adjusted_model$diam_on_screen/2)/screen_dist))
      adjusted_model$alpha_deg <- rad2deg(adjusted_model$alpha)

      ## da/dt column
      adjusted_model$dadt <- c(NA, diff(adjusted_model$alpha)*frame_rate)
      adjusted_model$dadt_deg <- rad2deg(adjusted_model$dadt)

      ## perceived distance
      adjusted_model$distance_perceived <-
        cos(adjusted_model$alpha/2)*
        (attacker_diameter/2)/(sin((adjusted_model$alpha/2)))

      ## perceived speed
      ## = perceived distance change per s
      adjusted_model$speed_perceived <-
        -1*c(NA, diff(adjusted_model$distance_perceived)*frame_rate)

      ## EXTRACT ALT
      ## from the ADJUSTED FOR LATENCY response frame
      alt <- adjusted_model$dadt[response_frame_adjusted]
      alt_deg <- rad2deg(alt)

      ## get three metrics at the ADJUSTED FOR LATENCY response frame
      alt_perceived <- alt
      distance_perceived <- adjusted_model$distance_perceived[response_frame_adjusted]
      speed_perceived <- adjusted_model$speed_perceived[response_frame_adjusted]

      ## get dist and speed of model at response frame
      distance_in_model <- adjusted_model$distance[response_frame_adjusted]
      speed_in_model <- original_model$speed


      ## organise adjusted model for output
      temp_list <- original_model
      temp_list$model <- adjusted_model
      adjusted_model <- temp_list


      #### OUTPUT

      output <- list(
        alt = alt,
        alt_deg = alt_deg,

        response_frame = response_frame_original,
        latency_applied = latency,
        response_frame_adjusted = response_frame_adjusted,

        distance_perceived = distance_perceived,
        speed_perceived = speed_perceived,
        distance_in_model = distance_in_model,
        speed_in_model = speed_in_model,
        new_distance_applied = inputs$new_distance,

        original_model = original_model,
        adjusted_model = adjusted_model,
        inputs = inputs
      )
    }


    # Variable speed model ----------------------------------------------------

    if(inherits(x, "variable_speed_model")){

      ## save inputs for inclusion in final output
      original_model <- x
      inputs <- list(
        new_distance = new_distance,
        latency = latency,
        response_frame = response_frame
      )


      ## take out df with frames, animation diameters etc
      adjusted_model <- x$model

      ## take out exp parameters
      attacker_diameter <- x$attacker_diameter
      frame_rate <- x$frame_rate

      ## if new distance entered use it
      ifelse(is.null(new_distance),
             screen_dist <- x$screen_distance,
             screen_dist <- new_distance)

      ## latency correction
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(frame_rate*latency))

      ## alpha column - visual angle of shape
      adjusted_model$alpha <- 2*(atan((adjusted_model$diam_on_screen/2)/screen_dist))
      adjusted_model$alpha_deg <- rad2deg(adjusted_model$alpha)

      ## da/dt column
      adjusted_model$dadt <- c(NA, diff(adjusted_model$alpha)*frame_rate)
      adjusted_model$dadt_deg <- rad2deg(adjusted_model$dadt)

      ## perceived distance
      adjusted_model$distance_perceived <-
        cos(adjusted_model$alpha/2)*
        (attacker_diameter/2)/(sin((adjusted_model$alpha/2)))

      ## perceived speed
      ## = perceived distance change per s
      adjusted_model$speed_perceived <-
        -1*c(NA, diff(adjusted_model$distance_perceived)*frame_rate)

      ## EXTRACT ALT
      ## from the ADJUSTED FOR LATENCY response frame
      alt <- adjusted_model$dadt[response_frame_adjusted]
      alt_deg <- rad2deg(alt)

      ## get three metrics at the ADJUSTED FOR LATENCY response frame
      alt_perceived <- alt
      distance_perceived <- adjusted_model$distance_perceived[response_frame_adjusted]
      speed_perceived <- adjusted_model$speed_perceived[response_frame_adjusted]

      ## get dist and speed of model at response frame
      distance_in_model <- adjusted_model$distance[response_frame_adjusted]
      ## this is basically only difference to constant speed model - getting
      ## speed at frame rather than the constant speed in model
      speed_in_model <- original_model$speed[response_frame_adjusted]


      ## organise adjusted model for output
      temp_list <- original_model
      temp_list$model <- adjusted_model
      adjusted_model <- temp_list


      #### OUTPUT

      output <- list(
        alt = alt,
        alt_deg = alt_deg,

        response_frame = response_frame_original,
        latency_applied = latency,
        response_frame_adjusted = response_frame_adjusted,

        distance_perceived = distance_perceived,
        speed_perceived = speed_perceived,
        distance_in_model = distance_in_model,
        speed_in_model = speed_in_model,
        new_distance_applied = inputs$new_distance,

        original_model = original_model,
        adjusted_model = adjusted_model,
        inputs = inputs
      )
    }


    ## Assign class
    class(output) <- "get_alt"

    ## Return output
    return(output)

  } #END


