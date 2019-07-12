#' @title Variable Speed Model
#'
#' @description Given a viewing distance, this function calculates the on-screen
#'   diameters of a hypothetical object of defined size approaching at a
#'   user-supplied variable speed profile. This allows a looming animation with
#'   precise parameters to be created.
#'
#' @details Calculates the screen diameters for a modelled object of specified
#'   size approaching at a variable speed. The variable speed must be supplied
#'   as a vector of speeds (operator \code{x}) in cm/s at the same frequency
#'   (i.e. same Hz) as the entered \code{frame_rate}, which is the frame
#'   rate the resulting animation created from this model will be played back
#'   at. If the speed profile is in a different frequency than common video
#'   frame rates (e.g, 24, 30, 60 fps) it is recommended to interpolate or
#'   subsample it to be so. I can't guarantee all playback software will
#'   correctly play videos encoded at odd frame rates, though you are free to
#'   try.
#'
#'   The output list object can be used to create a looming animation in
#'   \code{\link{looming_animation}}. Unlike \code{constant_speed_model}, no
#'   \code{starting_distance} operator is required: it is assumed the final
#'   value in the \code{speeds} vector occurs at the point of zero distance
#'   between the attacker and observing target. The function uses the
#'   \code{speeds} to back-calculate distances from this point to the starting
#'   entry in \code{speeds}. These distances and the \code{attacker_diameter}
#'   are used to calculate a screen diameter for the simulation in each frame.
#'   Obviously, the length of \code{speeds} and the frequency determines the
#'   total length of the resulting animation.
#'
#'   Required inputs include the intended frame rate at which the subsequent
#'   animation will be played, and distance from the screen at which the
#'   observing specimen will be located. These details are important in
#'   experiments where you want to precisely determine at what time, perceived
#'   distance, or perceived velocity of an attack an escape response occurs.
#'   Note: if the specimen is closer or further away than the specified screen
#'   distance, the animation will be perceived as a different distance and a
#'   different velocity.
#'
#'   If you need to create a looming animation simply to elicit a response, and
#'   are not concerned with the precise details, see
#'   \code{\link{diameter_model}}.
#'
#'   Inputs should be in \code{cm}, speeds in \code{cm/s}, and frame rate in
#'   \code{Hz} or \code{Frames per Second}.
#'
#' @seealso \code{\link{looming_animation}},
#'   \code{\link{looming_animation_calib}}, \code{\link{constant_speed_model}}
#'   \code{\link{diameter_model}}
#'
#' @param x numeric. Vector of speeds (cm/s) of the hypothetical approaching
#'   attacker at the same frequency (Hz) as the \code{frame_rate}. Length
#'   of the vector will thus determine total duration of the resulting
#'   animation.
#' @param screen_distance numeric. Distance (cm) from the playback screen to
#'   your specimen.
#' @param frame_rate numeric. Frames per second (Hz) you want the resulting
#'   animation to be played back at.
#' @param attacker_diameter numeric. Diameter of the hypothetical approaching
#'   attacker. This affects the size of the simulation in the final frame of the
#'   animation.
#'
#' @return List object containing the input parameters and the resulting
#'   diameter for each frame in the animation.
#'
#' @examples
#' ## Create a speeds vector
#' ## Here we create a vector of speeds of an attacker steadily accelerating from
#' ## nearly stationary (1 cm/s) to 500 cm/s by 1 cm/s per frame
#' x <- seq(1, 500, 1)
#'
#' ## Use the variable speed vector to create the model
#' loom_model <- variable_speed_model(x,
#'                                    screen_distance = 20,
#'                                    frame_rate = 60,
#'                                    attacker_diameter = 50)
#'
#' @author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#' @export

variable_speed_model <-
  function(
    x,
    screen_distance = 20,
    frame_rate = 60,
    attacker_diameter = 50){

    ## check x is a vector
    if(!is.vector(x)){
      stop("Input does not appear to be a vector")
    }

    ## calculate parameters
    total_frames <- length(x)
    total_time <- total_frames/frame_rate
    start_distance <- sum((x/frame_rate))

    ## calculate distance covered each frame at this speed and frame rate
    distance_per_frame <- x/frame_rate

    ## build up data frame
    ## list of frames
    results_df <- data.frame(frame = seq(1,total_frames,1))

    ## add time
    results_df$time <- results_df$frame/frame_rate

    ## add hypothetical predator distance
    results_df$distance <- start_distance-cumsum(distance_per_frame)

    ## Add screen diameter of model for each frame. Need a conditional here. The
    ## speed profile has the consequence of potentially causing an essentially
    ## infinite value on the last frame at high acceleration. Therefore screen
    ## diameter is set to a maximum value of 1000 cm. Unlikely anyone is
    ## simulating anything on a screen above 10m!

    results_df$diam_on_screen <- apply(results_df, 1, function(y)

      if((attacker_diameter*screen_distance)/y[3] < 1000){
        (attacker_diameter*screen_distance)/y[3]
      } else if((attacker_diameter*screen_distance)/y[3] >= 1000){
        1000
      })

    ## assemble output list object
    output <- list(
      model = results_df,
      screen_distance = screen_distance,
      frame_rate = frame_rate,
      speeds = x,
      attacker_diameter = attacker_diameter,
      start_distance = start_distance
    )

    class(output) <- "variable_speed_model"

    return(output)
  }
