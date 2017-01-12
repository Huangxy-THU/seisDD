#!/bin/bash

# parameters
source $SUBMIT_DIR/parameter

# local id (from 0 to $ntasks-1)
iproc=${OMPI_COMM_WORLD_RANK}

echo "test_mpi iproc=$iproc"

# run serial exe 
$SUBMIT_DIR/test/hello.exe

# run mpi exe 
#mpirun -np $NPROC $SUBMIT_DIR/test/hello_mpi.exe
