//Original code from www.mpitutorial.com
// MPI_Send, MPI_Recv example. Communicates the number -1 from process 0
// to process 1.
//
//Srinath V. 12/27/17:
//a)add loops for call count of 100
//b)loop for 10 secs
//Olly Perks 1/6/18: discussion of delay timing structure
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char** argv) {
  // Initialize the MPI environment
  MPI_Init(NULL, NULL);
  // Find out rank, size
  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  int world_size;
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);

  // We are assuming at least 2 processes for this task
  if (world_size < 2) {
    fprintf(stderr, "World size must be greater than 1 for %s\n", argv[0]);
    MPI_Abort(MPI_COMM_WORLD, 1);
  }
    time_t mpiendwait, compendwait, looptime;
    time_t loop1time, loop2time, loop3time;
    time_t endtime;
    time_t starttime = time(NULL);
    time_t delay1 = 10; // end loop after this time has elapsed
    time_t delay2 = 5; // end loop after this time has elapsed
    time_t delay3 = 15; // end loop after this time has elapsed

  if (world_rank == 0) {
    printf("start time is : %s", ctime(&starttime));
  }

MPI_Barrier(MPI_COMM_WORLD); // sync all

  int number, x, count=1 ;
//  for (x = 0; x < 10; x++){
  if (world_rank == 0) {
  // allocate known size of data 100MB
  char *data;
  int bytes = (10240*10240);
  data = (char *) malloc(bytes);
  for(int i=0;i<bytes;i++){
    data[i] = (char) rand();
//    printf("%c",data[i]);
  }
  //stall for 10secs
    starttime = time(NULL);
    looptime = starttime;
    endtime = starttime + delay1;
    while (looptime < endtime)
    {
        looptime = time(NULL);
        printf("%s",ctime(&looptime));
    }
//    // if we are rank 0, set the number to -3 and send it to process 1
//    number = -3;
//    mpi_send(&number, 1, mpi_int, 1, 0, mpi_comm_world);
//  } else if (world_rank == 1) {
//    mpi_recv(&number, 1, mpi_int, 0, 0, mpi_comm_world, mpi_status_ignore);
//    printf("process 1 received number %d from process 0\n", number);
    free(data);
  }

// rank 0 ~ 0sec in mpi but 1 rank in 10s in mpi_recv

//MPI_Barrier(MPI_COMM_WORLD); // sync all

//  if (world_rank == 0) {
//
//    // If we are rank 0, set the number to -5 and send it to process 1
//    number = -5;
//    MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
//  } else if (world_rank == 1) {
//      //stall for 10secs
//    starttime = time(NULL);
//    looptime = starttime;
//    endtime = starttime + delay1;
//    while (looptime < endtime)
//    {
//        looptime = time(NULL);
//    }
//    MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
//    printf("Process 1 received number %d from process 0\n", number);
//  }
  // rank 0 ~ 10secs in mpi while rank 1 is ~0 secs in mpi
//    printf("count is %d from rank %d \n", count, world_rank);
//    count++ ;
//  }; // 10 count for loop
 //       starttime = time(NULL);
 //       printf("loop time doing mpi sends & receives is : %s", ctime(&starttime));

//int global_sum;
//if (world_rank == 0) {
//starttime = time(NULL);
//}
//for (x = 0; x < 10; x ++){
//MPI_Allreduce(&number, &global_sum, 1, MPI_INT, MPI_SUM,
//              MPI_COMM_WORLD);
//}
//if (world_rank == 0) {
//endtime = time(NULL);
//double allReduceTime = difftime(starttime,endtime);
////printf("MPI_allreduce time is %.f \n", allReduceTime);
//printf("allReduce start time is %s", ctime(&starttime));
//printf("allReduce end time is %s", ctime(&endtime));
//}
//MPI_Barrier(MPI_COMM_WORLD); // sync all



if (world_rank == 0) {
  endtime = time(NULL);
  printf("end time is %s", ctime(&endtime));
}
  MPI_Finalize();
  return 0;
}
