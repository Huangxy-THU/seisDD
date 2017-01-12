#!/bin/bash

ulimit -s unlimited
# module load 
#module load intel/14.0.1
#module load gcc/5.2.0
#module load openmpi/1.4.4-intel-v12.1

#module load intel-mkl/11.0/1/64
#module load intel/13.0/64/13.0.1.117
#module load openmpi/intel-13.0/1.6.3/64

system='slurm'
# Submit directory
if [ $system == 'slurm' ]; then
    export SUBMIT_DIR=$SLURM_SUBMIT_DIR
elif [ $system == 'pbs' ]; then
    export SUBMIT_DIR=$PBS_O_WORKDIR
fi
cd $SUBMIT_DIR
source parameter

# Submit directory
if [ $system == 'slurm' ]; then
    echo "$SLURM_JOB_NODELIST"  >  ./job_info/NodeList
    echo "$SLURM_JOBID"  >  ./job_info/JobID
elif [ $system == 'pbs' ]; then
    echo "$PBS_NODEFILE"  >  ./job_info/NodeList
    echo "$PBS_JOBID"  >  ./job_info/JobID
fi

export SCRIPTS_DIR="$package_path/scripts"

echo
echo "       This is to check your system: $system "
echo "**********************************************************"
echo

STARTTIME=$(date +%s)
echo "start time is :  $(date +"%T")"
echo

# Distribute tasks in serial or parallel on specified hosts
if [ $system == 'slurm' ]; then
    # request $NPROC CPUs for $ntasks tasks 
    # multiple CPUs for the multithreaded tasks
    # srun - distribute task to nodes under sbatch
    echo 
    echo "srun -n $ntasks -c $NPROC -l -W 0  test/test_srun.sh"
    srun -n $ntasks -c $NPROC -l -W 0  test/test_srun.sh 2>./job_info/error_run 
elif [ $system == 'pbs' ]; then
    # pbsdsh - distribute task to nodes under pbs
    # pbsdsh -v test/test_pbsdsh.sh #2>./job_info/error_run
    sh $SCRIPTS_DIR/pbsssh.sh test/test_pbs.sh
fi

echo 
echo "mpirun -np $ntasks test/test_mpi.sh"
mpirun -np $ntasks test/test_mpi.sh 2>./job_info/error_mpi 

echo 
echo "mpiexec -np $ntasks test/test_mpi.sh"
mpiexec -np $ntasks test/test_mpi.sh 2>./job_info/error_mpi


echo 
echo "mpirun -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe"
mpirun -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe

echo 
echo "mpiexec -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe"
mpiexec -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe


ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")" 
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

echo
echo "******************well done*******************************"
