#!/bin/bash

#./setup.sh  /data/user/anegi/ppc/ice/spice_bfr-v2/models/ Amp/0/



d=$1                    # absolute path to the directory containing all perturbed ice models
# $1= /data/user/anegi/ppc/models or #/data/user/anegi/ppc/models_3sigma/
d+=$2                   #relative path from $1 to the icemodels perturbed in required Fourier mode 
# $2= Amp/0/ or #AmpPhs/
echo $d
cd $d
timenow=`date +%s`




if ! test -e /home/$USER/ppc_logs/; then
mkdir /home/$USER/ppc_logs/
fi

if ! test -e /home/$USER/ppc_condor/; then
mkdir /home/$USER/ppc_condor/
fi

#only use for uncorrelated Amp and Phs models

    #if ! test -e /home/$USER/ppc_logs/Amp; then
    #mkdir /home/$USER/ppc_logs/Amp
    #fi

    #if ! test -e /home/$USER/ppc_logs/Phs; then
    #mkdir /home/$USER/ppc_logs/Phs
    #fi

    #if ! test -e /home/$USER/ppc_condor/Amp; then
    #mkdir /home/$USER/ppc_condor/Amp
    #fi

    #if ! test -e /home/$USER/ppc_condor/Phs; then
    #mkdir /home/$USER/ppc_condor/Phs
    #fi


mkdir /home/$USER/ppc_logs/${2}
mkdir /home/$USER/ppc_logs/${2}/out/
mkdir /home/$USER/ppc_logs/${2}/err/
mkdir /home/$USER/ppc_logs/${2}/log/
mkdir /home/$USER/ppc_condor/${2}/
chmod 777 /home/$USER/ppc_logs/${2}
chmod 777 /home/$USER/ppc_logs/${2}*
chmod 777 /home/$USER/ppc_condor/${2}

#make sure to move all directories to scratch before submitting jobs!

ll="*"
echo "Universe        = vanilla
Notification    = never
Executable      = /home/anegi/multisim/ppc/llh/llh.sh


Output          = /scratch/$USER/ppc_logs/${2}/out/out_\$(Process)
Error           = /scratch/$USER/ppc_logs/${2}/err/err_\$(Process)
Log             = /scratch/$USER/ppc_logs/${2}/log/log_\$(Process)


request_gpus    = 1
request_memory  = 8GB
should_transfer_files = yes
when_to_transfer_output = ON_EXIT
requirements    = regexp(\"(gtx-8|gtx-27|gtx-33|gtx-40|rad-0)\", Machine) != True
" > /home/$USER/ppc_condor/${2}/$timenow

eval `/cvmfs/icecube.opensciencegrid.org/py3-v4.2.1/setup.sh`

for b in *.dat

do
    echo "Arguments       = 0 $b 36 1 20 $d" >> /home/$USER/ppc_condor/${2}/$timenow
    echo "queue" >> /home/$USER/ppc_condor/${2}/$timenow
    echo "Arguments       = 0 $b 36 21 40 $d" >> /home/$USER/ppc_condor/${2}/$timenow
    echo "queue" >> /home/$USER/ppc_condor/${2}/$timenow
    echo "Arguments       = 0 $b 36 41 60 $d" >> /home/$USER/ppc_condor/${2}/$timenow
    echo "queue" >> /home/$USER/ppc_condor/${2}/$timenow

done

echo "Done"
