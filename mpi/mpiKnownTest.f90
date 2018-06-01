!Original code from www.mpitutorial.com
! MPI_Send, MPI_Recv example. Communicates the number -1 from process 0
! to process 1.
!
!Srinath V. 05/31/18:
  PROGRAM mpiKnownTest

! Include the MPI library definitons:
  include 'mpif.h'

  integer ::  world_size, world_rank, ierr, rc, len, i
  integer ::  time_int, delay1, delay2, delay3
  integer ::  starttime_int, endtime_int, looptime_int
  real    ::  start, finish
  integer ::  mpiMessage, x, tripcount
  character(30) :: starttime,endtime,bigTottime
  character*(MPI_MAX_PROCESSOR_NAME) name
  integer :: stat(MPI_STATUS_SIZE)
  integer :: tag

  tag=1

  ! Initialize the MPI library:
  call MPI_INIT(ierr)
  if (ierr .ne. MPI_SUCCESS) then
     print *,'Error starting MPI program. Terminating.'
     call MPI_ABORT(MPI_COMM_WORLD, rc, ierr)
  end if


  call MPI_COMM_RANK(MPI_COMM_WORLD, world_rank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, world_size, ierr)

! We are assuming at least 2 processes for this task
  if (world_size < 2 ) then
    write(*,*) 'World size must be greater than 1 for this test.'
    call MPI_ABORT (MPI_COMM_WORLD, 1)
  endif
! set up first time loop
  starttime_int=time8()
  call ctime(starttime_int,starttime)
  delay1=10
  delay2=5
  delay3=15

  if (world_rank == 0) then
    write(*,*) "start time is ", starttime
    call cpu_time(start)
  endif


  call MPI_Barrier(MPI_COMM_WORLD,ierr) ! sync all

