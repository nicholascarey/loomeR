#' @title Determine the Apparent Looming Threshold (ALT) for a particular
#'   response frame
#'
#' @description \code{get_alt} gets the Apparent Looming Threshold (ALT) that is
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
#'
#'
#' @seealso \code{\link{looming_animation}}, \code{\link{???}}
#'
#' @usage get_alt(...)
#'
#' @param x numeric. Object of class
#' @param response_frame integer. The frame of the animation at which the
#'   subject responds, or the frame from which you want to extract the ALT and
#'   other parameters.
#' @param new_distance numeric. The distance in cm the specimen is from screen,
#'   if this is different to that used to create the model.
#' @param latency numeric. Visual response latency in milliseconds.
#'
#' @return List object of class \code{get_alt}
#'
#' @examples
#' get_alt(x, ...)
#'
#' @author Nicholas Carey - \link{nicholascarey@gmail.com}
#'
#' @export

get_alt <-

  function(x,
           response_frame = NULL,
           new_distance = NULL,
           latency = 0){

    ## class check

    ## CHECK - if diam model, require new_distance

    ## CHECK - Require response frame


    #### DIAMETER MODEL ####
    ## requires new_distance since not specified in original model,
    ## plus can't calculate a dadt without a viewing distance

    if(class(x) == "diameter_model"){

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


      ## latency correction
      ## save original
      ## modify response frame by frame rate*latency
      response_frame_original <- response_frame
      response_frame_adjusted <- response_frame-(round(anim_frame_rate*(latency/1000)))

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
      distance_model <- adjusted_model$distance[response_frame_adjusted]
      speed_model <- original_model$speed


      #### OUTPUT

      output <- list(
        dadt_perceived = dadt_perceived,
        distance_perceived = distance_perceived,
        speed_perceived = speed_perceived,

        response_frame_adjusted = response_frame_adjusted,
        latency_applied = latency,
        response_frame_original = response_frame_original,

        distance_model = distance_model,
        speed_model = speed_model,

        adjusted_model = adjusted_model,
        original_model = original_model,
        inputs = inputs
      )}


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


    ## Return results
    return(output)

  } #END


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
