#' @title Determine the Apparent Looming Threshold (ALT) for a particular
#'   response frame
#'
#' @description \code{get_alt} gets the Apparent Looming Threshold (ALT),
#'   the rate of change of the visual angle of the looming shape (da/dt in
#'   radians/s) at a particlar frame. Typically this is the frame a specimen
#'   responds to the stimulus, or the response taking into account a delay due
#'   to response latency. It also determines the perceived speed and perceived
#'   distance of the looming shape at this frame. It also allows the extracted
#'   parameters to be 'corrected' in two ways. If the observing specimen has
#'   moved, and so is at a different distance from the screen as specified in
#'   the original model, it will perceive a different distance, speed and ALT.
#'   This function allows the perceived parameters to be adjusted by specifying
#'   a \code{new_distance}. The function also allows a response latency to be
#'   applied (\code{latency}). Typically, there is a lag between an animal
#'   responding or "deciding" to respond to a stimulus, and this signal reaching
#'   their musculature.
#'
#' @details Gets the ALT, perceived speed and perceived distance of a specimen
#'
#'   Since da/dt is a derivative, its value lies between frames. The function
#'   uses the value between the response frame and the next.
#'
#'   Latency: Latency is applied internally by adjusting the response frame. The
#'   frame rate multiplied by the latency gives the number of frames 'back' from
#'   the entered \code{response_frame} the function goes to extract the
#'   parameters. In the event the number of frames backwards is a decimal, this
#'   is rounded to the nearest integer. For example, with 60 fps video and 0.06s
#'   latency, the function would seek to go back 3.6 frames. Instead, this is
#'   rounded to 4.
#'
#'   Diameter model: Note that for a diameter model, the dadt/ALT can be
#'   extracted (if a viewing distance is supplied), but *not* perceived distance
#'   and speed. This is because the size of the attacker was never specified in
#'   creating the model. While the viewing angle (alpha) can be calculated, and
#'   thus the da/dt, the perceived distance and/or speed cannot. A small object
#'   on screen expanding rapidly could represent a very small object moving
#'   slowly at a close distance, or a very large object moving rapidly at a far
#'   distance. Both of these can produce an identical da/dt, but without a size
#'   being specified the speed and distance cannot be determined. Expressing the
#'   ALT as a da/dt value is designed to negate this issue, by focussing purely
#'   on the rate of change of the viewing angle. If these parameters may be
#'   important to your study however, the model should be created in
#'   \code{\link{constant_speed_model}} or \code{\link{variable_speed_model}}.
#'   Note, \code{\link{diameter_model}} is intended to produce simple animations
#'   purely to induce response, where the precise parameters are not important.
#'
#'
#'
#' @seealso \code{\link{looming_animation}}, \code{\link{???}}
#'
#' @param x numeric. Object of class
#' @param response_frame integer. The frame of the animation at which the
#'   subject responds, or the frame from which you want to extract the ALT and
#'   other parameters.
#' @param new_distance numeric. The distance in cm the specimen is from screen,
#'   if this is different to that used to create the model.
#' @param latency numeric. Visual response latency in seconds.
#'
#' @return List object of class \code{get_alt}
#'
#' @examples
#' get_alt(x)
#'
#' @author Nicholas Carey - \link{nicholascarey@gmail.com}
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
      stop("Input must be an object of class 'constant_speed_model', 'variable_speed_model', or 'diameter_model'.")

    if(is.null(response_frame))
      stop("A 'response_frame' is required to extract the ALT and associated data.")

    if(response_frame > tail(x$model$frame, 1))
      stop("The 'response_frame' is greater than the last frame of the animation model.")



# Diameter model ----------------------------------------------------------

    if(class(x) == "diameter_model"){

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
      anim_frame_rate <- x$anim_frame_rate
      screen_dist <- new_distance


      ## latency correction
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(anim_frame_rate*latency))

      ## alpha column - visual angle of shape
      adjusted_model$alpha <- 2*(atan((adjusted_model$diam_on_screen/2)/screen_dist))
      adjusted_model$alpha_deg <- rad2deg(adjusted_model$alpha)

      ## da/dt column
      adjusted_model$dadt <- c(NA, diff(adjusted_model$alpha)*anim_frame_rate)
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

    if(class(x) == "constant_speed_model"){

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
      anim_frame_rate <- x$anim_frame_rate

      ## if new distance entered use it
      ifelse(is.null(new_distance),
             screen_dist <- x$screen_distance,
             screen_dist <- new_distance)

      ## latency correction
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(anim_frame_rate*latency))

      ## alpha column - visual angle of shape
      adjusted_model$alpha <- 2*(atan((adjusted_model$diam_on_screen/2)/screen_dist))
      adjusted_model$alpha_deg <- rad2deg(adjusted_model$alpha)

      ## da/dt column
      adjusted_model$dadt <- c(NA, diff(adjusted_model$alpha)*anim_frame_rate)
      adjusted_model$dadt_deg <- rad2deg(adjusted_model$dadt)

          ## perceived distance
          adjusted_model$distance_perceived <-
            cos(adjusted_model$alpha/2)*
            (attacker_diameter/2)/(sin((adjusted_model$alpha/2)))

          ## perceived speed
          ## = perceived distance change per s
          adjusted_model$speed_perceived <-
            -1*c(NA, diff(adjusted_model$distance_perceived)*anim_frame_rate)

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
        comparison_model =
        inputs = inputs
      )
      }


