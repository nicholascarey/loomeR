#' @title Create a looming animation
#'
#' @description
#' \code{looming_animation} creates a movie file (\code{.mp4}) of a circle increasing in size to represent
#' an object (e.g. an attacking predator) coming towards a target. The function input must be an object created in
#' \code{\link{constant_speed_model}}, which is where the parameters determining the size and speed of the
#' simulation are determined. It requires \code{ffmpeg} (\url{http://ffmpeg.org}), an external, cross-platform,
#' command line utility for encoding video, to be installed on your system.
#'
#' @details
#' NOTE - The function works by saving an image (\code{loom_img_*******.png} file) for every frame of the animation
#' to the current working directory. It then uses \code{ffmpeg} to encode these images to an \code{.mp4} file
#' (saved as \code{animation.mp4}). It then deletes the \code{.png} files from the working directory. It will overwrite any
#' \code{.png} or \code{.mp4} file it encounters which has an identical name. It's recommended you create a new directory
#' (i.e. folder) for each animation, and use \code{setwd()} to set this as the current working directory before running the
#' function. If you want to save an animation, move it or rename it before running the function again or it will get overwritten.
#' It has not been rigorously tested on older systems with slow read-write speeds to the hard drive, which may cause
#' unknown problems. Please provide feedback if you encounter any issues.
#'
#' The function creates a video at the frame rate (\code{anim_frame_rate}) specified in the \code{\link{constant_speed_model}}
#' object. The frame rate should be one the playback software handles correctly. Most modern displays have a maximum refresh
#' rate of 60 Hz, so videos at frame rates higher than this may not be displayed correctly. I recommend using either 30
#' or 60 frames per second (Hz) which is a frame rate most video playback software should handle correctly. The output
#' video is a circle increasing in diameter over time, as specified in the \code{$model$diam_on_screen} component of
#' the \code{\link{constant_speed_model}} object.
#'
#' The display resolution of the screen you will use to play the animation should be entered as \code{width} and
#' \code{height}. NOTE - This is the current DISPLAY resolution, which is not necessarily the native resolution
#' of the screen, but determined in the Displays preferences of your operating system. If you are unsure, visit
#' \url{https://whatismyscreenresolution.com} on the device. These settings ensure the animation is in the
#' correct aspect ratio and uses the full screen (although you can modify the aspect ratio if, for example,
#' you want your animation to be square). Incorrect resolution values *should* still produce the correct widths
#' onscreen, however I cannot guarantee all playback software will honour this, so best to follow the above guidelines.
#'
#' All screens are different, so an object of a hypothetical size may displayed at a different size on a different
#' screen, due to differences in resolution or the physical size of the pixels that make up the screen. The \code{correction}
#' operator is intended to be a display-specific correction factor to ensure the actual, physical size of the circle
#' matches the diameters in the \code{$model$diam_on_screen} component of the \code{\link{constant_speed_model}} object. This
#' value can be determined using the \code{\link{looming_animation_calib}} function. See the documentation for this function
#' for instructions on its use. If creating different animations, the \code{correction} value will be the same for a particular
#' screen as long as the display resolution remains the same.
#'
#' The circle colour and background can be specified using \code{fill} and \code{background} with standard base-R colour
#' syntax as used in graphics functions such as \code{plot()} etc.
#'
#' In your experiment you may want to identify the particular frame of the animation at which an event such as an escape
#' response occurs. There are two ways of marking the animation so the frame can be identified in video recordings of the
#' experiment. If \code{dots = TRUE}, a small dot is placed in the corner of the frame at the interval specified with
#' \code{dots_interval} starting from the first frame. The colour, size, and corner of the screen to place the dot can be
#' specified (see \code{Arguments}). Alternatively, the frame number can be placed in every frame using
#' \code{frame_number = TRUE}. Again, colour, size and corner can be specified. In addition, the frame number orientation
#' can be set with \code{frame_number_rotation}.
#'
#' The animation can be extended to a required total duration using the \code{pad_start} option. This value is a duration in
#' seconds added to the start of the animation before it starts playback. This duplicates the starting frame of the animation
#' the required number of times to achieve the padding duration. Essentially, this makes the animation static for \code{pad_start}
#' seconds before it starts to play. Depending on the \code{start_distance} set in \code{constant_speed_model}, this obviously
#' means the video will potentially show a static circle until animation playback starts. If you do not want this, either modify
#' the \code{start_distance} until the initial diameter is negligible, or use the \code{pad_blank = TRUE} option, in which case
#' blank frames will be added rather than duplicating the starting frame. Under this option, after \code{pad_start} seconds of
#' blank screen, the animation will suddenly appear and play. Again, how noticable this is depends on the starting diamater as
#' determined with \code{start_distance} in \code{constant_speed_model}. Note that padding the video with extra frames will
#' increase the time it takes for the function to run.
#'
#' The function should work with both Windows and macOS (Linux coming soon), however it requires \code{ffmpeg}
#' (\url{http://ffmpeg.org}), an external, cross-platform, command line utility for encoding video, to be installed on your
#' system. For installation instructions see \url{http://adaptivesamples.com/how-to-install-ffmpeg-on-windows/} (may need to
#' restart) or \url{https://github.com/fluent-ffmpeg/node-fluent-ffmpeg/wiki/Installing-ffmpeg-on-Mac-OS-X}
#'
#' On Windows, if you encounter an error after installation (e.g. \code{unable to start png() device}), try setting
#' the working directory with \code{setwd()} to the current or desired folder. It has not been extensively tested on Windows,
#' so please provide feedback on any other issues you encounter.
#'
#' For triggered playback of the animation I recommend Apple Quicktime Player. Others applications such as VLC
#' have quirks, for example automatically closing the window at the end of the video, however find the application that works
#' best for your purposes. As a check, it's a good idea to ensure the application you use is correctly identifying the
#' metadata of the video. Open the video, pause it, make it fullscreen and then:
#'
#' In Quicktime, Cmd-I or Window > Show Movie Inspector. Check 'Format' matches 'Current Size', and that both match
#' your entered screen resolution \code{width} and \code{height}. Check 'FPS' matches the \code{anim_frame_rate} used
#' to create the model in \code{\link{constant_speed_model}}.
#'
#' In VLC, Cmd-I or Window > Media Information, the 'Codec Details' tab. Check 'Resolution' and 'Display Resolution'
#' both match your entered screen resolution \code{width} and \code{height} (there may be small differences, which is ok).
#' Check 'Frame Rate' matches the \code{anim_frame_rate} used to create the model in \code{\link{constant_speed_model}}.
#' Make sure playback speed is at 'Normal' (Menu>Playback).
#'
#' The function requires the following packages: \code{plotrix}, \code{animation}, \code{glue}.
#'
#' @seealso \code{\link{constant_speed_model}}, \code{\link{looming_animation_calib}}
#'
#' @usage
#' looming_animation(x, ...)
#'
#' @param x list. A list object of class \code{constant_speed_model}.
#' @param correction numeric. Correction factor for the display used to play the animation. Default = 0.0285.
#'  Typically falls between 0.02-0.03. Exact value can be determined using \code{\link{looming_animation_calib}}
#' @param pad_start numeric. Duration in seconds to pad the start of the video. This replicates the first
#'  frame of the animation the required number of times to create this duration. Essentially, it makes the
#'  animation static for \code{pad_start} number of seconds before it starts playing (but see \code{pad_blank}).
#' @param pad_blank logical. Optionally pad with blank frames rather than the first animation frame.
#' @param width numeric. Width resolution of the display. E.g. for a display set at 1080p resolution (1920x1080),
#'  this is \code{width = 1080}. Note: this is NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com} on the playback display to check.
#' @param height numeric. Height resolution of the display. E.g. for a display set at 1080p resolution (1920x1080),
#'  this is \code{width = 1920}. Note: this is NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com} on the playback display to check.
#' @param fill string. Colour of the circle.
#' @param background string. Colour of the background.
#' @param dots logical. Controls if frame tracking dots are added to animation frames (see details).
#' @param dots_interval numeric. Interval in frames from starting frame when dots are added.
#' @param dots_colour string. Colour of dots
#' @param dots_position string. Corner in which to display dots: \code{tr}, \code{tl}, \code{br}, \code{bl},
#'  indicating top right, top left, bottom right, or bottom left.
#' @param dots_size numeric. Size of added dots. Default = 0.005.
#' @param frame_number logical. Controls if numbers are added to animation frames (see details).
#' @param frame_number_colour string. Colour of frame numbers
#' @param frame_number_position string. Corner in which to display frame numbers: \code{tr}, \code{tl}, \code{br},
#'  \code{bl}, indicating top right, top left, bottom right, or bottom left.
#' @param frame_number_size numeric. Size of frame numbers as proportion of default plotting text size. Default = 2.
#' @param frame_number_rotation numeric. Value in degrees (0-360) to rotate frame numbers.
#' @param save_data logical. If \code{=TRUE}, exports as a \code{.csv} the data used to make the animation, including
#'  the column of values scaled using the \code{correction} value.
#'  File name: \code{ANIM_from_**name of R object used**_**frame rate**_**display resolution**.csv}
#'
#' @return An \code{.mp4} video saved to the current working directory called \code{animation.mp4}
#'
#' @examples
#' # make a looming model
#' loom_model <- constant_speed_model(
#'                      screen_distance = 20,
#'                      anim_frame_rate = 60,
#'                      speed = 500,
#'                      attacker_diameter = 50,
#'                      start_distance = 1000)
#'
#' # use it to create an animation with frame numbers in top right corner
#' looming_animation(loom_model,
#'                    correction = 0.0285,
#'                    width = 1920,
#'                    height = 1080,
#'                    frame_number = TRUE,
#'                    frame_number_position = "tr",
#'                    frame_number_size = 2)
#'
#' @author Nicholas Carey - \link{nicholascarey@gmail.com}
#'
#' @export

