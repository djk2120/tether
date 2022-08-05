# tether.sh 

A utility to tether cesm cases


## cheyenne.template
 - template for each queued tether submission
 - you will need to edit this
   - specify your project code
   - tell it where to expect tether.sh (tdir)
 - tether.sh will search and replace for jobname/joblist/jobid
   - dont change those!
 
## example/joblist.txt
 - file to define your run sequence
 - jobname,caseroot,helper_script,status
 - all helper scripts must be executable!
 - status progresses from waiting->queued->submitted
 - joblist should be in order, with first job queued, and the rest waiting

## helper scripts
 - each script will run before its associated case
   - edit namelists, case.build, etc
 - case must be created before calling tether
 - do not include case.submit in the helper scripts
   - tether is responsible for submitting the case

## tether.sh
 - the workhorse script
 - takes joblist and template as command line arguments
 - e.g. 
   - ./tether.sh joblist.txt cheyenne.template
 - should not need to edit this script
 - its job is to:
   - run the appropriate helper script
   - call ./submit.case --resubmit-immediate from the current case
   - queue the next case in line
   - update the statuses in joblist.txt

## directory structure
 - put your joblist and shell scripts together in one directory, need not be nested within this directory
 - call tether.sh from within THAT directory
 - e.g. for my example here, cd example, and then:
   - ../tether.sh joblist.txt ../cheyenne.template

## logs
 - the first segment will write to stdout
 - tethered segments will write to their own files: jobname.oXXX

