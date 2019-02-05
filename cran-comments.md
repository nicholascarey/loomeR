## Test environments
* local macOS 10.14.2 install, R 3.5.2
* remote macOS 10.13.3 (on travis-ci), R 3.5.2
* remote ubuntu 14.04 (on travis-ci), R 3.5.2
* remote Windows Server 2012 R2 x64 (build 9600) (on appveyor), R 3.5.2

## R CMD check results
There were no ERRORs or WARNINGs. 

There were 2 NOTEs: 
(only when CMD Check is run in terminal, none in RStudio)

* checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Nicholas Carey <nicholascarey@gmail.com>’

New submission

Package has a VignetteBuilder field but no prebuilt vignette index.

* checking examples ... NOTE
Examples with CPU or elapsed time > 5s
                          user system elapsed
looming_animation       35.952  3.030  37.063
looming_animation_calib  5.862  1.017   7.802

