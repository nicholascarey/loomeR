#' @title Create a looming animation
#'
#' @description \code{looming_animation} creates a movie file (\code{.mp4}) of a
#'   circle increasing in size to simulate an object (e.g. an attacking
#'   predator) coming towards a target. The function input must be an object
#'   created in either \code{\link{constant_speed_model}},
#'   \code{\link{variable_speed_model}}, or \code{\link{diameter_model}} which
#'   is where the parameters determining the size and speed of the simulation
#'   are entered. It requires \code{ffmpeg} (\url{http://ffmpeg.org}), an
#'   external, cross-platform, command line utility for encoding video, to be
#'   installed on your system.
#'
#' @details IMPORTANT: The function works by saving an image file
#'   (\code{loom_img_0000001.png} etc.) for every frame of the animation to the
#'   current working directory. It then uses \code{ffmpeg} to encode these
#'   images to an \code{.mp4} file. By default, this is saved as
#'   \code{animation.mp4}, however the `filename` operator can be used to
#'   specify a custom file name. It then deletes (actually deletes, not just
#'   sent to the trash) the \code{.png} files from the working directory. The
#'   function will overwrite any \code{.png} or \code{.mp4} file it encounters
#'   which **has an identical name**. It's recommended you create a new
#'   directory (i.e. folder) for each animation, and use \code{setwd()} to set
#'   this as the current working directory before running the function. If you
#'   want to save an animation, you should move or rename it, or change the
#'   `filename` input before running the function again or it will get
#'   overwritten. It has not been rigorously tested on older systems with slow
#'   read-write speeds to the hard drive, which may cause unknown problems (but
#'   see the `pause` operator, which allows the function to be slowed down)
#'   Please provide feedback if you encounter any issues.
#'
#'   The function is capable of controlling precise details of how the object is
#'   displayed on screen. For example the \code{correction} operator ensures the
#'   hypothesised size in the model is displayed at that exact size on a
#'   specific display at a specific resolution. These details are important in
#'   experiments where the time in the animation at which an escape response
#'   occurs (and hence the perceived visual angle (alpha), distance and/or speed
#'   of the attacker) are of interest. If you simply want to generate an
#'   animation to elicit a response and are unconcerned with these details, you
#'   can ignore most of these options. For simple models where these details are
#'   unimportant see \code{\link{diameter_model}}.
#'
#'   Note animations will typically end with a filled screen, because even small
#'   objects at viewing distances approaching zero approach infinite perceived
#'   size (the exception is if you have used \code{\link{diameter_model}} and
#'   set the end diameter to less than the size of your screen). The final
#'   animation may have several completely filled frames at the end, depending
#'   on the \code{attacker_diameter} as set in \code{constant_speed_model} or
#'   \code{variable_speed_model}. Obviously, an object above a certain diameter
#'   cannot be displayed on a screen smaller than that diameter. If your
#'   attacker is larger in diameter than the screen, the final stages of the
#'   animation cannot physically display the actual perceived size as it gets
#'   close to the subject. In these cases, the animation essentially continues
#'   past the point where it can display the entirety of the simulation, and
#'   shows a filled screen (of the chosen \code{fill} colour) for however many
#'   frames are left in the simulation beyond that point. In most cases, if
#'   using biologically realistic parameters, this will be only a few frames.
#'
#' @section Screen display and playback considerations: The output video is of a
#'   circle increasing in diameter over time, as specified in the
#'   \code{$model$diam_on_screen} component of the original
#'   \code{\link{constant_speed_model}}, \code{\link{variable_speed_model}} or
#'   \code{\link{diameter_model}} object. The function creates a video at the
#'   \code{frame_rate} specified in this object. The frame rate should be one
#'   the playback software handles correctly. Most modern displays have a
#'   maximum refresh rate of 60 Hz, so videos at frame rates higher than this
#'   may not be displayed correctly. I recommend using either 30 or 60 frames
#'   per second (Hz) which is a frame rate most video playback software should
#'   honour without problems. (I would be very interested to hear user
#'   experiences of using displays which support higher frame rates than this,
#'   such as recent iPad Pros with 120Hz refresh rates).
#'
#'   The display resolution of the screen you will use to play the animation
#'   should be entered as \code{width} and \code{height}. NOTE - This is the
#'   current DISPLAY resolution, which is not necessarily the native resolution
#'   of the screen, but determined in the Displays preferences of your operating
#'   system. If you are unsure, visit \url{https://whatismyscreenresolution.com}
#'   on the device. These settings ensure the animation is in the correct aspect
#'   ratio and uses the full screen (although you are free to modify the aspect
#'   ratio if, for example, you want your animation to be square). Other
#'   resolution values *should* still produce the correct widths onscreen,
#'   however I cannot guarantee all playback software will honour this, so best
#'   to follow the above guidelines if these details are important in your
#'   experiment.
#'
#'   An object of a hypothetical size may be displayed at a different size on a
#'   different screen, due to differences in resolution or the physical size of
#'   the pixels that make up the screen. The \code{correction} operator is
#'   intended to be a display-specific correction factor to ensure the actual,
#'   physical size of the circle matches the diameters in the
#'   \code{$model$diam_on_screen} component of the model. This value can be
#'   determined using the \code{\link{looming_animation_calib}} function. See
#'   the documentation for this function for instructions on its use. If
#'   creating different animations, the \code{correction} value will be the same
#'   for a particular screen as long as the display resolution remains the same.
#'
#' @section Animation options: The circle colour and background can be specified
#'   using \code{fill} and \code{background} with standard base-R colour syntax
#'   as used in graphics functions such as \code{plot()} etc.
#'
#'   In your experiment you may want to identify the particular frame of the
#'   animation at which an event such as an escape response occurs. There are
#'   two ways of marking the animation so the frame can be identified in video
#'   recordings of the experiment:
#'
#'   \subsection{Frame numbers}{ The animation frame number can be placed in
#'   every frame using \code{frame_number = TRUE}. The colour, size, inset
#'   distance, and corner of the screen to place the number can be specified
#'   (see \code{Arguments}), and the orientation can be set with
#'   \code{frame_number_rotation}. In addition, text can be added to the start
#'   of the frame numbers using `frame_number_tag`. For example, with
#'   `frame_number_tag = "A-"`, frame numbers will follow the structure `A-1`,
#'   `A-2`, etc. This is useful if you create multiple animations and want to
#'   avoid getting them mixed up.}.
#'
#'   Frame numbers are also added to frames added for padding, although these
#'   follow their own numeric sequence and are also appended with "P" (see next
#'   section). Animation frame numbers will always refer to the correct row of
#'   the original model regardless of padding.
#'
#'   \subsection{Dots}{ If \code{dots = TRUE}, starting from the first animation
#'   frame a small dot is placed in the corner of the frame at the frame
#'   interval specified with \code{dots_interval}. It is also placed in the last
#'   frame, regardless of the \code{dots_interval}. Again, colour, size, inset
#'   distance and corner can be specified (see \code{Arguments}). }
#'
#'   These markers are only added to animation frames, not to frames added for
#'   padding (see next section). Use frame numbers if you need padding frames
#'   marked in some way.
#'
#'   \subsection{Start Marker}{ By default (\code{start_marker = TRUE}), a
#'   marker (an "X") is placed at the bottom centre of the screen in the first
#'   frame of the video, regardless of padding. This is a visual aid to allow
#'   you to see when the video has started to play: if it is not there, then the
#'   video has started playing. This is especially useful for videos that have
#'   been padded, and those without frame markers, as there may be no other
#'   indication the video is playing. The colour and size of the marker can be
#'   specified with \code{start_marker_colour} and \code{start_marker_size}.}
#'
#' @section Padding animations to a required duration: The video file can be
#'   extended to a required total duration using the \code{pad} option. This
#'   value is a duration in seconds added to the start of the animation before
#'   playback. It duplicates the starting frame of the animation the required
#'   number of times to achieve the padding duration. Essentially, this makes
#'   the animation static for \code{pad} seconds before it starts to play. This
#'   means the video may show a static circle until the animation starts. If you
#'   do not want this, either modify the model parameters until the initial
#'   diameter is negligible, or use the \code{pad_blank = TRUE} option, in which
#'   case blank frames will be added rather than duplicating the starting frame.
#'   Under this option, after \code{pad} seconds of blank screen, the animation
#'   will suddenly appear and play. Again, how noticable this is depends on the
#'   model parameters you have used. Note that frame numbers are also added to
#'   padding frames. These follow their own numeric sequence and are also
#'   appended with "P". Other tracking markers (i.e. dots) will only be added to
#'   animation frames, not to frames added for padding.
#'
#'   NOTE: Be careful with padding options. Padding the video with extra frames
#'   will increase the time it takes for the function to run. Finalise your
#'   animation options and parameters before padding it. If you need a long
#'   duration video, be aware that every frame png file generated is around
#'   40-50KB. Adding 10 minutes (600s) of padding to a video at 60 Hz will mean
#'   600*60 = 36000 extra frames generated. At ~45KB each this would require
#'   ~1.6GB of hard drive space, and require considerable time to process! Due
#'   to compression, the resulting video file should however be only a few MB in
#'   size.
#'
#' @section Looping animations: If you want the animation to loop or repeat a
#'   set number of times, use the `loop =` operator. If set with any value
#'   greater than the default of `1` this lets you output an additional video of
#'   the animation looped the set number of times. In this case there will be
#'   two output videos, the original `animation.mp4` (or whatever is set with
#'   the `filename` input) plus a looped version appended with `_loop.mp4`. This
#'   process is extremely fast, since it does not recreate the animation for
#'   each loop, but just copies the `animation.mp4` file the set number of times
#'   into a new video file.
#'
#'
#' @section Compatibility: The function should work with both Windows and macOS
#'   (Linux coming soon), however it requires \code{ffmpeg}
#'   (\url{http://ffmpeg.org}), an external, cross-platform, command line
#'   utility for encoding video, to be installed on your system. For
#'   installation instructions see
#'   \url{http://adaptivesamples.com/how-to-install-ffmpeg-on-windows/} (may
#'   need to restart) or
#'   \url{https://github.com/fluent-ffmpeg/node-fluent-ffmpeg/wiki/Installing-ffmpeg-on-Mac-OS-oX}
#'
#'
#'
#'
#'
#'   On Windows, if you encounter an error after installation (e.g. \code{unable
#'   to start png() device}), try setting the working directory with
#'   \code{setwd()} to the current or desired folder. It has not been
#'   extensively tested on Windows, so please provide feedback on any other
#'   issues you encounter.
#'
#' @section Playback in experiments: For triggered playback of the animation on
#'   a Mac I recommend Apple Quicktime Player. Playback can be started with the
#'   spacebar, the arrow keys allow frame-by-frame movement through the video,
#'   and Cmd-Left Arrow makes the video rewind to the start. Other applications
#'   such as VLC have quirks, for example automatically playing the video on
#'   opening the file, and closing it at the end of the video. However, find the
#'   application that works best for your purposes. If you need to loop the
#'   video, many video applications have an option for that. However, the `loop`
#'   operator (set with any value greater than 1) also lets you output an
#'   additional video of the animation looped the set number of times. In this
#'   case there will be two output videos, the original `animation.mp4` plus a
#'   looped version called `animation_loop.mp4`.
#'
#'   As a check, it's a good idea to ensure the application you use is correctly
#'   identifying the metadata of the video. This depends on the software, but in
#'   should be similar to the following: open the video file, pause it, make it
#'   fullscreen, and then:
#'
#'   In Quicktime, Cmd-I or Window > Show Movie Inspector. Check 'Format'
#'   matches 'Current Size', and that both match your entered screen resolution
#'   \code{width} and \code{height}. Check 'FPS' matches the \code{frame_rate}
#'   used to create the model in \code{\link{constant_speed_model}}.
#'
#'   In VLC, Cmd-I or Window > Media Information, the 'Codec Details' tab. Check
#'   'Resolution' and 'Display Resolution' both match your entered screen
#'   resolution \code{width} and \code{height} (there may be small differences,
#'   which is ok). Check 'Frame Rate' matches the \code{frame_rate} used to
#'   create the model in \code{\link{constant_speed_model}}. Make sure playback
#'   speed is at 'Normal' (Menu>Playback).
#'
#' @section Cleaning up: The package has been coded to clean up after itself.
#'   However, with heavy use occasionally orphaned png and mp4 files may remain
#'   in the various working directories, so it's a good idea to go through these
#'   periodically and manually delete unwanted files.
#'
#' @section Dependencies: The function requires the following packages:
#'   \code{glue}, \code{plotrix}, \code{stringr}
#'
#' @seealso \code{\link{constant_speed_model}},
#'   \code{\link{variable_speed_model}}, \code{\link{diameter_model}},
#'   \code{\link{looming_animation_calib}}.
#'
#' @param x list. A list object of class \code{constant_speed_model},
#'   \code{variable_speed_model}, or \code{diameter_model}.
#' @param correction numeric. Correction factor for the display used to play the
#'   animation. Default = 0.0285. Typically falls between 0.01-0.06. Exact value
#'   can be determined using \code{\link{looming_animation_calib}}
#' @param pad numeric. Duration in seconds to pad the start of the video. This
#'   replicates the first frame of the animation the required number of times to
#'   create this duration. Essentially, it makes the animation static for
#'   \code{pad} number of seconds before it starts playing (but see
#'   \code{pad_blank}).
#' @param pad_blank logical. Optionally pad with blank frames rather than the
#'   first animation frame.
#' @param width integer. Width resolution of the display. E.g. for a display set
#'   at 1080p resolution (1920x1080), this is \code{width = 1920}. Note: this is
#'   NOT the native resolution, but the display resolution as set in the
#'   operating system settings. Visit \url{https://whatismyscreenresolution.com}
#'   on the playback display to check.
#' @param height integer. Height resolution of the display. E.g. for a display
#'   set at 1080p resolution (1920x1080), this is \code{height = 1080}. Note:
#'   this is NOT the native resolution, but the display resolution as set in the
#'   operating system settings. Visit \url{https://whatismyscreenresolution.com}
#'   on the playback display to check.
#' @param fill string. Colour of the circle.
#' @param background string. Colour of the background.
#' @param dots logical. Controls if frame tracking dots are added to animation
#'   frames (see Details).
#' @param dots_interval numeric. Interval in frames from first animation frame
#'   when dots are added.
#' @param dots_colour string. Colour of dots
#' @param dots_position string. Corner in which to display dots: \code{tr},
#'   \code{tl}, \code{br}, \code{bl}, indicating top right, top left, bottom
#'   right, or bottom left.
#' @param dots_size numeric. Size of added dots. Default = 0.005.
#' @param dots_inset numeric. Distance of dots from edges of frame as proportion
#'   of entire width/height. Default = 0.05.
#' @param frame_number logical. Controls if frame numbers are added to animation
#'   frames (see Details).
#' @param frame_number_tag string. Text string to be added to the start of the
#'   frame numbers, e.g. '1-' or 'A-'. Useful for distinguishing between
#'   different animations.
#' @param frame_number_colour string. Colour of frame numbers
#' @param frame_number_position string. Corner in which to display frame
#'   numbers: \code{tr}, \code{tl}, \code{br}, \code{bl}, indicating top right,
#'   top left, bottom right, or bottom left.
#' @param frame_number_size numeric. Size of frame numbers as proportion of
#'   default plotting text size. Default = 2.
#' @param frame_number_rotation numeric. Value in degrees (0-360) to rotate
#'   frame numbers.
#' @param frame_number_inset numeric. Distance of frame numbers from edges of
#'   frame as proportion of entire width/height. Increase this if frame numbers
#'   start to run off the edge of the screen as they get larger. Default = 0.05.
#' @param start_marker logical. Controls if a marker ("X") is added to the first
#'   frame. This is a visual aid: if it disappears it indicates the video is
#'   playing.
#' @param start_marker_colour logical. Colour of the \code{start_marker}
#' @param start_marker_size logical. Size of the \code{start_marker} as
#'   proportion of default plotting text size. Default = 2.
#' @param loop integer. Default = 1. This sets the number of times to repeat the
#'   animation. Any value of 2 or higher will mean an additional video file is
#'   created called `animation_loop.mp4` with the original animation (including
#'   any padding) repeated this number of times.
#' @param pause numeric. Default = 0. For slow PCs a delay can be added to
#'   ensure the filesystem is not overloaded by having to write so many image
#'   files. This adds a delay (in seconds) to the generation of each frame. E.g.
#'   for a 600 frame video, 'pause = 0.05' will add an *additional* 30 seconds
#'   (600 * 0.05) to the total time taken.
#' @param save_data logical. If \code{=TRUE}, exports to the current working
#'   directory a \code{.csv} file containing the data used to make the
#'   animation, including the column of values scaled using the
#'   \code{correction} value. File name: \code{ANIM_from_**name of R object
#'   used**_**frame rate**_**display resolution**.csv}
#' @param save_images logical. If \code{=TRUE}, does not delete image files
#'   after the animation video is created.
#' @param filename string. Desired name of the output file without file
#'   extension. Default is `animation`, and output file is `animation.mp4`. Also
#'   used for looped video output, if the `loop` operator is used.
#'
#' @examples
#' # uncomment to run
#' # make a looming model
#' # loom_model <- constant_speed_model(
#' #                      screen_distance = 20,
#' #                      frame_rate = 60,
#' #                      speed = 500,
#' #                      attacker_diameter = 50,
#' #                      start_distance = 1000)
#'
#' # use it to create an animation with frame numbers in top right corner
#' # looming_animation(loom_model,
#' #                   correction = 0.0285,
#' #                   width = 1920,
#' #                   height = 1080,
#' #                   frame_number = TRUE,
#' #                   frame_number_position = "tr",
#' #                   frame_number_size = 2)
#'
#' # pad animation with 5 seconds of the starting frame before playback
#' # looming_animation(loom_model,
#' #                    correction = 0.0285,
#' #                    width = 1920,
#' #                    height = 1080,
#' #                    frame_number = TRUE,
#' #                    frame_number_position = "tr",
#' #                    frame_number_size = 2,
#' #                    pad = 5)
#'
#' @author Nicholas Carey - \email{nicholascarey@gmail.com}
#'
#' @importFrom glue glue
#' @importFrom plotrix draw.circle
#' @importFrom stringr str_match
#' @importFrom grDevices dev.off png
#' @importFrom graphics arrows par plot.new rect text
#' @importFrom utils write.csv
#'
#' @export