!   tripcount=1
!  for (x = 0; x < 10; x++){
   if (world_rank == 0) then
!  stall for 10secs
     starttime_int = time8()
     looptime_int = starttime_int
     endtime_int = starttime_int + delay1
     do while (looptime_int < endtime_int)
        looptime_int = time8()
     enddo
!     If we are rank 0, set the number to -3 and send it to process 1
     mpiMessage = -3
     call  MPI_Send(mpiMessage, 1, MPI_INTEGER, 1, tag, MPI_COMM_WORLD,ierr)

   else if (world_rank == 1) then
  write(*,*) 'on rank', world_rank
     call MPI_Recv(mpiMessage, 1, MPI_INTEGER, 0, tag, MPI_COMM_WORLD, stat, ierr)
     write(*,*) 'Process 1 received number ', mpiMessage,' from process 0'
   endif

!// rank 0 ~ 0sec in mpi but 1 rank in 10s in mpi_recv
!
!
   call MPI_Barrier(MPI_COMM_WORLD,ierr) ! sync all

  if (world_rank == 0) then
     mpiMessage = -5
!    // If we are rank 0, set the number to -5 and send it to process 1
     call  MPI_Send(mpiMessage, 1, MPI_INTEGER, 1, tag, MPI_COMM_WORLD,ierr)
   else if (world_rank == 1) then
     starttime_int = time8()
     looptime_int = starttime_int
     endtime_int = starttime_int + delay1
     do while (looptime_int < endtime_int)
        looptime_int = time8()
     enddo
  write(*,*) 'on rank', world_rank
     call MPI_Recv(mpiMessage, 1, MPI_INTEGER, 0, tag, MPI_COMM_WORLD, stat, ierr)
     write(*,*) 'Process 1 received number ', mpiMessage,' from process 0'
   endif
!  // rank 0 ~ 10secs in mpi while rank 1 is ~0 secs in mpi
!    printf("count is %d from rank %d \n", count, world_rank);
!    count++ ;
!   endif
! //       starttime = time(NULL);
! //       printf("loop time doing mpi sends & receives is : %s", ctime(&starttime));
!
 call MPI_Barrier(MPI_COMM_WORLD,ierr); ! sync all

  endtime_int=time8()
  call ctime(endtime_int,endtime)

  if (world_rank == 0) then
    write(*,*) "end time is ", endtime
    call cpu_time(finish)
    write(*,*) "total time [cpu_time] is ", finish-start
  endif




! Tell the MPI library to release all resources it is using:
  call MPI_FINALIZE(ierr)
  END PROGRAM mpiKnownTest

!int main(int argc, char** argv) {
!  // Initialize the MPI environment
!  MPI_Init(NULL, NULL);
!  // Find out rank, size
!  int world_rank;
!  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
!  int world_size;
!  MPI_Comm_size(MPI_COMM_WORLD, &world_size);
!
!  // We are assuming at least 2 processes for this task
!  if (world_size < 2) {
!    fprintf(stderr, "World size must be greater than 1 for %s\n", argv[0]);
!    MPI_Abort(MPI_COMM_WORLD, 1);
!  }
!    time_t mpiendwait, compendwait, looptime;
!    time_t loop1time, loop2time, loop3time;
!    time_t endtime;
!    time_t starttime = time(NULL);
!    time_t delay1 = 10; // end loop after this time has elapsed
!    time_t delay2 = 5; // end loop after this time has elapsed
!    time_t delay3 = 15; // end loop after this time has elapsed
!
!  if (world_rank == 0) {
!    printf("start time is : %s", ctime(&starttime));
!  }
!
!MPI_Barrier(MPI_COMM_WORLD); // sync all
!
!  int number, x, count=1 ;
!  for (x = 0; x < 10; x++){
!  if (world_rank == 0) {
!  //stall for 10secs
!    starttime = time(NULL);
!    looptime = starttime;
!    endtime = starttime + delay1;
!    while (looptime < endtime)
!    {
!        looptime = time(NULL);
!    }
!    // If we are rank 0, set the number to -3 and send it to process 1
!    number = -3;
!    MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
!  } else if (world_rank == 1) {
!    MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
!    printf("Process 1 received number %d from process 0\n", number);
!  }
!
!// rank 0 ~ 0sec in mpi but 1 rank in 10s in mpi_recv
!
!
!MPI_Barrier(MPI_COMM_WORLD); // sync all
!
!  if (world_rank == 0) {
!
!    // If we are rank 0, set the number to -5 and send it to process 1
!    number = -5;
!    MPI_Send(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
!  } else if (world_rank == 1) {
!      //stall for 10secs
!    starttime = time(NULL);
!    looptime = starttime;
!    endtime = starttime + delay1;
!    while (looptime < endtime)
!    {
!        looptime = time(NULL);
!    }
!    MPI_Recv(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
!    printf("Process 1 received number %d from process 0\n", number);
!  }
!  // rank 0 ~ 10secs in mpi while rank 1 is ~0 secs in mpi
!    printf("count is %d from rank %d \n", count, world_rank);
!    count++ ;
!  };
! //       starttime = time(NULL);
! //       printf("loop time doing mpi sends & receives is : %s", ctime(&starttime));
!
!MPI_Barrier(MPI_COMM_WORLD); // sync all
!int global_sum;
!if (world_rank == 0) {
!starttime = time(NULL);
!}
!for (x = 0; x < 10; x ++){
!MPI_Allreduce(&number, &global_sum, 1, MPI_INT, MPI_SUM,
!              MPI_COMM_WORLD);
!}
!if (world_rank == 0) {
!endtime = time(NULL);
!double allReduceTime = difftime(starttime,endtime);
!//printf("MPI_allreduce time is %.f \n", allReduceTime);
!printf("allReduce start time is %s", ctime(&starttime));
!printf("allReduce end time is %s", ctime(&endtime));
!}
!MPI_Barrier(MPI_COMM_WORLD); // sync all
!
!
!
!if (world_rank == 0) {
!  endtime = time(NULL);
!  printf("end time is %s", ctime(&endtime));
!}
!  MPI_Finalize();
!  return 0;
!}
