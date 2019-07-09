
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/loomeR)](https://cran.r-project.org/package=loomeR)
[![Travis build
status](https://travis-ci.org/nicholascarey/loomeR.svg?branch=master)](https://travis-ci.org/nicholascarey/loomeR)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/nicholascarey/loomeR?branch=master&svg=true)](https://ci.appveyor.com/project/nicholascarey/loomeR)
[![Coverage
status](https://codecov.io/gh/nicholascarey/loomeR/branch/master/graph/badge.svg)](https://codecov.io/github/nicholascarey/loomeR?branch=master)
[![license](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1212570.svg)](https://doi.org/10.5281/zenodo.1212570)
[![HitCount](http://hits.dwyl.io/nicholascarey/loomeR.svg)](http://hits.dwyl.io/nicholascarey/loomeR)

# Welcome

`loomeR` is an `R` package for creating looming animations for use in
behavioural and neurological experiments, and analysing escape
responses, for example the Apparent Looming Threshold (**ALT**) of an
escape (*Dill 1974, Webb 1982*). Looming animations are used in a range
of physiological, psychological and behavioural sciences to simulate an
approaching threat and investigate phenomena such as perception, visual
latency, escape responses, and neurological functioning. **ALT** is a
metric which describes the threshold where a specimen may initiate an
escape movement based on a combination of the perceived distance and/or
speed of an oncoming threat.

<p align="center">

<iframe src="https://player.vimeo.com/video/267812726" width="640" height="480" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen>

</iframe>

</p>

See the
[Reference](https://nicholascarey.github.io/loomeR/reference/index.html)
page to view the detailed Help file for each function.

### Installation

`loomeR` is not yet published on CRAN, but can be installed using the
`devtools` package:

``` r
install.packages("devtools")
devtools::install_github("nicholascarey/loomeR")
```

### Usage

Using the package is straightforward:

#### 1\. Create an animation model

``` r
diameter_model(), constant_speed_model(), variable_speed_model()
```

The package can create simple or complex animations in three ways:

  - Use of basic inputs: enter start and end screen diameters, and total
    duration.
  - Use of realistic parameters: the function will determine the correct
    screen diameters for each animation frame using…
      - **Constant speed**: specify a constant speed, size, and starting
        distance of the hypothetical oncoming threat
      - **Variable speed**: provide a profile of variable speeds, plus
        size and starting distance of the oncoming threat <br> <br>

#### 2\. Create an animation from the model

``` r
looming_animation()
```

To create the animation from the model, `loomeR` requires
[ffmpeg](http://ffmpeg.org), a free, cross-platform, command-line
utility for encoding video to be installed on your system. This
currently works in `R` on **macOS** and **Windows**. Support for
**Linux** is planned: please [get in
touch](mailto:nicholascarey@gmail.com) if you would like to help with
testing on Linux systems.

Many options are available to customise the animation; specifying a
frame rate, modifying the colour and background, padding the video with
blank frames to a desired total duration, marking frames to assist with
identifying when escape responses occur, and more. <br> <br>

#### 3\. Analyse escape responses

``` r
get_alt()
```

This function calculates the viewing angle, alpha (**α**), for each
frame in the animation, and the change in this viewing angle per unit
time (**dα/dt** in radians/second) (*Dill 1974*). Given a response frame
the *Apparent Looming Threshold* (**ALT**, *Webb 1982*) can be
determined. These metrics can all be corrected for different viewing
distances if the specimen has moved to a different distance from the
screen, which will affect the perceived **α** and thus **ALT**. The new
perceived speed and distance for the different viewing distance are also
returned. A visual response latency (i.e. to account for neurological
lag in response time) can also be applied. <br> <br>

### Example code

The included
[documentation](https://nicholascarey.github.io/loomeR/reference/index.html)
is comprehensive, and a vignette explaining how to use the package is in
preparation. For a quick evaluation try out the following code:

##### 1\. Create a model

``` r
library(loomeR) # load the package

# Simple constant speed model
# (speed in cm/s, frame rate in Hz, all other inputs in cm)

x <- constant_speed_model(
  screen_distance = 20,    # How far from the screen is your observing specimen?
  frame_rate = 60,         # Frame rate you want the final animation to be 
  speed = 500,             # Speed of the simulated oncoming object
  attacker_diameter = 50,  # Diameter of the simulated oncoming object
  start_distance = 1000)   # Starting distance of the simulated oncoming object
```

##### 2\. Use the model to create the animation

``` r
looming_animation(x)
```

##### 3\. Extract the ALT

``` r
# E.g. from response frame 100, and applying a response latency of 60 milliseconds
get_alt(x, response_frame = 100, latency = 0.06)
#> 
#> Extraction complete. 
#>  
#> Response Frame:            100
#> Response Frame Adjusted:   96
#> Latency Applied:           0.06s
#>  
#> The Apparent Looming Threshold is: 
#> ALT: 0.5911 radians/sec
```

### Forthcoming and potential features

  - [x] Function to extract model parameters at a particular frame,
    optionally apply a latency correction, and correct the perceived
    speed and distance for a different viewing distance. **DONE** - see
    `get_alt`
  - [ ] Linux support
  - [ ] Add a receding option for animations (possibly works by setting
    speed as a negative, or start/end diameters the other way round, but
    this has not been tested)
  - [ ] Enhancements (e.g. quicker padding method) and alternative to
    `ffmpeg`
  - [ ] Option to export images only, and not convert them
  - [ ] Option to subsample or interpolate variable speed profiles to
    match a desired frame rate
  - [ ] Use of custom shapes (please [contact
    me](mailto:nicholascarey@gmail.com) if you know of actual
    applications for this… it would be a *lot* of work)

### Feedback

If you have any bugs or feedback, you can contact me via
[email](mailto:nicholascarey@gmail.com), or by [opening an
issue](https://github.com/nicholascarey/loomeR/issues).

### Acknowledgements

Working with the following people inspired the creation of this package:

  - Paolo Domenici, CNR IAMC, Italy.
    [Link](http://iamc.objectis.net/staff/domenici-paolo)
  - Jeremy Goldbogen & Dave Cade, Hopkins Marine Station, Stanford
    University. [Link](http://goldbogen.stanford.edu)
  - Januar Harianto, University of Sydney
    [Link](https://github.com/januarharianto)

### Cite

If you use `loomeR` in your work, a citation using this zenodo DOI would
be much appreciated:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1212570.svg)](https://doi.org/10.5281/zenodo.1212570)

Or run this code:

``` r
citation("loomeR")
#> 
#> To cite package 'loomeR' in publications use:
#> 
#>   Nicholas Carey (2019). loomeR: Looming Animations for Use in
#>   Behavioural and Neurological Experiments.
#>   https://github.com/nicholascarey/loomeR,
#>   https://doi.org/10.5281/zenodo.1212570.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {loomeR: Looming Animations for Use in Behavioural and Neurological Experiments},
#>     author = {Nicholas Carey},
#>     year = {2019},
#>     note = {https://github.com/nicholascarey/loomeR, https://doi.org/10.5281/zenodo.1212570},
#>   }
#> 
#> ATTENTION: This citation information has been auto-generated from
#> the package DESCRIPTION file and may need manual editing, see
#> 'help("citation")'.
```

If you don’t have the space to cite it, not a problem, but please do
**[let me know](mailto:nicholascarey@gmail.com)** if you use it in your
experiments. I would love to keep an updated list of studies which have
made use of it, and I can help publicise your paper by tweeting about
it\!

### References

Dill, Lawrence M, 1974. The escape response of the zebra danio
(Brachydanio rerio) I. The stimulus for escape. Animal Behaviour 22,
711–722. <https://doi.org/10.1016/S0003-3472(74)80022-9>

Webb, P.W., 1982. Avoidance responses of fathead minnow to strikes by
four teleost predators. J. Comp. Physiol. 147, 371–378.
<https://doi.org/10.1007/BF00609671>

Gibson, J. J. (2014) The Ecological Approach to Visual Perception:
Classic Edition. Psychology Press. (2014).

Domenici, P. (2002). The visually mediated escape response in fish:
predicting prey responsiveness and the locomotor behaviour of predators
and prey. Marine and Freshwater Behaviour and Physiology, 35(1–2),
87–110. <https://doi.org/10.1080/10236240290025635>

Muijres, F. T., Elzinga, M. J., Melis, J. M., & Dickinson, M. H. (2014).
Flies evade looming targets by executing rapid visually directed banked
turns. Science, 344(6180), 172–177.
<https://doi.org/10.1126/science.1248955>

Peron, S., & Gabbiani, F. (2009). Spike frequency adaptation mediates
looming stimulus selectivity in a collision-detecting neuron. Nature
Neuroscience, 12, 318. <http://dx.doi.org/10.1038/nn.2259>
