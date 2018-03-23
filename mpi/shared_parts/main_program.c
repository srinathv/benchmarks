// Author: Wes Kendall
// Copyright 2011 www.mpitutorial.com
// This code is provided freely with the tutorials on mpitutorial.com. Feel
// free to modify it for your own use. Any distribution of the code must
// either provide a link to www.mpitutorial.com or keep this header intact.
//
// MPI_Send, MPI_Recv example. Communicates the number -1 from process 0
// to process 1.
//
//Srinath V. 12/27/17: 
//a)add loops for call count of 100 
//b)loop for 10 secs
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int test_mpi();

int main(int argc, char** argv) {
  printf("here\n" );
  test_mpi();
  return 0;
}
