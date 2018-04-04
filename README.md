# Welcome

`loomeR` is an R package for creating looming animations for use in behavioural and neurological experiments. Looming animations are used in a range of physiological, psychological and behavioural sciences to simulate an approaching predator and to investigate phenomena such as perception, visual latency, predator responses, and neurological functioning. 

The package can create a simple animation of a desired duration with inputs for starting and end screen diameters. However, it also allows the precise details of the animation to be controlled to simulate precise speeds or distances of the hypothetical oncoming predator. 

Many other options are available, such as modifying the colour and background of the animation, padding the video to a desired total duration, marking frames to assist with identifying when escape responses occur, and more. 

Note, `loomeR` currently only works on Mac and Windows, and requires [ffmpeg](http://ffmpeg.org), a free, cross-platform command-line utility for encoding video, to be installed on your system. Linux support is planned: please [get in touch](nicholascarey@gmail.com) if you would like to help with implementing that. 

## Installation
`loomeR` is not yet published on CRAN, but can be installed using the `devtools` package:

```r
install.packages("devtools")
devtools::install_github("nicholascarey/loomeR")
```

## Usage

The included documentation is comprehensive, and a vignette explaining how to use the package is in preparation. For a quick evaluation try out the following code:

```r
library(loomeR) # load the package

# 1. Create a model

# Simple constant speed model
# (all inputs are in cm, speed in cm/s, frame rate in Hz)

x <- constant_speed_model(
  screen_distance = 20,    # How far from the screen is your observing specimen?
  anim_frame_rate = 60,    # Frame rate you want the final animation to be 
  speed = 500,             # Speed of the simulated oncoming object
  attacker_diameter = 50,  # Diameter of the simulated oncoming object
  start_distance = 1000)   # Starting distance of the simulated oncoming object


# 2. Use the model to create the animation
looming_animation(x)

```

## Forthcoming features

- [ ] Linux support
- [ ] Add a receding option for animations (possibly this works by setting speed as a negative, or start/end diameters the other way round, but this has not been tested)
- [ ] Function to extract model parameters at a particular frame, and optionally apply a latency correction, or correct the perceived speed and distance for a different viewing distance. 
- [ ] Enhancements (e.g. better padding method) and alternatives to `ffmpeg`

## Feedback

If you have any bugs or feedback, you can contact me via [email](nicholascarey@gmail.com), or by [opening an issue](https://github.com/nicholascarey/loomeR/issues). 

# Acknowledgements

Working with the following people inspired the creation of this package:

- Paolo Domenici, CNR IAMC, Italy.  [Link](http://oristano.iamc.cnr.it/IAMC/staff/paolo-domenici/domenici-paolo?set_language=en)
- Dave Cade, Hopkins Marine Station, Stanford University. [Link](http://goldbogen.stanford.edu)
- Januar Harianto [Link](https://github.com/januarharianto)

# Cite
If you use `loomeR` in your work, it would be nice if you cite it using this zenodo DOI:

DOI

Even if you don't cite it, please let me [know](nicholascarey@gmail.com) if you use it in your experiments. I would love to keep an updated list of studies which have made use of it, and I can help publicise your study by tweeting about it! 

# References

James J. Gibson, The Ecological Approach to Visual Perception: Classic Edition. Psychology Press. (2014).


