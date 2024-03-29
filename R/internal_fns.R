# Internal Functions ------------------------------------------------------

#' Print get_alt result
#'
#' @keywords internal
#' @export
print.get_alt <- function(x, ...) {
  cat("\n")
  cat("Extraction complete. \n \n")
  cat(glue::glue("Response Frame:            ",
                 {x$response_frame}))
  cat("\n")
  cat(glue::glue("Response Frame Adjusted:   ",
                 {x$response_frame_adjusted}))
  cat("\n")
  cat(glue::glue("Latency Applied:           ",
                 {x$latency_applied},
                 "s"))
  cat("\n")
  cat(glue::glue("New Screen Distance:       ",
                 {x$inputs$new_distance},
                 "cm"))
  cat(" \n")
  cat("The Apparent Looming Threshold is: \n")
  cat(glue::glue("ALT: ",
                 {round(x$alt, 4)},
                 " radians/sec"))
}

#' Convert radians to degrees
#'
#' @keywords internal
#' @export
rad2deg <- function(rad){(rad * 180) / (pi)}


#' Get left n characters
#'
#' @keywords internal
#' @export
left = function (string,n){
  substr(string,1,n)
}

#' Get right n characters
#'
#' @keywords internal
#' @export
right = function (string, n){
  substr(string, nchar(string)-(n-1), nchar(string))
}


#' Check operating system
#'
#' @keywords internal
#' @export
os <- function() {
  if (Sys.info()["sysname"] == "Darwin")
    "mac" else if (.Platform$OS.type == "windows")
      "win" else if (.Platform$OS.type == "unix")
        "unix" else stop("Unknown OS")
}


#' Display image generation progress bar
#'
#' @details
#' Displays an updating progress bar within the frame image generation loop. Modified from
#' \url{https://github.com/klmr/rcane/blob/master/system.R}.
#'
#' @keywords internal
#' @export
image_progress <- function (x, max = 100) {
  percent <- x / max * 100
  cat(sprintf('\r[%-50s] %d%% Generating image files...',
              paste(rep('=', percent / 2), collapse = ''),
              floor(percent)))
  if (x == max)
    cat('\n')
}

#' Display preparing video progress bar
#'
#' @details
#' Simply implements a delay
#'
#' @keywords internal
#' @export
prep_progress <- function (x, max = 100) {
  percent <- x / max * 100
  cat(sprintf('\r[%-50s] %d%% Preparing to create video file...',
              paste(rep('=', percent / 2), collapse = ''),
              floor(percent)))
  if (x == max)
    cat('\n')
}


#' Calculate alpha in radians
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
calc_alpha <- function(diameter, distance){
  output <- 2*(atan((diameter/2)/distance))
  ## make positive
  ## Sometimes 0 is returned as -3.14, sometimes not. No idea why...
  output <- abs(output)
  return(output)
}


#' Calculate da/dt in radians
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
calc_dadt <- function(speed, diameter, distance){
  output <- 4*(speed*diameter)/((4*distance^2)+(diameter^2))
  return(output)
}


#' Calculates screen diameter
#'
#' alpha = alpha angles
#' screen_distance = distance simulation will be viewed at
#'
#' @keywords internal
#' @export
calc_screen_diam <- function(alpha, screen_distance){
  ## add diam_on_screen column
  diam_on_screen <- 2 * screen_distance * (tan(alpha / 2))
  ## Round to 2 decimal places (1/10th of a mm)
  diam_on_screen <- sapply(diam_on_screen, function(z) round(z, 2))
  ## Convert any diameter over 1000cm to 1000cm, which can't be displayed on screen anyway.
  ## (deals with values on last frames, where diam can be approaching infinity)
  ## (need to use abs because sometimes they are approaching negative infinity)
  diam_on_screen <- sapply(diam_on_screen, function(z) ifelse(abs(z) > 1000, z <- 1000, z))
  return(diam_on_screen)
}




## Leaving the below for now. Getting Windows commands to run is a pain.## Might need to look into admin v non-admin user issues#' Check if ffmpeg is installed
#'
#' @details Runs system commands on OS-specific basis to check if ffmpeg is
#'   installed. Experimental for now. Added `force_ffmpeg` argument to
#'   `looming_animation` and `looming_animation_calib` to override if necessary.
#'
#' @keywords internal
#' @export

# check_ffmpeg <- function(ffmpeg_check = ffmpeg_check) {
#
#   os <- os()
#
#   # ## XP - Don't know yet how to detect XP as opposed to other Win versions
#   # if(os == "xp" && ffmpeg_check == TRUE){
#   #   stop("Windows XP is not supported for creating animations because of ffmpeg compatibility problems.
#   #        If you want to ignore this warning and try anyway, you can override with ffmpeg_check = TRUE."
#   #   )}
#
#   ## Linux
#   if(os == "unix"){
#     stop("Linux systems are not yet supported for creating animations.
#          Please contact me if you would like to help with implementing this functionality."
#     )}
#
#   ## MAC
#   if(os == "mac" && ffmpeg_check == TRUE){
#
#     ffmpeg_path <- suppressWarnings(
#       system2(command = "which", args = "ffmpeg", stderr = TRUE)
#     )
#
#     if(length(ffmpeg_path) == 0 && ffmpeg_check == TRUE){
#       stop("ffmpeg does not appear to be installed on this Mac. Animation creation halted.
#       Visit ffmpeg.org for installation instructions.
#       (Note: this is an experimental warning. If you are sure ffmpeg *IS* installed, you can override this check with ffmpeg_check = FALSE)")
#     }
#   }
#
#   ## WIN 7/8/10
#   if(os == "win" && ffmpeg_check == FALSE){
#
#     ffmpeg_path <- shell("where ffmpeg", intern = TRUE)
#
#     if(length(ffmpeg_path) == 2 && ffmpeg_check == FALSE){
#       stop("ffmpeg does not appear to be installed on this Mac. Animation creation halted.
#   Visit ffmpeg.org for installation instructions.
#   (Note: this is an experimental warning. If you are sure ffmpeg *IS* installed, you can override this check with ffmpeg_check = FALSE)")
#     }}
#
# } #end
#