# Variable speed model ----------------------------------------------------



    #### VARIABLE SPEED MODELS ####
    ## note here we use the anim_model

    else if(class(x) == "variable_speed_model"){

      # variable_speed_model <-
      #     x, #speed profile - single vector of speeds in same Hz as anim_frame_rate
      #     y, #mouth open profile - 4 column dataframe of upper and lowwer jaw X and Z
      #     screen_distance = 16,
      #     anim_frame_rate = 60,
      #     attacker_diameter = 250.6690354,
      #     start_distance = 2443.4985,
      #     max_girth = 441, #distance behind mouth of max girth
      #     mouth_open = 622) #what frame in SAME Hz as frame rate does the mouth open occur?
      #   {

      ## save inputs for inclusion in final output
      original_model <- x
      inputs <- list(
        new_distance = new_distance,
        latency = latency,
        response_frame = response_frame
      )

      ## take out df with frames, animation diameters etc
      adjusted_model <- x$anim_model

      ## take out exp parameters
      attacker_diameter <- x$inputs$attacker_diameter
      anim_frame_rate <- x$inputs$anim_frame_rate

      ## latency correction
      ## save original
      ## modify response frame by frame rate*latency
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(anim_frame_rate*latency))

      #### RECREATE EXCEL FILE - i.e. ADJUSTMENT COLUMNS ####
      ## i.e. perceived parameters for new distance to screen
      ## create new alfa_perceived column
      adjusted_model$alfa_perceived <- 2*(rad2deg(atan((adjusted_model$diam_on_screen/2)/new_distance)))

      ## create new perceived distance column
      adjusted_model$distance_perceived <- cos(
        deg2rad(adjusted_model$alfa_perceived/2))*
        (attacker_diameter/2)/(sin(deg2rad(adjusted_model$alfa_perceived/2)))

      ## radians_perceived (of alfa_perceived) column
      adjusted_model$radians_perceived <- deg2rad(adjusted_model$alfa_perceived)

      ## da/dt column
      adjusted_model$dadt_perceived <- c(0, diff(adjusted_model$radians_perceived)*anim_frame_rate)

      ## perceived speed
      ## perceived distance change per s
      adjusted_model$speed_perceived <- -1*c(0, diff(adjusted_model$distance_perceived)*anim_frame_rate)

      ## RESULTS
      ## get three metrics at the ADJUSTED FOR LATENCY response frame
      dadt_perceived <- adjusted_model$dadt_perceived[response_frame_adjusted]
      distance_perceived <- adjusted_model$distance_perceived[response_frame_adjusted]
      speed_perceived <- adjusted_model$speed_perceived[response_frame_adjusted]

      ## get dist and speed of model at response frame
      distance_model_max_girth <- adjusted_model$distance_max_girth[response_frame_adjusted]
      speed_model <- adjusted_model$speed[response_frame_adjusted]


      #### OUTPUT

      output <- list(
        dadt_perceived = dadt_perceived,
        distance_perceived = distance_perceived,
        speed_perceived = speed_perceived,

        response_frame_adjusted = response_frame_adjusted,
        latency_applied = latency,
        response_frame_original = response_frame_original,

        distance_model_max_girth = distance_model_max_girth,
        speed_model = speed_model,

        adjusted_model = adjusted_model,
        original_model = original_model,
        inputs = inputs
      )}

    ## Assign class
    class(output) <- "get_alt"

    ## Return output
    return(output)

  } #END


#' @export
print.get_alt <- function(x, ...) {
  cat("\n")
  cat("Extraction complete. \n \n")
  cat("Using inputs: \n")
  cat(glue::glue("Response Frame:            ",
                 {x$response_frame}))
  cat("\n")
  cat(glue::glue("Response Frame Adjusted:   ",
                 {x$response_frame_adjusted}))
  cat("\n")
  cat(glue::glue("Latency Applied:                   ",
                 {x$latency_applied},
                 "s"))
  cat("\n")
  cat(glue::glue("New Screen Distance:       ",
                 {x$inputs$new_distance},
                 "cm"))
  cat(" \n \n")
  cat("The Apparent Looming Threshold is: \n")
  cat(glue::glue("ALT: ",
                 {round(x$alt, 4)},
                 " radians/sec"))
}


#' Convert radians to degrees
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
deg2rad <- function(deg) {(deg * pi) / (180)}

#' Convert degrees to radians
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
rad2deg <- function(rad){(rad * 180) / (pi)}



