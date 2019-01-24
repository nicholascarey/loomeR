# Internal Functions ------------------------------------------------------

#' Print get_alt result
#'
#' @keywords internal
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
  cat(glue::glue("Latency Applied:           ",
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
  if (.Platform$OS.type == "windows")
    "mac" else if (.Platform$OS.type == "unix")
      "win" else if (Sys.info()["sysname"] == "Darwin")
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
  cat(sprintf('\r[%-50s] %d%% Generating image files',
              paste(rep('=', percent / 2), collapse = ''),
              floor(percent)))
  if (x == max)
    cat('\n')
}


## Leaving the below for now. Getting Windows commands to run is a pain.
## Might need to look into admin v non-admin user issues
#' #' Check if ffmpeg is installed
#' #'
#' #' @details Runs system commands on OS-specific basis to check if ffmpeg is
#' #'   installed. Experimental for now. Added `force_ffmpeg` argument to
#' #'   `looming_animation` and `looming_animation_calib` to override if necessary.
#' #'
#' #' @keywords internal
#' #' @export
#'
#' check_ffmpeg <- function(force_ffmpeg = force_ffmpeg) {
#'
#'   os <- os()
#'
#'   ## XP
#'   if(os == "xp" && force_ffmpeg == FALSE){
#'     stop("Windows XP is not supported for creating animations because of ffmpeg compatibility problems.
#'          If you want to ignore this warning and try anyway, you can override with force_ffmpeg = TRUE."
#'     )}
#'
#'   ## Linux
#'   if(os == "unix"){
#'     stop("Linux systems are not yet supported for creating animations.
#'          Please contact me if you would like to help with implementing this functionality."
#'     )}
#'
#'   ## MAC
#'   if(os == "mac" && force_ffmpeg == FALSE){
#'
#'     ffmpeg_path <- system("which ffmpeg", intern = TRUE)
#'
#'     if(length(ffmpeg_path) == 0 && force_ffmpeg == FALSE){
#'       stop("ffmpeg does not appear to be installed on this Mac. Animation creation halted.
#'     Visit ffmpeg.org for installation instructions.
#'     (Note: this is an experimental warning. If you are sure ffmpeg *IS* installed, you can override with force_ffmpeg = TRUE)")
#'     }}
#'
#'   ## WIN 7/8/10
#'   if(os == "win" && force_ffmpeg == FALSE){
#'
#'     ffmpeg_path <- shell("where ffmpeg", intern = TRUE)
#'
#'     if(length(ffmpeg_path) == 2 && force_ffmpeg == FALSE){
#'       stop("ffmpeg does not appear to be installed on this Mac. Animation creation halted.
#'   Visit ffmpeg.org for installation instructions.
#'   (Note: this is an experimental warning. If you are sure ffmpeg *IS* installed, you can override with force_ffmpeg = TRUE)")
#'     }}
#'
#' } #end
