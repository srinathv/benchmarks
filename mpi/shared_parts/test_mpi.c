#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int test_mpi() {
  // Initialize the MPI environment
  MPI_Init(NULL, NULL);
  // Find out rank, size
  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);
  printf("here\n" );

  // We are assuming at least 2 processes for this task
  if (world_size < 2) {
    fprintf(stderr, "World size must be greater than 1\n" );
    MPI_Abort(MPI_COMM_WORLD, 1);
  }

    time_t endwait;
    time_t start = time(NULL);
    time_t seconds = 10; // end loop after this time has elapsed

    endwait = start + seconds;

    printf("start time is : %s", ctime(&start));

    while (start < endwait)
    {
  int number,x,count=1 ;
  for (x = 0; x < 100; x++){
  if (world_rank == 0) {
    // If we are rank 0, set the number to -1 and send it to process 1
    number = -3;
    MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
  } else if (world_rank == 1) {
    MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    printf("Process 1 received number %d from process 0\n", number);
  }
    printf("count is %d \n", count);
    count++ ;
  };
   sleep(1);   // sleep 1s.
        start = time(NULL);
        printf("loop time is : %s", ctime(&start));
  }

    printf("end time is %s", ctime(&endwait));
  MPI_Finalize();
}