## To Do
## gif export option? - would be gigantic for long videos
## option to NOT convert images using ffmpeg, but save them

## optimisations
# use apply instead of loop
# faster way of padding? rather than looping for padded frames, duplicating
# that frame more quickly in file system?
# play with ffmpeg options to reduce file size of pngs

## test
## really big padding on windows - that it works and deletes successfully

looming_animation <-

  function(x,
           correction = 0.0285,
           width = 1280,
           height = 1024,
           fill = "black",
           background = "white",
           pad = NULL,
           pad_blank = FALSE,
           dots = FALSE,
           dots_interval = 20,
           dots_colour = "grey",
           dots_position = "br",
           dots_size = 0.005,
           dots_inset = 0.05,
           frame_number = FALSE,
           frame_number_tag = NULL,
           frame_number_colour = "grey",
           frame_number_position = "tr",
           frame_number_size = 2,
           frame_number_rotation = 0,
           frame_number_inset = 0.05,
           start_marker = TRUE,
           start_marker_colour = "black",
           start_marker_size = 2,
           loop = 1,
           pause = 0,
           save_data = FALSE,
           save_images = FALSE,
           filename = "animation"){

    ## check class
    if(!any(class(x) %in% c("constant_speed_model", "variable_speed_model", "diameter_model")))
      stop("Input must be an object of class 'constant_speed_model', 'variable_speed_model', or 'diameter_model'")

    ## class detection message - assists with testing
    if(class(x) == "constant_speed_model"){
      message("constant_speed_model detected.")
    } else if(class(x) == "variable_speed_model"){
      message("variable_speed_model detected.")
    } else if(class(x) == "diameter_model"){
      message("diameter_model detected.")}

    ## check loop is an integer
    if(loop %% 1 != 0)  stop("loop input must be an integer")

    ## check for odd numbered screen resolutions, and if so add a pixel
    ## odd numbers cause "not divisible by 2" error in ffmpeg
    if(width %% 2 != 0){
      width <- width +1
      message(glue::glue("Screen `width` cannot be an odd number."))
      message(glue::glue("Screen `width` modified to {width}."))
    }
    if(height %% 2 != 0){
      height <- height +1
      message(glue::glue("Screen `height` cannot be an odd number."))
      message(glue::glue("Screen `height` modified to {height}"))
    }

    ## check pause is not too high, since it will massively increase the time
    ## taken
    if(pause >= 0.5) warning("The `pause` value is quite high.\nGenerally, it is not necessary to pause for more than a few milliseconds per frame, e.g. 'pause = 0.05'.")


    # Extract data and parameters ---------------------------------------------
    cs_model <- x$model
    frame_rate <- x$frame_rate

    ## get total frames of the animation - useful later for adding frame markers
    total_frames_anim <- nrow(cs_model)


    # Padding -----------------------------------------------------------------

    ## use pad to duplicate starting frame the required number of times
    ## this modifies the input 'constant_speed_model' cs_model and replaces it
    if(!is.null(pad)){

      # If pad_blank is not TRUE
      # replicates first diam_on_screen value required number of times and adds rest of diam_on_screen
      if(!isTRUE(pad_blank)){
        temp_diam_on_screen <- c(rep(cs_model$diam_on_screen[1], ceiling(pad*frame_rate)), cs_model$diam_on_screen)
        # otherwise set the diameter to Zero for those frames to achieve a blank frame
      } else {
        temp_diam_on_screen <- c(rep(0, ceiling(pad*frame_rate)), cs_model$diam_on_screen)
      }


      temp_distance <- c(rep(cs_model$distance[1], ceiling(pad*frame_rate)), cs_model$distance)
      temp_frame <- seq(1, length(temp_diam_on_screen), 1)
      temp_time <- temp_frame/frame_rate
      temp_alpha <- c(rep(cs_model$alpha[1], ceiling(pad*frame_rate)), cs_model$alpha)
      temp_dadt <- c(rep(cs_model$dadt[1], ceiling(pad*frame_rate)), cs_model$dadt)

      ## make new padded model
      padded_model <- data.frame(
        temp_frame,
        temp_time,
        temp_distance,
        temp_alpha,
        temp_dadt,
        temp_diam_on_screen
      )

      names(padded_model) <- names(cs_model)

      cs_model <- padded_model

      ## check padded successfully
      if(nrow(cs_model) != total_frames_anim + ceiling(pad*frame_rate)){
        stop("Something has gone wrong with padding. ")
      }

    }


    # Total Frames ------------------------------------------------------------

    ## total frames
    total_frames <- nrow(cs_model)


    # Correct diameters -------------------------------------------------------

    ## use correction factor to modify diameters
    if(!is.null(correction)){
      cs_model$diam_on_screen_corrected <- cs_model$diam_on_screen * correction
    } else {
      cs_model$diam_on_screen_corrected <- cs_model$diam_on_screen
    }


    # Loop to create images ---------------------------------------------------

    for(i in 1:total_frames){

      # create filename with leading zeros up to 6 numerals total
      name <- paste0("loom_img_", sprintf("%06d", i), ".png")

      # make png file
      png(name, width=width, height=height, res=72)

      # create new plot
      par(mar=c(0,0,0,0), bg=background)
      plot.new()

      # make circle - centered
      plotrix::draw.circle(x=0.5, y=0.5,
                           ## NOTE - use corrected column
                           r <- cs_model$diam_on_screen_corrected[i]/2,
                           nv=100,
                           border=fill,
                           col=fill,
                           lty=1,lwd=1)

      ## add start marker
      if(start_marker == TRUE && i == 1){

        text("X",
             col = start_marker_colour,
             x = 0.5,
             y = 0.1,
             cex = start_marker_size)}

      ## add dots
      ## only to animation frames
      ## - if i is greater than or equal to this, then it's the start of the animation

      ## get animation start frame
      asf <- total_frames - total_frames_anim +1
      ## get animation frame for this iteration
      af <- total_frames_anim - (total_frames - i)

      if(dots == TRUE && i >= asf){
        ## set x and y coords from position
        dots_x_pos <- right(dots_position, 1)
        dots_y_pos <- left(dots_position, 1)

        # set x position
        if(dots_x_pos == "l"){
          dots_x_coord <- dots_inset
        } else if(dots_x_pos == "r"){
          dots_x_coord <- 1 - dots_inset
        }

        # set y position
        if(dots_y_pos == "b"){
          dots_y_coord <- dots_inset
        } else if(dots_y_pos == "t"){
          dots_y_coord <- 1 - dots_inset
        }

        ## draw dot in corner of first animation frame
        if(i == asf){plotrix::draw.circle(x=dots_x_coord, y=dots_y_coord,
                                          r <- dots_size,
                                          nv=100,
                                          border=dots_colour,
                                          col=dots_colour,
                                          lty=1,
                                          lwd=1)}

        # draw dot in corner every nth animation frame
        if(af %% dots_interval == 0) {plotrix::draw.circle(x=dots_x_coord, y=dots_y_coord,
                                                           r <- dots_size,
                                                           nv=100,
                                                           border=dots_colour,
                                                           col=dots_colour,
                                                           lty=1,
                                                           lwd=1)}

        # draw dot in corner of last frame
        if(i == total_frames) {plotrix::draw.circle(x=dots_x_coord, y=dots_y_coord,
                                                    r <- dots_size,
                                                    nv=100,
                                                    border=dots_colour,
                                                    col=dots_colour,
                                                    lty=1,
                                                    lwd=1)}
      }


      ## add frame numbers to padded frames
      if(frame_number == TRUE && i < asf){
        ## set x and y coords from position
        fn_x_pos <- right(frame_number_position, 1)
        fn_y_pos <- left(frame_number_position, 1)

        if(fn_x_pos == "l"){
          fn_x_coord <- frame_number_inset
        } else if(fn_x_pos == "r"){
          fn_x_coord <- 1 - frame_number_inset
        }

        if(fn_y_pos == "b"){
          fn_y_coord <- frame_number_inset
        } else if(fn_y_pos == "t"){
          fn_y_coord <- 1 - frame_number_inset
        }

        ## make frame number label
        ## with frame number prepend label
        ## NOTE - can't use 'i' alone since it include padded frames
        ## must use this code to get actual animation frame
        text(labels = paste0(frame_number_tag, i, "P"),
             col = frame_number_colour,
             x = fn_x_coord,
             y = fn_y_coord,
             cex = frame_number_size,
             srt = frame_number_rotation)
      }

      ## add frame numbers to animation frames
      if(frame_number == TRUE && i >= asf){

        ## set x and y coords from position
        fn_x_pos <- right(frame_number_position, 1)
        fn_y_pos <- left(frame_number_position, 1)

        if(fn_x_pos == "l"){
          fn_x_coord <- frame_number_inset
        } else if(fn_x_pos == "r"){
          fn_x_coord <- 1 - frame_number_inset
        }

        if(fn_y_pos == "b"){
          fn_y_coord <- frame_number_inset
        } else if(fn_y_pos == "t"){
          fn_y_coord <- 1 - frame_number_inset
        }

        ## make frame number label
        ## with frame number prepend label
        ## NOTE - can't use 'i' alone since it include padded frames
        ## must use this code to get actual animation frame
        text(labels = paste0(frame_number_tag, af),
             col = frame_number_colour,
             x = fn_x_coord,
             y = fn_y_coord,
             cex = frame_number_size,
             srt = frame_number_rotation)
      }

      ## clear plot before next loop
      dev.off()

      ## Generate progress message
      perc_done <- round(i/total_frames*100)
      image_progress(perc_done)

      ## pause
      Sys.sleep(pause)

    } # end loop


    # Export data -------------------------------------------------------------

    if(save_data == TRUE){
      exp_filename <- glue::glue('ANIM_from_',
                                 deparse(quote(x)),
                                 '_',
                                 {frame_rate},
                                 'fps_',
                                 {width},
                                 'x',
                                 {height},
                                 '.csv'
      )

      write.csv(cs_model, file = glue::glue(exp_filename))
    }


    # Run ffmpeg command ------------------------------------------------------

    ## Add 5 second delay (for slow PCs to make sure file system has updated )
    for(i in 1:10){
      prep_progress(i, max = 10)
      Sys.sleep(0.5)}

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
      message("Encoding movie...")
      instruction_string <-
        glue::glue(
          ## rm loom_img_*.png'
          ## old remove command above - ran into Terminal "Argument list too long" error when there were huge numbers of files
          ## this seems to work ok
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%06d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p {filename}.mp4'
        )
      ## run the command
      system(instruction_string)

      if(isFALSE(save_images)){
        message("\nDeleting image files...")
        system('find . -maxdepth 1 -name "loom_img_*.png" -delete')
      }
    }

    ## For Windows
    ## NOTE - command changed to remove deletion instruction at end
    ## For some reason Windows needs to run this via the shell() command
    else if(os() == "win"){
      message("Encoding movie...")
      instruction_string <-
        glue::glue(
          'ffmpeg -y -r {frame_rate} -f image2 -s {width}x{height} -i loom_img_%06d.png -vcodec libx264 -crf 25  -pix_fmt yuv420p {filename}.mp4'
        )

      ## run command
      system(instruction_string)

      if(isFALSE(save_images)){
        message("\nDeleting image files...")
        ## delete png files
        shell("del loom_img_*.png")
      }
    }

    ## calculate and round duration for message
    duration <- total_frames/frame_rate
    ## this rounds it to 2 decimal places, even if they are zeros.
    ## i.e. 2.001 gets displayed as "2.00s" not "2s"
    duration <- sprintf('%.2f', duration)
    duration_loop <- sprintf('%.2f', total_frames/frame_rate*loop)

    ## make looped video
    if(loop > 1){
      loop_n <- loop-1
      instruction_string <- glue::glue(
        'ffmpeg -y -stream_loop {loop_n} -i {filename}.mp4 -c copy {filename}_loop.mp4')
      system(instruction_string)
    }

    ## make message (blank line first, to make it more noticable from ffmpeg output)
    message("")
    cat("\n# Conversion complete # -------------------------\n")
    message(glue::glue('Resulting {filename}.mp4 video should be {duration}s in duration.'))
    if(loop > 1) cat("\n# Looped video created # ------------------------\n")
    if(loop > 1) message(glue::glue('Resulting {filename}_loop.mp4 video should be {duration_loop}s in duration and contain {loop} loops.'))
    message("")
    message('Any ffmpeg errors should be listed above')


    # Check total frames of video are correct ---------------------------------
    ## check and save video metadata
    ffmpeg_log <- suppressWarnings(system2(command = "ffmpeg", args = glue::glue("-i {filename}.mp4 -map 0:v:0 -c copy -f null -"), stderr = TRUE))

    ## where is total frames within metadata
    frames_loc <- grep("\rframe=", ffmpeg_log)

    ## Extract, trim white space and convert to numeric
    n_frames <- stringr::str_match(ffmpeg_log[frames_loc], "\rframe= (.*?) fps=")
    n_frames <-trimws(n_frames[,2])
    n_frames <- as.numeric(n_frames)

    if(n_frames != total_frames) warning("\nWARNING: \nTotal number of frames in the output video does not match total number in model.\nSome frames may have been dropped during conversion.\nTry using 'pause' to slow down the function.")


  }

