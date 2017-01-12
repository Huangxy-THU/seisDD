#!/bin/bash

# parameters
source $SUBMIT_DIR/parameter

# local id (from 0 to $ntasks-1)
iproc=$SLURM_PROCID

echo "test_srun iproc=$iproc"

# run serial exe 
echo
echo "run hello.exe"
$SUBMIT_DIR/test/hello.exe

# run mpi exe 
echo
echo "run hello_mpi.exe"
mpirun -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe
