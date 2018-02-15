#' @title Create a short animation for calibrating the looming animation function
#'
#' @description
#' All screens are different, so an object of a hypothetical size may displayed at a different size on a different
#' screen, due to differences in resolution or the physical size of the pixels that make up the screen.
#'
#' \code{looming_animation_calib} is a utility to create a short animation from an object of class
#' \code{\link{constant_speed_model}}. It requires \code{ffmpeg} (\url{http://ffmpeg.org}), an external, cross-platform,
#' command line utility for encoding video, to be installed on your system. The function allows the \code{correction}
#' value (typically in the range 0.02 - 0.03) used in \code{looming_animation_calib} to be determined, and checks the
#' desired screen diameter is correctly displayed. Requires access to the screen you intend to display the animation on,
#' and a ruler or other method of physically measuring lengths on the screen. Output is a short 60 frame video containing
#' a static image of 10 horizontal bars (it is not an image file to ensure software rendering onscreen is consistent).
#' This video should be paused, made fullscreen and the bar closest in length to 10cm used to estimate the correct
#' \code{correction} value. The function can be run again to further refine estimates of the \code{correction} value, if
#' the 10cm distance falls between two \code{correction} values. If creating different animations, the \code{correction}
#' value will be the same for a particular screen as long as the display resolution remains the same (see details).
#'
#' @details
#' NOTE - The function works by saving an image (\code{loom_img_**.png} file) for every frame of the animation
#' to the current working directory. It then uses \code{ffmpeg} to encode these images to an \code{.mp4} file
#' (saved as \code{animation.mp4}). It then deletes the \code{.png} files from the working directory. It will overwrite any
#' \code{.png} or \code{.mp4} file it encounters which has an identical name. It's recommended you create a new directory
#' (i.e. folder) for each animation, and use \code{setwd()} to set this as the current working directory before running the
#' function. If you want to save an animation, move it or rename it before running the function again or it will get overwritten.
#' I have not tested this on old systems with slow read-write speeds to the hard drive. This may cause problems. Please
#' provide feedback if you encounter any problems.
#'
#' The function creates a short 60 frame video containing a static image of 10 horizontal bars along with the
#' \code{correction} value used to create each. It is a video not an image file to ensure software rendering onscreen is
#' consistent. Open the file in the software you intend to use to play back the final animation, make it fullscreen, pause it,
#' and measure the bars physically on the screen with a ruler to identify the correct \code{correction} value. If the closest
#' result to 10cm falls between two values, these can be entered as the \code{correction_range} and the function re-run to
#' further refine the estimate. When a good \code{correction} value is determined, this should be used in the
#' \code{looming_animation} function to produce the final animation.
#'
#' The display resolution of the screen you will use to play the animation should be entered as \code{width} and
#' \code{height}. NOTE - This is the current DISPLAY resolution, which is not necessarily the native resolution
#' of the screen, but determined in the Displays preferences of your operating system. If you are unsure, visit
#' \url{https://whatismyscreenresolution.com} on the device. These settings ensure the animation is in the
#' correct aspect ratio and uses the full screen (although you can modify the aspect ratio if, for example,
#' you want your animation to be square). Incorrect resolution values *should* still produce the correct widths onscreen,
#' however I cannot guarantee all playback software will honour this, so best to follow the above guidelines.
#'
#' The function should work with both Windows and macOS (Linux coming soon), however it requires \code{ffmpeg}
#' (\url{http://ffmpeg.org}), an external, cross-platform, command line utility for encoding video, to be installed on your
#' system. For installation instructions see \url{http://adaptivesamples.com/how-to-install-ffmpeg-on-windows/} (may need to
#' restart) or \url{https://github.com/fluent-ffmpeg/node-fluent-ffmpeg/wiki/Installing-ffmpeg-on-Mac-OS-X}
#'
#' On Windows after installation, if you encounter an error (e.g. \code{unable to start png() device}), try setting
#' the working directory with \code{setwd()} to the current or desired folder. Please provide feedback on any other
#' errors you encounter.
#'
#' The function requires the following packages: \code{plotrix}, \code{animation}, \code{glue}.
#'
#' @seealso \code{\link{constant_speed_model}}, \code{\link{looming_animation}}
#'
#' @usage
#' looming_animation_calib(x, ...)
#'
#' @param x A list object of class \code{constant_speed_model}
#' @param correction_range numeric vector of length = 2. Upper and lower range of the correction factors to be tested
#' @param width numeric. Width resolution of the display. E.g. for a display set at 1080p resolution (1920x1080),
#'  this is \code{width = 1080}. Note: this is NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com} on the playback display to check.
#' @param height numeric. Height resolution of the display. E.g. for a display set at 1080p resolution (1920x1080),
#'  this is \code{width = 1920}. Note: this is NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com} on the playback display to check.
#'
#' @return An \code{.mp4} video saved to the current working directory called \code{animation_calib.mp4}
#'
#' @examples
#' # make a looming model
#' loom_model <- constant_speed_model(
#'                      screen_distance = 20,
#'                      anim_frame_rate = 60,
#'                      speed = 500,
#'                      diameter = 50,
#'                      start_distance = 1000)
#'
#' # use it to create a calibration video
#' looming_animation_calib(loom_model,
#'                            correction_range = c(0.02, 0.03),
#'                            width = 1920,
#'                            height = 1080)
#'
#' @author Nicholas Carey - \link{nicholascarey@gmail.com}
#'
#' @export


