#'@title Create a short animation for calibrating the looming animation function
#'
#'@description All screens are different, so an object of a hypothetical size
#'  may be displayed at a different size on a different screen, due to
#'  differences in resolution or the physical size of the pixels that make up
#'  the screen. \code{looming_animation_calib} is a utility to help calibrate
#'  the \code{\link{looming_animation}} function for a particular screen.
#'
#'
#'@details IMPORTANT: The function works by saving an image
#'  (\code{loom_img_01.png} etc.) for every frame of the animation to the
#'  current working directory. It then uses \code{ffmpeg} to encode these images
#'  to an \code{.mp4} file (saved as \code{animation_calib.mp4}). It then
#'  deletes the \code{.png} files from the working directory. It will overwrite
#'  any \code{.png} or \code{.mp4} file it encounters which has an identical
#'  name.
#'
#'  The function helps determine the \code{correction} value used in
#'  \code{\link{looming_animation}} to ensure screen diameters are correctly
#'  displayed. Typically this is in the range 0.01 - 0.06, with the larger the
#'  screen the lower the value. It requires access to the screen you intend to
#'  display the animation on, and a ruler or other method of physically
#'  measuring lengths on the screen. The output is a short 2 second, 60 frame
#'  video containing a static image of 10 horizontal bars (it is not an image
#'  file to ensure software rendering onscreen is consistent). This video should
#'  be opened in the playback application, paused, made fullscreen and the bar
#'  closest in length to the entered \code{ruler} value used to estimate an
#'  appropriate \code{correction} value. If the \code{ruler} width falls between
#'  two values, these can be entered as the \code{correction_range}, and the
#'  function run again to further refine estimates of the \code{correction}
#'  value. The \code{ruler} value should be less than the physical horizontal
#'  width of the screen, or - obviously - the bars will be too wide to display.
#'
#'  The display resolution of the screen you will use to play the animation
#'  should be entered as \code{width} and \code{height}. NOTE - This is the
#'  current DISPLAY resolution, which is not necessarily the native resolution
#'  of the screen, but determined in the Displays preferences of your operating
#'  system. If you are unsure, visit \url{https://whatismyscreenresolution.com}
#'  on the device. These settings ensure the animation is in the correct aspect
#'  ratio and uses the full screen.
#'
#'  Note that if you are creating multiple animations, the \code{correction}
#'  value used in \code{\link{looming_animation}} will be the same for a
#'  particular screen as long as the display resolution remains the same.
#'
#'  The function should work with both Windows and macOS (Linux coming soon),
#'  however it requires \code{ffmpeg} (\url{http://ffmpeg.org}), an external,
#'  cross-platform, command line utility for encoding video, to be installed on
#'  your system. For installation instructions see
#'  \url{http://adaptivesamples.com/how-to-install-ffmpeg-on-windows/} (may need
#'  to restart) or
#'  \url{https://github.com/fluent-ffmpeg/node-fluent-ffmpeg/wiki/Installing-ffmpeg-on-Mac-OS-X}
#'
#'
#'
#'
#'  \subsection{Note on smaller screens}{If you are using the function to
#'  calibrate for a small screen, for example a phone or tablet, the resulting
#'  video might look strange: low resolution, blurry, bad spacing, etc. This is
#'  normal, and a result of having to scale the text size to display properly.
#'  It should not affect the estimation of the \code{calibration} value, or the
#'  animation you eventually create in \code{\link{looming_animation}}. Please
#'  do let me know if you have any issues however.}
#'
#'@section Dependencies: The function requires the following packages:
#'  \code{glue}.
#'
#'@seealso \code{\link{looming_animation}}
#'
#'@param correction_range numeric vector of length = 2. Upper and lower range of
#'  the correction factors to be tested. Defaults to \code{c(0.02, 0.03)}.
#'  Larger screens require lower values.
#'@param width integer. Width resolution of the display. E.g. for a display set
#'  at 1080p resolution (1920x1080), this is \code{width = 1920}. Note: this is
#'  NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com}
#'  on the playback display to check.
#'@param height integer. Height resolution of the display. E.g. for a display
#'  set at 1080p resolution (1920x1080), this is \code{height = 1080}. Note:
#'  this is NOT the native resolution, but the display resolution as set in the
#'  operating system settings. Visit \url{https://whatismyscreenresolution.com}
#'  on the playback display to check.
#'@param ruler numeric. Width in cm to check onscreen with your ruler. Should be
#'  less than the physical horizontal width of the screen, or - obviously - it
#'  will be too large to display.
#'
#' @examples
#' # Create a calibration video for checking a 10cm width
#' looming_animation_calib(correction_range = c(0.02, 0.03),
#'                         width = 1920,
#'                         height = 1080,
#'                         ruler = 10)
#'
#'@author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#'@importFrom glue glue
#'
#'@export

looming_animation_calib <-

  function(correction_range = c(0.02, 0.03),
           width = 1920,
           height = 1080,
           ruler = 10){

    ## check for odd numbered screen resolutions, and if so add a pixel
    ## odd numbers cause "not divisible by 2" error in ffmpeg
    if(width %% 2 != 0){
      width <- width +1
    }
    if(height %% 2 != 0){
      height <- height +1
    }

    ## set parameters
    frame_rate <- 30
    total_frames <- 60

    ## vector of 10 correction values to try
    corr_values <- seq(min(correction_range), max(correction_range), # from - to
                       (max(correction_range)-min(correction_range))/9) # by

    ## make new 10cm lengths using different correction values
    ruler_lengths <- corr_values * ruler

    ## set display positions
    x_left <- 0.05

    x_right <- c(0.05 + ruler_lengths[1],
                 0.05 + ruler_lengths[2],
                 0.05 + ruler_lengths[3],
                 0.05 + ruler_lengths[4],
                 0.05 + ruler_lengths[5],
                0.05 + ruler_lengths[6],
                0.05 + ruler_lengths[7],
                0.05 + ruler_lengths[8],
                0.05 + ruler_lengths[9],
                0.05 + ruler_lengths[10])

    y_top <- rev(seq(0.1, 0.82, 0.08))

    y_bottom <- y_top - 0.05

    ## create image for each frame
    for(i in 1:total_frames){
      # create a name for each file with leading zeros
      if (i < 10) {name = paste('loom_img_', '0',i,'.png',sep='')}
      if (i < 100 && i >= 10) {name = paste('loom_img_',i,'.png', sep='')}

      # make png file
        # res= here is a bit of a hack to scale the text so that it's readable on
        # different sized screens - results in low resolution on smaller screens though
      png(name, width=width, height=height, res=round(width*0.05))

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
      arrows(x_left[1], y_top[1]+0.02, x_right[1], y_top[1]+0.02,
             col = "blue",
             lwd = 3,
             code = 3,
             length = 0.1)
      text(glue::glue('Vary values until one produces a bar {ruler}cm long on screen'),
           x = 0.5,
           y = 0.9,
           cex = 3)

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

