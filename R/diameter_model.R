#' @title Diameter Model
#'
#' @description Creates a simple model for making a looming animation by setting
#'   starting screen diameter and total duration
#'
#' @details Exapnsion of the simulation can be set in two ways. If
#'   \code{constant}, the function models a constant speed of the attacker.
#'   Because of visual foreshortening, this results in a simulation that expands
#'   progressively more rapidly towards the end of the animation. If \code{=
#'   diameter}, the function instead imposes a constant increase in diameter,
#'   i.e. a simulation that expands by the same amount in diameter in each
#'   frame. This simulation represents an oncoming object that actually slows
#'   down as it gets closer to the target.
#'
#'   Inputs should be in \code{cm}, speed in \code{cm/s}, and frame rate in
#'   \code{Hz} or \code{Frames per Second}.
#'
#' @seealso \code{\link{looming_animation}},
#'   \code{\link{looming_animation_calib}},  \code{\link{variable_speed_model}}
#'
#' @param start_diameter numeric. Diameter (cm) you want the animation to start
#'   at.
#' @param end_diameter numeric. Diameter (cm) you want the animation to end at.
#'   Should be slightly larger than the screen size if you want it to fill the
#'   screen in the final frames.
#' @param duration numeric. Total duraion (s) you want the animation to be.
#' @param anim_frame_rate numeric. Frames per second (Hz) you want the resulting
#'   animation to be.
#' @param expansion string. Sets if the expansion of the simulation is modelled
#'   as a constant speed or constant increase in diameter (see Details).
#'
#' @return List object containing the input parameters and the resulting
#'   diameter for each frame in the animation.
#'
#' @examples
#' loom_model <- diameter_model(
#'                      start_diameter = 5,
#'                      end_diameter = 50,
#'                      duration = 5,
#'                      anim_frame_rate = 60,
#'                      expansion = "constant")
#'
#' @author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#' @export

diameter_model <-

  function(
    start_diameter = 5,
    end_diameter = 50,
    duration = 5,
    anim_frame_rate = 60,
    expansion = "constant"){

    ## IF CONSTANT SPEED

    ## calculate total number of frames
    ## ceiling to round up, otherwise results df will be a frame short if total frames ends up a decimal
    total_frames <- ceiling(duration*anim_frame_rate)

    ## Arbitrary screen dist and attacker diam
    ## Values of these do not affect the final calculated diameters
    screen_dist <- 20
    att_diam <- 50

    ## start distance
    start_dist <- (screen_dist*att_diam)/start_diameter
    ## end distance
    end_dist <- (screen_dist*att_diam)/end_diameter

    ## calculate distance covered each frame
    ## rounding it because of ridiculously long results in later calcs
    distance_per_frame <- round((start_dist-end_dist)/total_frames, 3)

    ## build up data frame
    ## list of frames
    results_df <- data.frame(frame = seq(1,total_frames,1))

    ## add time
    results_df$time <- results_df$frame/anim_frame_rate

    ## add hypothetical predator distance
    results_df$distance <- start_dist-((results_df$frame) * distance_per_frame)

    ## add screen diameter of model for each frame
    results_df$diam_on_screen <- (att_diam*screen_dist)/results_df$distance

    ## assemble output list object
    output <- list(
      model = results_df,
      start_diameter = 5,
      end_diameter = 50,
      duration = 5,
      anim_frame_rate = 60,
      expansion = "constant"
    )

    class(output) <- "diameter_model"

    return(output)
  }