looming_animation_calib <-

  function(x,
           correction_range = c(0.02, 0.03),
           width=1920,
           height=1080){

    ## check x class
    if(class(x) != "constant_speed_model")
      stop("Input must be an object of class 'constant_speed_model'.")

    ## load required packages
    require("plotrix")
    require("animation")
    require("glue")

    ## extract data
    frame_rate <- x$anim_frame_rate
    total_frames <- 60

    ## vector of 10 correction values to try
    corr_values <- seq(min(correction_range), max(correction_range), # from - to
                       (max(correction_range)-min(correction_range))/9) # by

    ## make new 10cm lengths using different correction values
    ten_cm_lengths <- corr_values * 10

    ## make xy coords for rect() function
    x_left <- c(0.05, 0.05, 0.05, 0.05, 0.05,
                0.95 - ten_cm_lengths[6],
                0.95 - ten_cm_lengths[7],
                0.95 - ten_cm_lengths[8],
                0.95 - ten_cm_lengths[9],
                0.95 - ten_cm_lengths[10])

    x_right <- c(0.05 + ten_cm_lengths[1],
                 0.05 + ten_cm_lengths[2],
                 0.05 + ten_cm_lengths[3],
                 0.05 + ten_cm_lengths[4],
                 0.05 + ten_cm_lengths[5],
                 0.95, 0.95, 0.95, 0.95, 0.95)

    y_top <- c(0.9, 0.7, 0.5, 0.3, 0.1, 0.9, 0.7, 0.5, 0.3, 0.1)

    y_bottom <- y_top - 0.05

    ## create image for each frame
    for(i in 1:total_frames){
      # create a name for each file with leading zeros
      if (i < 10) {name = paste('loom_img_', '0',i,'.png',sep='')}
      if (i < 100 && i >= 10) {name = paste('loom_img_',i,'.png', sep='')}

      # make png file
      png(name, width=width, height=height, res=72)

      # create new plot
      par(mar=c(0,0,0,0), bg="white")
      plot.new()

      ## make rectangle
      rect(xleft = x_left,
           xright = x_right,
           ybottom = y_bottom,
           ytop = y_top)

      ## add appropriate correction value to each
      text(round((corr_values),4),
           col = "red",
           x = (x_right + x_left)/2,
           y = (y_top + y_bottom)/2,
           cex = 2)

      ## Instructions
      text("Pause Video & Make Fullscreen!",
           x = 0.5,
           y=0.975,
           cex = 4)

      ## measurement arrow
      arrows(x_left[1], y_top[1]-0.1, x_right[1], y_top[1]-0.1,
             col = "black",
             lwd = 2,
             code = 3,
             length = 0.1)
      text("Which is closest to 10cm onscreen?",
           x = (x_left[1] + x_right[1])/2,
           y= y_top[1]-0.15,
           cex = 2)

      ## clear plot before next loop
      dev.off()

    } # end loop

    ## ffmpeg options
    # -y (global) = Overwrite output files without asking
    # -r = Set frame rate (Hz value, fraction or abbreviation)
    # -f = Force input or output file format
    # -s = Set frame size
    # -i = input file url
    # plot%06d.png = specifies to look for files called loom_img_, followed by number composed of 2 digits
    # padded with zeroes to express the sequence number
    # -vcodec = Set the video codec (libx264)
    # -crf = Constant Rate Factor for x264. Decides how many bits will be used for each frame.
    # i.e. quality~file size trade-off. 0 (lossless) to 50 (worst)
    # -pix_fmt = Set pixel format (yuv420p)
    # animation_calib.mp4 = name of output file
    ## && rm or del - deletes ALL png files in current directory

    ## build system/ffmpeg command on OS specific basis
    ## For Mac
    if(os() == "mac"){
      instruction_string <-
        glue::glue(
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%02d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation_calib.mp4; rm loom_img_*.png'
        )
      ## run the command
      system(instruction_string)
    }

    ## For Windows
    ## NOTE - command changed to remove deletion instruction at end
    ## For some reason Windows needs to run this separately via the shell() command
    else if(os() == "win"){
      instruction_string <-
        glue::glue(
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%02d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation_calib.mp4'
        )
      ## run command
      system(instruction_string)

      ## delete png files
      shell("del loom_img_*.png")
    }

  }



#' Check operating system
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export

os <- function() {
  if (.Platform$OS.type == "windows")
    "win" else if (Sys.info()["sysname"] == "Darwin")
      "mac" else if (.Platform$OS.type == "unix")
        "unix" else stop("Unknown OS")
}
