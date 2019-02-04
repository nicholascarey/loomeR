## Test environments
* local macOS 10.14.2 install, R 3.5.2
* remote macOS 10.13.3 (on travis-ci), R 3.5.2
* remote ubuntu 14.04 (on travis-ci), R 3.5.2
* remote Windows Server 2012 R2 x64 (build 9600) (on appveyor), R 3.5.2

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 0 NOTEs:

## Downstream dependencies
I have also run R CMD check on downstream dependencies of httr 
(https://github.com/wch/checkresults/blob/master/httr/r-release). 
All packages that I could install passed except:

* Ecoengine: this appears to be a failure related to config on 
  that machine. I couldn't reproduce it locally, and it doesn't 
  seem to be related to changes in httr (the same problem exists 
  with httr 0.4).