## To Do
## option to set position (i.e. distance from side) of dots and frame number
## pad animation with frames before/after, or loop it. i.e. make very long video, or constant looping animation.
  ## option to add dots/frame number to every frame or just when anim starts
## add time check = "video should be ...s long" = total frames/fps
## option to NOT convert images using ffmpeg
## set package dependencies

looming_animation <-

  function(x,
           correction = 0.0285,
           pad_start = NULL,
           pad_blank = FALSE,
           width=1280,
           height=1024,
           fill = "black",
           background = "white",
           dots = FALSE,
           dots_interval = 20,
           dots_colour = "grey",
           dots_position = "br",
           dots_size = 0.005,
           frame_number = FALSE,
           frame_number_colour = "grey",
           frame_number_position = "tr",
           frame_number_size = 2,
           frame_number_rotation = 0,
           save_data = FALSE){

    ## check x class
    if(class(x) != "constant_speed_model")
      stop("Input must be an object of class 'constant_speed_model'.")

    ## load required packages
    require("plotrix")
    require("animation")
    require("glue")

    ## check for mac or windows thne change this to...
    #ani.options(convert = '/opt/local/bin/convert')

    ## extract data and parameters
    cs_model <- x$model
    frame_rate <- x$anim_frame_rate


              ## use pad_start to duplicate starting frame the required number of times
              ## this modifies the input 'constant_speed_model' cs_model and replaces it
              if(!is.null(pad_start)){

              # If pad_blank is not TRUE
              # replicates first diam_on_screen value required number of times and adds rest of diam_on_screen
              if(!isTRUE(pad_blank)){
                temp_diam_on_screen <- c(rep(cs_model$diam_on_screen[1], pad_start*frame_rate), cs_model$diam_on_screen)
              # otherwise set the diamater to Zero for those frames to achieve a blank frame
              } else {
                temp_diam_on_screen <- c(rep(0, pad_start*frame_rate), cs_model$diam_on_screen)
              }


              temp_distance <- c(rep(cs_model$distance[1], pad_start*frame_rate), cs_model$distance)
              temp_frame <- seq(1, length(temp_diam_on_screen), 1)
              temp_time <- temp_frame/frame_rate

              ## make new padded model
              padded_model <- data.frame(
                temp_frame,
                temp_time,
                temp_distance,
                temp_diam_on_screen
              )

              names(padded_model) <- names(cs_model)

              cs_model <- padded_model
              }


    ## total frames
    total_frames <- nrow(cs_model)


    ## use correction factor to modify diameters
    if(!is.null(correction)){
      cs_model$diam_on_screen_corrected <- cs_model$diam_on_screen * correction
    } else {
      cs_model$diam_on_screen_corrected <- cs_model$diam_on_screen
    }



    ## create image for each frame
    for(i in 1:total_frames){
      # create a name for each file with leading zeros
      if (i < 10) {name = paste('loom_img_', '00000',i,'.png',sep='')}
      if (i < 100 && i >= 10) {name = paste('loom_img_', '0000',i,'.png', sep='')}
      if (i < 1000 && i >= 100) {name = paste('loom_img_', '000', i,'.png', sep='')}
      if (i < 10000 && i >= 1000) {name = paste('loom_img_', '00', i,'.png', sep='')}
      if (i >= 10000) {name = paste('loom_img_', '0', i,'.png', sep='')}

      # make png file
      png(name, width=width, height=height, res=72)

      # create new plot
      par(mar=c(0,0,0,0), bg=background)
      plot.new()

      # make circle - centered
      draw.circle(x=0.5, y=0.5,
                  ## NOTE - use corrected column
                  r <- cs_model$diam_on_screen_corrected[i]/2,
                  nv=100,
                  border=fill,
                  col=fill,
                  lty=1,lwd=1)

      ## add dots
      if(dots == TRUE){
        ## set x and y coords from position
        dots_x_pos <- right(dots_position, 1)
        dots_y_pos <- left(dots_position, 1)

        # set x position
        if(dots_x_pos == "l"){
          dots_x_coord <- 0.07
        } else if(dots_x_pos == "r"){
          dots_x_coord <- 0.93
        }

        # set y position
        if(dots_y_pos == "b"){
          dots_y_coord <- 0.05
        } else if(dots_y_pos == "t"){
          dots_y_coord <- 0.95
        }

        ## draw dot in corner of first frame
        if(i == 1) {draw.circle(x=dots_x_coord, y=dots_y_coord,
                                r <- dots_size,
                                nv=100,
                                border=dots_colour,
                                col=dots_colour,
                                lty=1,
                                lwd=1)}

        # draw dot in corner every 25th frame
        if(i %% dots_interval == 0) {draw.circle(x=dots_x_coord, y=dots_y_coord,
                                                 r <- dots_size,
                                                 nv=100,
                                                 border=dots_colour,
                                                 col=dots_colour,
                                                 lty=1,
                                                 lwd=1)}

        # draw dot in corner of last frame
        if(i == total_frames) {draw.circle(x=dots_x_coord, y=dots_y_coord,
                                           r <- dots_size,
                                           nv=100,
                                           border=dots_colour,
                                           col=dots_colour,
                                           lty=1,
                                           lwd=1)}
      }


      ## add frame numbers
      if(frame_number == TRUE){

        ## set x and y coords from position
        fn_x_pos <- right(frame_number_position, 1)
        fn_y_pos <- left(frame_number_position, 1)

        if(fn_x_pos == "l"){
          fn_x_coord <- 0.05
        } else if(fn_x_pos == "r"){
          fn_x_coord <- 0.95
        }

        if(fn_y_pos == "b"){
          fn_y_coord <- 0.05
        } else if(fn_y_pos == "t"){
          fn_y_coord <- 0.95
        }

        ## make frame number label
        text(paste(i),
             col = frame_number_colour,
             x=fn_x_coord,
             y=fn_y_coord,
             cex = frame_number_size,
             srt = frame_number_rotation)
      }

      ## clear plot before next loop
      dev.off()

    } # end loop

    ## save data
    if(save_data == TRUE){
      filename <- glue::glue('ANIM_from_',
                             deparse(quote(x)),
                             '_',
                             {frame_rate},
                             'fps_',
                             {width},
                             'x',
                             {height},
                             '.csv'
      )

      write.csv(cs_model, file = glue::glue(filename))
    }


    ## ffmpeg options
    # -y (global) = Overwrite output files without asking
    # -r = Set frame rate (Hz value, fraction or abbreviation)
    # -f = Force input or output file format
    # -s = Set frame size
    # -i = input file url
    # plot%06d.png = specifies to look for files called loom_img_, followed by number composed of six digits
    # padded with zeroes to express the sequence number
    # -vcodec = Set the video codec (libx264)
    # -crf = Constant Rate Factor for x264. Decides how many bits will be used for each frame.
    # i.e. quality~file size trade-off. 0 (lossless) to 50 (worst)
    # -pix_fmt = Set pixel format (yuv420p)
    # animation.mp4 = name of output file
    ## && rm *.png OR del *.png  = delete ALL png files on Mac or Win respectively

    ## build system/ffmpeg command on OS specific basis
    ## For Mac
    if(os() == "mac"){
      instruction_string <-
        glue::glue(
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%06d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation.mp4; rm loom_img_*.png'
        )
      ## run the command
      system(instruction_string)
    }

    ## For Windows
    ## NOTE - command changed to remove deletion instruction at end
    ## For some reason Windows needs to run this via the shell() command
    else if(os() == "win"){
      instruction_string <-
        glue::glue(
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%06d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p animation.mp4'
        )
      ## run command
      system(instruction_string)

      ## delete png files
      shell("del loom_img_*.png")
    }

  }


#' Get left n characters
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
left = function (string,n){
  substr(string,1,n)
}

#' Get right n characters
#'
#' This is an internal function.
#'
#' @keywords internal
#' @export
right = function (string, n){
  substr(string, nchar(string)-(n-1), nchar(string))
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
