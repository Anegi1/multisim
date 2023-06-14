#!/bin/bash

#./llh.sh 0 Amp_0+0p0000.dat 36 1 3 /data/ana/NuFSGenMC/MultiSim/MultisimOutputs/Constraints/Models/models/Amp/0/


eval `/cvmfs/icecube.opensciencegrid.org/py3-v4.2.1/setup.sh`

ppcbase=/home/anegi/multisim/ppc  #path to ppc
ice=$ppcbase/ice/spice_ftp-v2/    #path to ice model directory (must have central icemodel and all ice configuration files)
ppc=$ppcbase/gpu/ppc
. $ppcbase/ocl/src
. $ppcbase/llh/src

cp $ppcbase/llh/cdom.txt .
cp $ppcbase/llh/list.bad .
strings=36

if [ -z ${_CONDOR_SCRATCH_DIR+x} ]
then
    mkdir "/scratch/$USER"
    BaseDir="/scratch/$USER"
else
    BaseDir=$_CONDOR_SCRATCH_DIR
fi
echo "Basedir= $BaseDir"
#creating a directory in scratch to store temperory files 

m=0
k=$[$1+0]
a=$1                 #0
q=$2                 #perturbed icemodel file name(perturbed_model.dat)
s=$3                 #string to flash (0-86)
lowdom=$4            # lowest DoM on string $3 to flash (1-60)
highdom=$5           # highest DoM on string $3 to flash (1-60)
ICEM="/$6/"          # absolute path to perturbed ice models directory
#Ice_models_path=/data/ana/NuFSGenMC/MultiSim/MultisimOutputs/Constraints/Models/models/Amp/0/Amp_0+0p0500.dat  

#echo $ICEM
ICEM+=$2            
echo $ICEM            #make sure the path points to the perturbed icemodel 
if test "$FWID" = ""; then FWID=12; fi
if test "$SREP" = ""; then SREP=10; fi

echo "SHIFT $q"
#echo $LD_LIBRARY_PATH
for b in $q""; do
echo $b
n=0

for str in $strings; do

    det=86
  if test $str == $s; then 
      echo "STRING $str"
      #Add another 1 here for PPC LLH startup issue: for dom in `seq 1$lowdom $highdom`; do
      for dom in `seq $lowdom $highdom`; do
	fla=${str}_$dom
	dat=$ppcbase/dat/all/oux.$fla       # this path should contain flasher data files for each string and DoM

	if test -e $dat; then 
	    echo -e "\nDOM $dom" 
	    if ! test -e $BaseDir/fit.$b-$n; then
		mkdir $BaseDir/fit.$b-$n
        mkdir $BaseDir/fit.$b-$n/ice/
	    fi
	    num=`cat $ppcbase/dat/all/num.$fla`
	#    num=10
   
	    echo $fla > $BaseDir/fit.$b-$n/fla
	    ln -sf $dat $BaseDir/fit.$b-$n/dat
        cp $ice/* $BaseDir/fit.$b-$n/ice
        ln -sf $ICEM $BaseDir/fit.$b-$n/ice/icemodel.dat
	    ln -s $ppcbase/llh/llh $BaseDir/fit.$b-$n/llh

        
            ( cat $ice/bad-f2k $ppcbase/dat/detector/bad.ic$det; echo $str $dom; awk '$1=='$str' && $2=='$dom' {print $3, $4}' list.bad ) > $BaseDir/fit.$b-$n/bad
	    echo "Running"
	    here=$PWD
 #       echo $here
	    cd $BaseDir/fit.$b-$n
#        echo $PWD
	    PPCTABLESDIR=$BaseDir/fit.$b-$n/ice FWID=$FWID SREP=$SREP DREP=$num FLSH=${str},$dom FAIL=1 FAST=1 MLPD=0 CYLR=1 FLOR=0 FSEP=1 GSL_RNG_SEED=$RANDOM ./llh $m 2> $BaseDir/tmpf
	    head -n 20 $BaseDir/tmpf
	    tail -n 10 $BaseDir/tmpf
	    rm tmp
	    cd $here
	    
	    n=$[$n+1]
	fi
    done
  fi

done
done

set -o pipefail

echo "done"

