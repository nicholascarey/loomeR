#' @title Diameter Model
#'
#' @description Creates a simple model for making a looming animation by setting
#'   start and end screen diameters and total duration
#'
#' @details Creates a simple expansion model for use in
#'   \code{looming_animation}, from a start and end diameter, and a total
#'   duration. Expansion of the simulation can be set in two ways. In the
#'   default, \code{constant_speed}, the function models the expansion of the
#'   simulated oncoming object as if it were approaching at a constant speed.
#'   Because of visual foreshortening, this results in a simulation that expands
#'   progressively more rapidly as the animation progresses. If \code{=
#'   constant_diameter}, the function instead imposes a constant increase in
#'   diameter, i.e. a simulation that expands by the same amount in diameter in
#'   each frame. This simulation represents an oncoming object that is starting
#'   off at high speed, but slowing down as it gets closer to the target.
#'
#'   Inputs should be in \code{cm}, duration in seconds (s), and frame rate in
#'   \code{Hz} or \code{Frames per Second}.
#'
#' @seealso \code{\link{looming_animation}},
#'   \code{\link{looming_animation_calib}},  \code{\link{variable_speed_model}}
#'   \code{\link{constant_speed_model}},
#'
#' @param start_diameter numeric. Diameter (cm) you want the animation to start
#'   at.
#' @param end_diameter numeric. Diameter (cm) you want the animation to end at.
#'   If you want the animation to fill the screen, this should be slightly
#'   larger than the physical screen size.
#' @param duration numeric. Total duration (s) you want the animation to be.
#' @param frame_rate numeric. Frames per second (Hz) you want the resulting
#'   animation to be played at.
#' @param expansion string. \code{constant_speed} or \code{constant_diameter}.
#'   Sets if the expansion of the simulation is modelled as a constant speed or
#'   constant increase in diameter (see Details).
#'
#' @return List object containing the input parameters and a model with the
#'   resulting diameter for each frame in the animation.
#'
#' @examples
#' loom_model <- diameter_model(
#'                      start_diameter = 2,
#'                      end_diameter = 50,
#'                      duration = 3,
#'                      frame_rate = 60,
#'                      expansion = "constant_speed")
#'
#' @author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#' @export

diameter_model <-

  function(
    start_diameter = 3,
    end_diameter = 50,
    duration = 3,
    frame_rate = 60,
    expansion = "constant_speed"){

    ## check expansion for typos
    ## check class
    if(!any(expansion %in% c("constant_speed", "constant_diameter")))
      stop("expansion operator not set correctly: must be 'constant_speed' or 'constant_diameter'")

    ## IF CONSTANT SPEED
    if(expansion == "constant_speed"){
    ## calculate total number of frames
    ## ceiling to round up, otherwise results df will be a frame short if total frames ends up a decimal
    total_frames <- ceiling(duration*frame_rate)

    ## Distances - these are arbitrary/proportional
    ## start distance
    start_dist <- 1/start_diameter
    ## end distance
    end_dist <- 1/end_diameter

    ## calculate distance covered each frame
    ## -1 because we are interested in what happens between frames
    distance_per_frame <- (start_dist-end_dist)/(total_frames-1)

    ## build up data frame
    ## list of frames
    results_df <- data.frame(frame = seq(1,total_frames,1))

    ## add time
    results_df$time <- results_df$frame/frame_rate

    ## add hypothetical predator distance
    ## start with start distance
    ## then add distance per frame for each frame
    ## minus 1 because we want first entry to be start_dist, so no need to add to it
    results_df$distance <- start_dist-((results_df$frame-1) * distance_per_frame)

    ## add screen diameter of model for each frame
    results_df$diam_on_screen <- 1/results_df$distance

    ## remove distance column
    results_df <- results_df[,c(1,2,4)]
    }


  ## IF CONSTANT DIAMETER
  if(expansion == "constant_diameter"){
  total_frames <- ceiling(duration*frame_rate)
  diam_per_frame <- (end_diameter - start_diameter)/(total_frames-1)
  results_df <- data.frame(frame = seq(1,total_frames,1))
  results_df$time <- results_df$frame/frame_rate
  ## add diameter change to start distance for each row
  results_df$diam_on_screen <-
    apply(results_df, 1, function(x) start_diameter + (x[1]-1)*diam_per_frame)
  }


    ## assemble output list object
    output <- list(
      model = results_df,
      start_diameter = start_diameter,
      end_diameter = end_diameter,
      duration = duration,
      frame_rate = frame_rate,
      expansion = expansion
    )

    class(output) <- "diameter_model"

    return(output)
  }



#' Remove last n values from a vector
#'
#' @details
#' Removes the specified nunmber of values/entries from the end of a vector
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
vect_rm_end <- function (x, n = 1) {

  if(n >= length(x))
    stop("Length of value is greater than or equal to length of vector")

  x <- x[1:(length(x)-n)]
  return(x)
}
