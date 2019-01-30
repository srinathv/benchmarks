#! /bin/sh
# This is a shell archive.  Remove anything before this line, then unpack
# it by saving it into a file and typing "sh file".  To overwrite existing
# files, type "sh file -c".  You can also feed this as standard input via
# unshar, or by typing "sh <file", e.g..  If this archive is complete, you
# will see the following message at the end:
#		"End of shell archive."
# Contents:  maind.f loopd.f
# Wrapped by dongarra@dasher on Fri Apr 19 13:33:49 1991
PATH=/bin:/usr/bin:/usr/ucb ; export PATH
if test -f 'maind.f' -a "${1}" != "-c" ; then
  echo shar: Will not clobber existing file \"'maind.f'\"
else
echo shar: Extracting \"'maind.f'\" \(60569 characters\)
sed "s/^X//" >'maind.f' <<'END_OF_FILE'
c***********************************************************************
c                TEST SUITE FOR VECTORIZING COMPILERS                  *
c                        (File 1 of 2)                                 *
c                                                                      *
c  Version:   2.0                                                      *
c  Date:      3/14/88                                                  *
c  Authors:   Original loops from a variety of                         *
c             sources. Collection and synthesis by                     *
c                                                                      *
c             David Callahan  -  Tera Computer                         *
c             Jack Dongarra   -  University of Tennessee               *
c             David Levine    -  Argonne National Laboratory           *
c***********************************************************************
c  Version:   3.0                                                      *
c  Date:      1/4/91                                                   *
c  Authors:   David Levine    -  Executable version                    *
c***********************************************************************
c                         ---DESCRIPTION---                            *
c                                                                      *
c  This test consists of a variety of  loops that represent different  *
c  constructs  intended   to  test  the   analysis  capabilities of a  *
c  vectorizing  compiler.  Each loop is  executed with vector lengths  *
c  of 10, 100, and 1000.   Also included  are several simple  control  *
c  loops  intended  to  provide  a  baseline  measure  for  comparing  *
c  compiler performance on the more complicated loops.                 *
c                                                                      *
c  The  output from a  run  of the test  consists of seven columns of  *
c  data:                                                               *
c     Loop:        The name of the loop.                               *
c     VL:          The vector length the loop was run at.              *
c     Seconds:     The time in seconds to run the loop.                *
c     Checksum:    The checksum calculated when running the test.      *
c     PreComputed: The precomputed checksum (64-bit IEEE arithmetic).  *
c     Residual:    A measure of the accuracy of the calculated         *
c                  checksum versus the precomputed checksum.           *
c     No.:         The number of the loop in the test suite.           *
c                                                                      *
c  The  residual  calculation  is  intended  as  a  check  that   the  *
c  computation  was  done  correctly  and  that 64-bit arithmetic was  *
c  used.   Small   residuals    from    non-IEEE    arithmetic    and  *
c  nonassociativity  of   some calculations  are   acceptable.  Large  *
c  residuals  from   incorrect  computations or  the  use   of 32-bit  *
c  arithmetic are not acceptable.                                      *
c                                                                      *
c  The test  output  itself  does not report   any  results;  it just  *
c  contains data.  Absolute  measures  such as Mflops and  total time  *
c  used  are  not   appropriate    metrics  for  this  test.   Proper  *
c  interpretation of the results involves correlating the output from  *
c  scalar and vector runs  and the  loops which  have been vectorized  *
c  with the speedup achieved at different vector lengths.              *
c                                                                      *
c  These loops  are intended only  as  a partial test of the analysis  *
c  capabilities of a vectorizing compiler (and, by necessity,  a test  *
c  of the speed and  features  of the underlying   vector  hardware).  *
c  These loops  are  by no means  a  complete  test  of a vectorizing  *
c  compiler and should not be interpreted as such.                     *
c                                                                      *
c***********************************************************************
c                           ---DIRECTIONS---                           *
c                                                                      *
c  To  run this  test,  you will  need  to  supply  a  function named  *
c  second() that returns user CPU time.                                *
c                                                                      *
c  This test is distributed as two separate files, one containing the  *
c  driver  and  one containing the loops.   These  two files MUST  be  *
c  compiled separately.                                                *
c                                                                      *
c  Results must  be supplied from  both scalar and vector  runs using  *
c  the following rules for compilation:                                *
c                                                                      *
c     Compilation   of the  driver  file must  not  use any  compiler  *
c     optimizations (e.g., vectorization, function  inlining,  global  *
c     optimizations,...).   This   file   also must  not  be analyzed  *
c     interprocedurally to  gather information useful  in  optimizing  *
c     the test loops.                                                  *
c                                                                      *
c     The file containing the  loops must be compiled twice--once for  *
c     a scalar run and once for a vector run.                          *
c                                                                      *
c        For the scalar  run, global (scalar) optimizations should be  *
c        used.                                                         *
c                                                                      *
c        For  the  vector run,  in  addition   to  the  same   global  *
c        optimizations specified  in the scalar   run,  vectorization  *
c        and--if available--automatic  call generation to   optimized  *
c        library  routines,  function inlining,  and  interprocedural  *
c        analysis should be  used.  Note again that function inlining  *
c        and interprocedural  analysis  must  not be  used to  gather  *
c        information  about any of the  program  units  in the driver  *
c        program.                                                      *
c                                                                      *
c     No changes  may  be made  to   the   source code.   No compiler  *
c     directives may be used, nor may  a file  be split into separate  *
c     program units.  (The exception is  filling  in  the information  *
c     requested in subroutine "info" as described below.)              *
c                                                                      *
c     All files must be compiled to use 64-bit arithmetic.             *
c                                                                      *
c     The  outer  timing  loop  is  included  only   to increase  the  *
c     granularity of the calculation.  It should not be vectorizable.  *
c     If it is found to be so, please notify the authors.              *
c                                                                      *
c  All runs  must be  made  on a standalone  system  to minimize  any  *
c  external effects.                                                   *
c                                                                      *
c  On virtual memory computers,  runs should be  made with a physical  *
c  memory and working-set  size  large enough  that  any  performance  *
c  degradation from page  faults is negligible.   Also,  the  timings  *
c  should be repeatable  and you  must  ensure  that timing anomalies  *
c  resulting from paging effects are not present.                      *
c                                                                      *
c  You should edit subroutine "info"   (the  last subroutine  in  the  *
c  driver program) with  information specific to your  runs, so  that  *
c  the test output will be annotated automatically.                    *
c                                                                      *
c  Please return the following three files in an electronic format:    *
c                                                                      *
c  1. Test output from a scalar run.                                   *
c  2. Test output from a vector run.                                   *
c  3. Compiler output listing (source echo, diagnostics, and messages) *
c     showing which loops have been vectorized.                        *
c                                                                      *
c  The preferred media  for receipt, in order  of preference, are (1)  *
c  electronic mail, (2) 9-track  magnetic or  cartridge tape in  Unix  *
c  tar  format, (3) 5" IBM PC/DOS  floppy   diskette, or  (4) 9-track  *
c  magnetic  tape in  ascii  format,   80 characters per card,  fixed  *
c  records, 40 records per block, 1600bpi.  Please return to           *
c                                                                      *
c  David Levine       		                                       *
c  Mathematics and Computer Science Division                           *
c  Argonne National Laboratory                                         *
c  Argonne, Illinois 60439                                             *
c  levine@mcs.anl.gov                                                  *
c***********************************************************************
X      integer ld, nloops
X      parameter (ld=1000,nloops=135)
X      real dtime, ctime, c471s
X      double precision s1, s2, array
X      integer ip(ld),indx(ld),n1,n3,n,i,ntimes
X      common /cdata/ array(ld*ld)
X      double precision a(ld),b(ld),c(ld),d(ld),e(ld),aa(ld,ld),
X     +                 bb(ld,ld),cc(ld,ld)
X
X      call title
X      n      = 10
X      ntimes = 100000
X      call set(dtime,ctime,c471s,ip,indx,n1,n3,s1,s2,
X     +           n,a,b,c,d,e,aa,bb,cc)
X
X      do 1000 i = 1,3
X
X      call s111 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s112 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s113 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s114 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s115 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s116 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s118 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s119 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s121 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s122 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1,n3)
X      call s123 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s124 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s125 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s126 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s127 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s128 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s131 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s132 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s141 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s151 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s152 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s161 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s162 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1)
X      call s171 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1)
X      call s172 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1,n3)
X      call s173 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s174 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s175 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1)
X      call s176 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s211 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s212 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s221 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s222 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s231 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s232 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s233 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s234 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s235 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s241 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s242 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1,s2)
X      call s243 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s244 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s251 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s252 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s253 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s254 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s255 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s256 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s257 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s258 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s261 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s271 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s272 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1)
X      call s273 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s274 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s275 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s276 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s277 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s278 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s279 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s2710(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1)
X      call s2711(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s2712(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s281 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s291 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s292 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s293 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s2101(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s2102(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s2111(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s311 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s312 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s313 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s314 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s315 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s316 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s317 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s318 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1)
X      call s319 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s3110(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s3111(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s3112(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s3113(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s321 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s322 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s323 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s331 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s332 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1)
X      call s341 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s342 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s343 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s351 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s352 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s353 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call s411 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s412 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1)
X      call s413 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s414 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s415 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s421 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s422 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s423 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s424 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s431 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s432 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s441 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s442 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,indx)
X      call s443 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s451 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s452 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s453 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s471 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,c471s)
X      call s481 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s482 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s491 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call s4112(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,s1)
X      call s4113(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call s4114(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,n1)
X      call s4115(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call s4116(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,n/2,n1)
X      call s4117(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call s4121(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call va   (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vag  (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call vas  (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
X      call vif  (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vpv  (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vtv  (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vpvtv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vpvts(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1)
X      call vpvpv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vtvtv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vsumr(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vdotr(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X      call vbor (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
X
X      n      = n*10
X      ntimes = ntimes/10
X
X1000  continue
X
X      call info(ctime,dtime,c471s)
X
X      stop
X      end
X
X      block data
c
c --  initialize precomputed checksums and array of names
c --  resary contains checksums for vectors of length 10,100, and 1000
c --  snames contains the 5 character string names of the loops
c --  time gets set in subroutine check with execution times
c --  ans  gets set in subroutine check with calculated checksums
c --  nit, number of iterations of inner loop, is not currently used
c
X      integer i,nloops,ld,j,nvl
X      parameter(ld=1000,nloops=135,nvl=3)
X      integer nit(nloops,nvl)
X      double precision ans(nloops,nvl),resary(nloops,nvl)
X      real            time(nloops,nvl)
X      character*5 snames(nloops)
X      common /acom/ans,resary
X      common /bcom/nit
X      common /ccom/snames
X      common /tcom/time
c
c --  precomputed checksums
c
X      data ( (resary(i,j), j=1,nvl),i=1,10 ) /
X     &     10.36590277778d0,    100.40628318341d0,   1000.41073401638d0,
X     &     22.56870905770d0,    258.31101250085d0,   2636.44909582101d0,
X     &     10.54976773117d0,    100.63498390018d0,   1000.64393456668d0,
X     &     29.63974080373d0,    353.12363498321d0,   3628.96362496028d0,
X     &      9.12372283291d0,     99.01324486818d0,    999.00149833537d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     10.92428292812d0,    100.99325548216d0,   1000.99949866671d0,
X     &    122.58323255228d0,  13099.31638829156d0,1321154.90032936420d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0,
X     & 154986.77311666883d0,  16449.83900184871d0,   2643.93456668156d0/
X
X      data ( (resary(i,j), j=1,nvl),i=11,20 ) /
X     &     12.92722222222d0,    103.25026546724d0,   1003.28587213103d0,
X     &      6.46361111111d0,     51.62513273362d0,    501.64293606551d0,
X     &    200.00000000000d0,  20000.00000000000d0,2000000.00000000000d0,
X     &    122.58409263671d0,  10460.02285184050d0,1006907.25586229020d0,
X     &     12.92722222222d0,    103.25026546724d0,   1003.28587213103d0,
X     &     25.00000000000d0,    250.00000000000d0,   2500.00000000000d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0,
X     &    100.96448412698d0,  10002.09368875882d0,1000003.24273543020d0,
X     & 141284.76788863543d0,  25994.59964010348d0,1001638.09303032420d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0/
X
X      data ( (resary(i,j), j=1,nvl),i=21,30 ) /
X     & 119763.19856741340d0,  12120.07400659667d0,   2202.05640365934d0,
X     &     21.88004550894d0,    202.03631475108d0,   2002.05416908073d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &     11.46361111111d0,    101.62513273362d0,   1001.64293606552d0,
X     &     11.46361111111d0,    101.62513273362d0,   1001.64293606551d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0,
X     &  94863.96825398761d0,   1756.26368022382d0,   1023.06352283494d0,
X     &     15.97371236458d0,    191.54999869568d0,   1986.96285998095d0/
X
X      data ( (resary(i,j), j=1,nvl),i=31,40 ) /
X     &  90012.92896823291d0,  10005.18737751802d0,   2006.48547086055d0,
X     & 466901.67065395752d0, 611283.72814145486d0,1145729.92128578290d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &    169.73954790249d0,  18093.17030591522d0,1821145.31605738050d0,
X     &    100.00000000000d0,  10000.00000000000d0,1000000.00000000000d0,
X     &    318.99007936508d0,  63220.03164047703d0,9733449.02625389960d0,
X     &    169.73954790249d0,  18093.17030591522d0,1821145.31605738050d0,
X     & 502593.87943175732d0, 554106.50684144662d0,2362767.41506457240d0,
X     &     20.00000000000d0,    200.00000000000d0,   2000.00000000000d0,
X     &    135.00014500000d0,  14850.01494999997d0,1498501.49950003670d0/
X
X      data ( (resary(i,j), j=1,nvl),i=41,50 ) /
X     & 703168.96900448343d0,  74452.86201741260d0,   9467.85242521049d0,
X     &     21.89999209985d0,    201.98990200994d0,   2001.99800200180d0,
X     &     14.18157204583d0,    104.35229070571d0,   1004.37019236674d0,
X     &     19.00000000000d0,    199.00000000000d0,   1999.00000000000d0,
X     & 985374.71938453394d0, 999940.55331344355d0,1001996.24603636260d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &      9.99000000000d0,     99.90000000000d0,    999.00000000002d0,
X     &    210.00000000000d0,  20100.00000000000d0,2001000.00000000000d0,
X     &    210.00000000000d0,  20100.00000000000d0,2001000.00000000000d0,
X     &      8.25300047928d0,     12.77876983660d0,     17.37505452842d0/
X
X      data ( (resary(i,j), j=1,nvl),i=51,60 ) /
X     & 208965.09600098155d0,  22800.31298759832d0,   3289.51206792981d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 309973.54623333761d0,  32899.67800369742d0,   5287.86913336312d0,
X     &     31.30754181311d0,    301.05213316999d0,   3001.00748921734d0,
X     &1154998.32288425600d0,1016551.47398574440d0,1003645.57850125060d0,
X     &    100.00000000041d0,  10000.00000048991d0,1000000.00050001150d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     24.47873598513d0,    206.82236141782d0,   2009.12940542723d0,
X     &     25.77728228143d0,    208.47634861140d0,   2010.81938737257d0/
X
X      data ( (resary(i,j), j=1,nvl),i=61,70 ) /
X     &     33.09953546233d0,    303.26996780037d0,   3003.28786913336d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &  54986.77311666882d0,   6449.83900184871d0,   1643.93456668156d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &      9.99000000000d0,     99.90000000000d0,    999.00000000002d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     & 155076.77311666880d0,  26349.83900184871d0,1001643.93456668160d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &      3.00000000000d0,      3.00000000000d0,      3.00000000000d0/
X
X      data ( (resary(i,j), j=1,nvl),i=71,80 ) /
X     &      2.92896825397d0,      5.18737751764d0,      7.48547086055d0,
X     &      1.00001000004d0,      1.00010000495d0,      1.00100049967d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &      1.00000000000d0,      1.00000000000d0,      1.00000000000d0,
X     &      2.00000000000d0,      2.00000000000d0,      2.00000000000d0,
X     &      0.10000000000d0,      0.01000000000d0,      0.00100000000d0,
X     &      0.99990000450d0,      0.99900049484d0,      0.99004978425d0,
X     &     12.00000000000d0,    102.00000000000d0,   1002.00000000000d0,
X     &     11.71587301587d0,     20.74951007056d0,     29.94188344220d0,
X     &     22.00000000000d0,    202.00000000000d0,   2002.00000000000d0/
X
X      data ( (resary(i,j), j=1,nvl),i=81,90 ) /
X     &      2.92896825397d0,      5.18737751764d0,      7.48547086055d0,
X     &     15.66824452003d0,    161.58098030122d0,   1639.73696495437d0,
X     &      2.00000000000d0,      2.00000000000d0,      2.00000000000d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     35.92413942429d0,    439.14900170395d0,   4551.72818698408d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &     12.00000000000d0,    102.00000000000d0,   1002.00000000000d0,
X     &      2.92896825397d0,      5.18737751764d0,      7.48547086055d0,
X     &      2.92896825397d0,      5.18737751764d0,      7.48547086055d0/
X
X      data ( (resary(i,j), j=1,nvl),i=91,100 ) /
X     &     29.28968253968d0,    518.73775176393d0,   7485.47086054862d0,
X     &5000010.00000000000d0,5000100.00000000000d0,5001000.00000000000d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &5000010.00000000000d0,5000100.00000000000d0,5001000.00000000000d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 153996.32288440072d0,  16548.47398574890d0,   3643.57750124824d0,
X     &    228.31891298186d0,  19130.64580944312d0,1836116.25777848130d0,
X     & 153984.77311666956d0,  16446.83900184871d0,   2641.93356668156d0,
X     &     12.82896825397d0,    105.17737751764d0,   1007.48447086055d0/
X
X      data ( (resary(i,j), j=1,nvl),i=101,110 ) /
X     &      6.69827003023d0,     52.29313637543d0,    502.87104683277d0,
X     &     10.53976773117d0,    100.64083339222d0,   1000.68224820984d0,
X     &     10.53976773117d0,    103.25165081509d0,   1026.25239026486d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &     12.00663579797d0,    104.22170317263d0,   1006.51531302881d0,
X     &     10.00005500000d0,    100.00505000000d0,   1000.50050000000d0/
X
X      data ( (resary(i,j), j=1,nvl),i=111,120 ) /
X     &      5.85793650794d0,     10.37475503528d0,     14.97094172110d0,
X     &     24.64930319350d0,    204.90495170055d0,   2004.93180370004d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &     11.54976773117d0,    101.63498390018d0,   1001.64393456668d0,
X     & 292906.82539681665d0,  51973.77517639728d0,   8485.47086055035d0,
X     &     11.54976773117d0,    101.63498390018d0,   1001.64393456668d0,
X     &     10.64027777778d0,    100.10352524037d0,   1000.01496357775d0,
X     &      0.94448853616d0,      1.02889405454d0,      1.03784373764d0,
X     &      0.65398478836d0,      0.74716878794d0,      0.75617087823d0/
X
X      data ( (resary(i,j), j=1,nvl),i=121,130 ) /
X     &     10.24053571429d0,    100.41622200819d0,   1000.43417317164d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     & 154976.77311666883d0,  16349.83900184871d0,   1643.93456668156d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0,
X     & 154986.77311666880d0,  16449.83900184871d0,   2643.93456668156d0/
X
X      data ( (resary(i,j), j=1,nvl),i=131,nloops ) /
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &     10.00000000000d0,    100.00000000000d0,   1000.00000000000d0,
X     &      2.92896825397d0,      5.18737751764d0,      7.48547086055d0,
X     &      1.54976773117d0,      1.63498390018d0,      1.64393456668d0,
X     &    180.04429557950d0,    180.04429557960d0,    180.04429557960d0/
c
c --  subroutine name used in function nindex
c
X      data ( snames(i),i=1,nloops) /
X     &'s111 ','s112 ','s113 ','s114 ','s115 ','s116 ','s118 ','s119 ',
X     &'s121 ','s122 ','s123 ','s124 ','s125 ','s126 ','s127 ','s128 ',
X     &'s131 ','s132 ','s141 ','s151 ','s152 ','s161 ','s162 ','s171 ',
X     &'s172 ','s173 ','s174 ','s175 ','s176 ','s211 ','s212 ','s221 ',
X     &'s222 ','s231 ','s232 ','s233 ','s234 ','s235 ','s241 ','s242 ',
X     &'s243 ','s244 ','s251 ','s252 ','s253 ','s254 ','s255 ','s256 ',
X     &'s257 ','s258 ','s261 ','s271 ','s272 ','s273 ','s274 ','s275 ',
X     &'s276 ','s277 ','s278 ','s279 ','s2710','s2711','s2712','s281 ',
X     &'s291 ','s292 ','s293 ','s2101','s2102','s2111','s311 ','s312 ',
X     &'s313 ','s314 ','s315 ','s316 ','s317 ','s318 ','s319 ','s3110',
X     &'s3111','s3112','s3113','s321 ','s322 ','s323 ','s331 ','s332 ',
X     &'s341 ','s342 ','s343 ','s351 ','s352 ','s353 ','s411 ','s412 ',
X     &'s413 ','s414 ','s415 ','s421 ','s422 ','s423 ','s424 ','s431 ',
X     &'s432 ','s441 ','s442 ','s443 ','s451 ','s452 ','s453 ','s471 ',
X     &'s481 ','s482 ','s491 ','s4112','s4113','s4114','s4115','s4116',
X     &'s4117','s4121','va   ','vag  ','vas  ','vif  ','vpv  ','vtv  ',
X     &'vpvtv','vpvts','vpvpv','vtvtv','vsumr','vdotr','vbor '/
X
X      end
X
X
X      subroutine set(dtime,ctime,c471s,ip,indx,n1,n3,s1,s2,
X     +               n,a,b,c,d,e,aa,bb,cc)
c
c --  initialize miscellaneous data
c
X      integer ld
X      parameter(ld=1000)
X      integer ip(ld),indx(ld),n1,n3,k,n,i
X      real dtime, ctime, c471s, tdummy, tcall, t471s
X      double precision s1, s2
X      double precision a(ld),b(ld),c(ld),d(ld),e(ld),aa(ld,ld),
X     +                 bb(ld,ld),cc(ld,ld)
X
X      dtime     = tdummy(ld,n,a,b,c,d,e,aa,bb,cc)
X      ctime     = tcall()
X      c471s     = t471s()
X
X      k = 0
X      do 5 i = 1,ld,5
X         ip(i)   = (i+4)
X         ip(i+1) = (i+2)
X         ip(i+2) = (i)
X         ip(i+3) = (i+3)
X         ip(i+4) = (i+1)
X         k = k + 1
X5     continue
X      do 6 i = 1,ld
X         indx(i) = mod(i,4) + 1
X6     continue
X      n1   = 1
X      n3   = 1
X      s1   = 1.0d0
X      s2   = 2.0d0
X
X      return
X      end
X
X
X      subroutine title
X      write(*,40)
X 40   format(/,' Loop    VL     Seconds',
X     +'     Checksum      PreComputed  Residual(1.e-10)   No.')
X
X      return
X      end
X
X      subroutine set1d(n,array,value,stride)
c
c  -- initialize one-dimensional arrays
c
X      integer i, n, stride, frac, frac2
X      double precision array(n), value
X      parameter(frac=-1,frac2=-2)
X      if ( stride .eq. frac ) then
X         do 10 i=1,n
X            array(i) = 1.0d0/dble(i)
X10       continue
X      elseif ( stride .eq. frac2 ) then
X         do 15 i=1,n
X            array(i) = 1.0d0/dble(i*i)
X15       continue
X      else
X         do 20 i=1,n,stride
X            array(i) = value
X20       continue
X      endif
X      return
X      end
X
X      subroutine set2d(n,array,value,stride)
c
c  -- initialize two-dimensional arrays
c
X      integer i, j, n, stride, frac, frac2, ld
X      parameter(frac=-1, frac2=-2, ld=1000)
X      double precision array(ld,n),value
X      if ( stride .eq. frac ) then
X         do 10 j=1,n
X            do 20 i=1,n
X               array(i,j) = 1.0d0/dble(i)
X20          continue
X10       continue
X      elseif ( stride .eq. frac2 ) then
X         do 30 j=1,n
X            do 40 i=1,n
X               array(i,j) = 1.0d0/dble(i*i)
X40          continue
X30       continue
X      else
X         do 50 j=1,n,stride
X            do 60 i=1,n
X               array(i,j) = value
X60          continue
X50       continue
X      endif
X      return
X      end
X
X      subroutine check (chksum,totit,n,t2,name)
c
c --  called by each loop to record and report results
c --  chksum is the computed checksum
c --  totit is the number of times the loop was executed
c --  n  is the length of the loop
c --  t2 is the time to execute loop 'name'
c
X      integer nloops, nvl, i, j, totit, n, nindex
X      double precision epslon, chksum, rnorm
X      real t2
X      parameter (nloops=135,nvl=3,epslon=1.d-10)
X      character*5 name
X      external nindex
X      integer nit (nloops,nvl)
X      double precision ans(nloops,nvl),resary(nloops,nvl)
X      real            time(nloops,nvl)
X      common /acom/ans,resary
X      common /bcom/nit
X      common /tcom/time
c
c -- get row index based on vector length
c
X      if     ( n .eq. 10   ) then
X         j = 1
X      elseif ( n .eq. 100  ) then
X         j = 2
X      elseif ( n .eq. 1000 ) then
X         j = 3
X      else
X         print*,'ERROR COMPUTING COLUMN INDEX IN SUB. CHECK, n= ',n
X      endif
c
c --  column index is the kernel number from function nindex
c
X      i = nindex(name)
X
X      ans (i,j)  = chksum
X      nit (i,j)  = totit
X      time(i,j)  = t2
X
X      rnorm = sqrt((resary(i,j)-chksum)*(resary(i,j)-chksum))/chksum
X      if ( ( rnorm .gt. epslon) .or. ( rnorm .lt. -epslon) ) then
X        write(*,98)name,n,t2,chksum,resary(i,j),rnorm,i
X      else
X        write(*,99)name,n,t2,chksum,resary(i,j),i
X      endif
X
X98    format(a6,i5,1x,f12.6,1x,1p,d13.4,1x,1p,d13.4,1p,d13.4,9x,i3)
X99    format(a6,i5,1x,f12.6,1x,1p,d13.4,1x,1p,d13.4,22x,i3)
X
X      return
X      end
X
X
X      double precision function cs1d(n,a)
c
c --  calculate one-dimensional checksum
c
X      integer i,n
X      double precision a(n), sum
X      sum = 0.0d0
X      do 10 i = 1,n
X         sum = sum + a(i)
X10    continue
X      cs1d = sum
X      return
X      end
X
X      double precision function cs2d(n,aa)
c
c --  calculate two-dimensional checksum
c
X      integer i,j,n,ld
X      parameter(ld=1000)
X      double precision aa(ld,n), sum
X      sum = 0.0d0
X      do 10 j = 1,n
X         do 20 i = 1,n
X            sum = sum + aa(i,j)
X20       continue
X10    continue
X      cs2d = sum
X      return
X      end
X
X      real function tcall()
c
c --  time the overhead of a call to function second()
c
X      integer i, ncalls
X      real t1, t2, second, s
X      parameter(ncalls = 100000)
X
X      t1 = second()
X      do 1 i = 1,ncalls
X         s = second()
X  1   continue
X      t2 = second() - t1
X      tcall = t2/float(ncalls)
X      return
X      end
X
X      real function t471s()
c
c --  time the overhead of a call to subroutine s471s
c
X      integer ncalls, i
X      real t1, t2, second
X      parameter(ncalls = 100000)
X      t1 = second()
X      do 1 i = 1,ncalls
X         call s471s
X  1   continue
X      t2 = second() - t1
X      t471s = t2/float(ncalls)
X      return
X      end
X
X      real function tdummy(ld,n,a,b,c,d,e,aa,bb,cc)
c
c --  time the overhead of a call to subroutine dummy
c
X      integer ld, n, i, ncalls
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      real t1, t2, second
X      parameter(ncalls = 100000)
X      t1 = second()
X      do 1 i = 1,ncalls
X         call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1
X      tdummy = t2/float(ncalls)
X      return
X      end
X
X      subroutine dummy(ld,n,a,b,c,d,e,aa,bb,cc,s)
c
c --  called in each loop to make all computations appear required
c
X      integer ld, n
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision s
X      return
X      end
X
X      subroutine s471s
c
c --  dummy subroutine call made in s471
c
X      return
X      end
X
X
X      integer function nindex(name)
c
c --  returns the (integer) loop index given the (character) name
c
X      integer i, nloops
X      parameter(nloops=135)
X      character*5 name
X      character*5 snames(nloops)
X      common /ccom/snames
X
X      do 10 i=1,nloops
X        if ( name .eq. snames(i) ) then
X           nindex = i
X           return
X        endif
X10    continue
X      print*,'ERROR COMPUTING ROW INDEX IN FUNCTION NINDEX()'
X      nindex = -1
X      return
X      end
X
X      subroutine init(ld,n,a,b,c,d,e,aa,bb,cc,name)
X      double precision zero, small, half, one, two, any, array
X      parameter(any=0.0d0,zero=0.0d0,half=.5d0,one=1.0d0,
X     +          two=2.0d0,small=.000001d0)
X      integer unit, frac, frac2, ld, n
X      parameter(unit=1, frac=-1, frac2=-2)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      common /cdata/ array(1000*1000)
X      character*5 name
X
X      if     ( name .eq. 's111 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's112 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's113 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's114 ' ) then
X         call set2d(n,aa, any,frac)
X         call set2d(n,bb, any,frac2)
X      elseif ( name .eq. 's115 ' ) then
X         call set1d(n,  a, one,unit)
X         call set2d(n, aa,small,unit)
X      elseif ( name .eq. 's116 ' ) then
X         call set1d(n,  a, one,unit)
X      elseif ( name .eq. 's118 ' ) then
X         call set1d(n,  a, one,unit)
X         call set2d(n, bb,small,unit)
X      elseif ( name .eq. 's119 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any,frac2)
X      elseif ( name .eq. 's121 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's122 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's123 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's124 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's125 ' ) then
X         call set1d(n*n,array,zero,unit)
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb,half,unit)
X         call set2d(n,cc, two,unit)
X      elseif ( name .eq. 's126 ' ) then
X         call set2d(n,  bb, one,unit)
X         call set1d(n*n,array,any,frac)
X         call set2d(n,  cc, any,frac)
X      elseif ( name .eq. 's127 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's128 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, two,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, one,unit)
X      elseif ( name .eq. 's131 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's132 ' ) then
X         call set2d(n, aa, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's141 ' ) then
X         call set1d(n*n,array, one,unit)
X         call set2d(n,bb, any,frac2)
X      elseif ( name .eq. 's151 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's152 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b,zero,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's161 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n/2,b(1), one,2)
X         call set1d(n/2,b(2),-one,2)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's162 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's171 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's172 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's173 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's174 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's175 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's176 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's211 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's212 ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's221 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's222 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X      elseif ( name .eq. 's231 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any,frac2)
X      elseif ( name .eq. 's232 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb,zero,unit)
X      elseif ( name .eq. 's233 ' ) then
X         call set2d(n,aa, any,frac)
X         call set2d(n,bb, any,frac)
X         call set2d(n,cc, any,frac)
X      elseif ( name .eq. 's234 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any,frac)
X         call set2d(n,cc, any,frac)
X      elseif ( name .eq. 's235 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any, frac2)
X      elseif ( name .eq. 's241 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, one,unit)
X      elseif ( name .eq. 's242 ' ) then
X         call set1d(n,  a,small,unit)
X         call set1d(n,  b,small,unit)
X         call set1d(n,  c,small,unit)
X         call set1d(n,  d,small,unit)
X      elseif ( name .eq. 's243 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's244 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c,small,unit)
X         call set1d(n,  d,small,unit)
X      elseif ( name .eq. 's251 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's252 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X      elseif ( name .eq. 's253 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b,small,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's254 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X      elseif ( name .eq. 's255 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X      elseif ( name .eq. 's256 ' ) then
X         call set1d(n, a, one,unit)
X         call set2d(n,aa, two,unit)
X         call set2d(n,bb, one,unit)
X      elseif ( name .eq. 's257 ' ) then
X         call set1d(n, a, one,unit)
X         call set2d(n,aa, two,unit)
X         call set2d(n,bb, one,unit)
X      elseif ( name .eq. 's258 ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b,zero,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e,zero,unit)
X         call set2d(n, aa, any,frac)
X      elseif ( name .eq. 's261 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X         call set1d(n,  c, any,frac2)
X         call set1d(n,  d, one,unit)
X      elseif ( name .eq. 's271 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's272 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, two,unit)
X      elseif ( name .eq. 's273 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d,small,unit)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's274 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's275 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb,small,unit)
X         call set2d(n,cc,small,unit)
X      elseif ( name .eq. 's276 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's277 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n/2,b, one,unit)
X         call set1d(n/2,b(n/2+1),-one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's278 ' ) then
X         call set1d(n/2,a,-one,unit)
X         call set1d(n/2,a(n/2+1),one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's279 ' ) then
X         call set1d(n/2,a,-one,unit)
X         call set1d(n/2,a(n/2+1),one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's2710' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's2711' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's2712' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's281 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X      elseif ( name .eq. 's291 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X      elseif ( name .eq. 's292 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X      elseif ( name .eq. 's293 ' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's2101' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any,frac)
X         call set2d(n,cc, any,frac)
X      elseif ( name .eq. 's2102' ) then
X         call set2d(n,aa,zero,unit)
X      elseif ( name .eq. 's2111' ) then
X         call set2d(n,aa,zero,unit)
X      elseif ( name .eq. 's311 ' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's312 ' ) then
X         call set1d(n,a,1.000001d0,unit)
X      elseif ( name .eq. 's313 ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's314 ' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's315 ' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's316 ' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's317 ' ) then
X         continue
X      elseif ( name .eq. 's318 ' ) then
X         call set1d(n,  a, any,frac)
X         a(n) = -two
X      elseif ( name .eq. 's319 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b,zero,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's3110' ) then
X         call set2d(n,aa, any,frac)
X         aa(n,n) = two
X      elseif ( name .eq. 's3111' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 's3112' ) then
X         call set1d(n,  a, any,frac2)
X         call set1d(n,  b,zero,unit)
X      elseif ( name .eq. 's3113' ) then
X         call set1d(n,  a, any,frac)
X         a(n) = -two
X      elseif ( name .eq. 's321 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b,zero,unit)
X      elseif ( name .eq. 's322 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b,zero,unit)
X         call set1d(n,  c,zero,unit)
X      elseif ( name .eq. 's323 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's331 ' ) then
X         call set1d(n,  a, any,frac)
X         a(n) = -one
X      elseif ( name .eq. 's332 ' ) then
X         call set1d(n,  a, any,frac2)
X         a(n) = two
X      elseif ( name .eq. 's341 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's342 ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's343 ' ) then
X         call set2d(n,aa, any,frac)
X         call set2d(n,bb, one,unit)
X      elseif ( name .eq. 's351 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         c(1) = 1.
X      elseif ( name .eq. 's352 ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's353 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         c(1) = 1.
X      elseif ( name .eq. 's411 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's412 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's413 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's414 ' ) then
X         call set2d(n,aa, one,unit)
X         call set2d(n,bb, any,frac)
X         call set2d(n,cc, any,frac)
X      elseif ( name .eq. 's415 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         a(n) = -one
X      elseif ( name .eq. 's421 ' ) then
X         call set1d(n,  a, any,frac2)
X      elseif ( name .eq. 's422 ' ) then
X         call set1d(n,array,one,unit)
X         call set1d(n,  a, any,frac2)
X      elseif ( name .eq. 's423 ' ) then
X         call set1d(n,array,zero,unit)
X         call set1d(n,  a, any,frac2)
X      elseif ( name .eq. 's424 ' ) then
X         call set1d(n,array,one,unit)
X         call set1d(n,  a, any,frac2)
X      elseif ( name .eq. 's431 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's432 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's441 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set1d(n/3,   d(1),        -one,unit)
X         call set1d(n/3,   d(1+n/3),    zero,unit)
X         call set1d(n/3+1, d(1+(2*n/3)), one,unit)
X      elseif ( name .eq. 's442 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's443 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's451 ' ) then
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's452 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c,small,unit)
X      elseif ( name .eq. 's453 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 's471 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, one,unit)
X         call set1d(n,  d, any,frac)
X         call set1d(n,  e, any,frac)
X      elseif ( name .eq. 's481 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's482 ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 's491 ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's4112' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's4113' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac2)
X      elseif ( name .eq. 's4114' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's4115' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 's4116' ) then
X         call set1d(n, a, any,frac)
X         call set2d(n,aa, any,frac)
X      elseif ( name .eq. 's4117' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c, any,frac)
X         call set1d(n,  d, any,frac)
X      elseif ( name .eq. 's4121' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 'va   ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vag  ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vas  ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vif  ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vpv  ' ) then
X         call set1d(n,  a,zero,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vtv  ' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, one,unit)
X      elseif ( name .eq. 'vpvtv' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, any,frac)
X      elseif ( name .eq. 'vpvts' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, any,frac2)
X      elseif ( name .eq. 'vpvpv' ) then
X         call set1d(n,  a, any,frac2)
X         call set1d(n,  b, one,unit)
X         call set1d(n,  c,-one,unit)
X      elseif ( name .eq. 'vtvtv' ) then
X         call set1d(n,  a, one,unit)
X         call set1d(n,  b, two,unit)
X         call set1d(n,  c,half,unit)
X      elseif ( name .eq. 'vsumr' ) then
X         call set1d(n,  a, any,frac)
X      elseif ( name .eq. 'vdotr' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X      elseif ( name .eq. 'vbor ' ) then
X         call set1d(n,  a, any,frac)
X         call set1d(n,  b, any,frac)
X         call set1d(n,  c, one,frac)
X         call set1d(n,  d, two,frac)
X         call set1d(n,  e,half,frac)
X         call set2d(n, aa, any,frac)
X      else
X        print*,'COULDN''T FIND ',name,' TO INITIALIZE'
X      endif
X
X      return
X      end
X
X
X      subroutine info(ctime,dtime,c471s)
X      real ctime, dtime, c471s
c
c --  Please fill in the information below as best you can.  Additional
c --  information you feel useful may be entered in the comments section.
c --  Thanks to the SLALOM benchmark for the idea for this subroutine.
c
X      character*72 who(7), run(3), cmpter(15), coment(6)
X      data who   /
X     &' Run by:                  Mr./Ms. Me',
X     &' Address:                 My_Company',
X     &' Address:                 My_Address',
X     &' Address:                 My_City, My_State, My_Zipcode',
X     &' Phone:                   (123)-456-7890',
X     &' FAX:                     (123)-456-7890',
X     &' Electronic mail:         me@company.com'/
X      data run    /
X     &' Scalar/Vector run:       Scalar',
X     &' Timer:                   User CPU, etime()',
X     &' Standalone:              Yes'/
X      data cmpter /
X     &' Computer:                Fast_Computer 1',
X     &' Compiler/version:        f77 3.1',
X     &' Compiler options:        -O',
X     &' Availability date:       Now',
X     &' OS/version:              Un*x, 1.0',
X     &' Cache size:              none',
X     &' Main memory size:        128MB',
X     &' No. vec. registers:      8',
X     &' Vec. register length:    128',
X     &' No. functional units:    2 add, 2 multiply',
X     &' Chaining supported:      no',
X     &' Overlapping supported:   independent add and mutiply units',
X     &' Memory paths:            2 load, 1 store',
X     &' Memory path width        4 64-bit words per clock, per pipe',
X     &' Clock speed:             4ns.'/
c
c -- Enter any comments you think may be important.
c -- Feel free to increase the number of comment lines
c
X      data coment /
X     &' Comments:',
X     &' Comments:',
X     &' Comments:',
X     &' Comments:',
X     &' Comments:',
X     &' Comments:'/
X
X      write (*, *) ' '
X      write (*, '(a72)') who
X      write (*, '(a72)') run
X      write (*, '(a72)') cmpter
X      write (*, 99) 'Cost of timing call:', ctime
X      write (*, 99) 'Cost of dummy  call:', dtime
X      write (*, 99) 'Cost of c471s  call:', c471s
X      write (*, '(a72)') coment
X99    format(1x,a20,5x,f12.10)
X      return
X      end
X
END_OF_FILE
if test 60569 -ne `wc -c <'maind.f'`; then
    echo shar: \"'maind.f'\" unpacked with wrong size!
fi
# end of 'maind.f'
fi
if test -f 'loopd.f' -a "${1}" != "-c" ; then
  echo shar: Will not clobber existing file \"'loopd.f'\"
else
echo shar: Extracting \"'loopd.f'\" \(122064 characters\)
sed "s/^X//" >'loopd.f' <<'END_OF_FILE'
c***********************************************************************
c                TEST SUITE FOR VECTORIZING COMPILERS                  *
c                        (File 2 of 2)                                 *
c                                                                      *
c  Version:   2.0                                                      *
c  Date:      3/14/88                                                  *
c  Authors:   Original loops from a variety of                         *
c             sources. Collection and synthesis by                     *
c                                                                      *
c             David Callahan  -  Tera Computer                         *
c             Jack Dongarra   -  University of Tennessee               *
c             David Levine    -  Argonne National Laboratory           *
c***********************************************************************
c  Version:   3.0                                                      *
c  Date:      1/4/91                                                   *
c  Authors:   David Levine    -  Executable version                    *
c***********************************************************************
c                         ---DESCRIPTION---                            *
c                                                                      *
c  This test consists of a variety of  loops that represent different  *
c  constructs  intended   to  test  the   analysis  capabilities of a  *
c  vectorizing  compiler.  Each loop is  executed with vector lengths  *
c  of 10, 100, and 1000.   Also included  are several simple  control  *
c  loops  intended  to  provide  a  baseline  measure  for  comparing  *
c  compiler performance on the more complicated loops.                 *
c                                                                      *
c  The  output from a  run  of the test  consists of seven columns of  *
c  data:                                                               *
c     Loop:        The name of the loop.                               *
c     VL:          The vector length the loop was run at.              *
c     Seconds:     The time in seconds to run the loop.                *
c     Checksum:    The checksum calculated when running the test.      *
c     PreComputed: The precomputed checksum (64-bit IEEE arithmetic).  *
c     Residual:    A measure of the accuracy of the calculated         *
c                  checksum versus the precomputed checksum.           *
c     No.:         The number of the loop in the test suite.           *
c                                                                      *
c  The  residual  calculation  is  intended  as  a  check  that   the  *
c  computation  was  done  correctly  and  that 64-bit arithmetic was  *
c  used.   Small   residuals    from    non-IEEE    arithmetic    and  *
c  nonassociativity  of   some calculations  are   acceptable.  Large  *
c  residuals  from   incorrect  computations or  the  use   of 32-bit  *
c  arithmetic are not acceptable.                                      *
c                                                                      *
c  The test  output  itself  does not report   any  results;  it just  *
c  contains data.  Absolute  measures  such as Mflops and  total time  *
c  used  are  not   appropriate    metrics  for  this  test.   Proper  *
c  interpretation of the results involves correlating the output from  *
c  scalar and vector runs  and the  loops which  have been vectorized  *
c  with the speedup achieved at different vector lengths.              *
c                                                                      *
c  These loops  are intended only  as  a partial test of the analysis  *
c  capabilities of a vectorizing compiler (and, by necessity,  a test  *
c  of the speed and  features  of the underlying   vector  hardware).  *
c  These loops  are  by no means  a  complete  test  of a vectorizing  *
c  compiler and should not be interpreted as such.                     *
c                                                                      *
c***********************************************************************
c                           ---DIRECTIONS---                           *
c                                                                      *
c  To  run this  test,  you will  need  to  supply  a  function named  *
c  second() that returns user CPU time.                                *
c                                                                      *
c  This test is distributed as two separate files, one containing the  *
c  driver  and  one containing the loops.   These  two files MUST  be  *
c  compiled separately.                                                *
c                                                                      *
c  Results must  be supplied from  both scalar and vector  runs using  *
c  the following rules for compilation:                                *
c                                                                      *
c     Compilation   of the  driver  file must  not  use any  compiler  *
c     optimizations (e.g., vectorization, function  inlining,  global  *
c     optimizations,...).   This   file   also must  not  be analyzed  *
c     interprocedurally to  gather information useful  in  optimizing  *
c     the test loops.                                                  *
c                                                                      *
c     The file containing the  loops must be compiled twice--once for  *
c     a scalar run and once for a vector run.                          *
c                                                                      *
c        For the scalar  run, global (scalar) optimizations should be  *
c        used.                                                         *
c                                                                      *
c        For  the  vector run,  in  addition   to  the  same   global  *
c        optimizations specified  in the scalar   run,  vectorization  *
c        and--if available--automatic  call generation to   optimized  *
c        library  routines,  function inlining,  and  interprocedural  *
c        analysis should be  used.  Note again that function inlining  *
c        and interprocedural  analysis  must  not be  used to  gather  *
c        information  about any of the  program  units  in the driver  *
c        program.                                                      *
c                                                                      *
c     No changes  may  be made  to   the   source code.   No compiler  *
c     directives may be used, nor may  a file  be split into separate  *
c     program units.  (The exception is  filling  in  the information  *
c     requested in subroutine "info" as described below.)              *
c                                                                      *
c     All files must be compiled to use 64-bit arithmetic.             *
c                                                                      *
c     The  outer  timing  loop  is  included  only   to increase  the  *
c     granularity of the calculation.  It should not be vectorizable.  *
c     If it is found to be so, please notify the authors.              *
c                                                                      *
c  All runs  must be  made  on a standalone  system  to minimize  any  *
c  external effects.                                                   *
c                                                                      *
c  On virtual memory computers,  runs should be  made with a physical  *
c  memory and working-set  size  large enough  that  any  performance  *
c  degradation from page  faults is negligible.   Also,  the  timings  *
c  should be repeatable  and you  must  ensure  that timing anomalies  *
c  resulting from paging effects are not present.                      *
c                                                                      *
c  You should edit subroutine "info"   (the  last subroutine  in  the  *
c  driver program) with  information specific to your  runs, so  that  *
c  the test output will be annotated automatically.                    *
c                                                                      *
c  Please return the following three files in an electronic format:    *
c                                                                      *
c  1. Test output from a scalar run.                                   *
c  2. Test output from a vector run.                                   *
c  3. Compiler output listing (source echo, diagnostics, and messages) *
c     showing which loops have been vectorized.                        *
c                                                                      *
c  The preferred media  for receipt, in order  of preference, are (1)  *
c  electronic mail, (2) 9-track  magnetic or  cartridge tape in  Unix  *
c  tar  format, (3) 5" IBM PC/DOS  floppy   diskette, or  (4) 9-track  *
c  magnetic  tape in  ascii  format,   80 characters per card,  fixed  *
c  records, 40 records per block, 1600bpi.  Please return to           *
c                                                                      *
c  David Levine       		                                       *
c  Mathematics and Computer Science Division                           *
c  Argonne National Laboratory                                         *
c  Argonne, Illinois 60439                                             *
c  levine@mcs.anl.gov                                                  *
c***********************************************************************
c%1.1
X      subroutine s111 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     no dependence - vectorizable
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s111 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      do 10 i = 2,n,2
X         a(i) = a(i-1) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s111 ')
X      return
X      end
c%1.1
X      subroutine s112 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     loop reversal
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s112 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = n-1,1,-1
X         a(i+1) = a(i) + b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s112 ')
X      return
X      end
c%1.1
X      subroutine s113 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     a(i)=a(1) but no actual dependence cycle
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s113 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = a(1) + b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s113 ')
X      return
X      end
c%1.1
X      subroutine s114 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     transpose vectorization
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s114 ')
X      t1 = second()
X      do 1 nl = 1,2*(ntimes/n)
X      do 10 j = 1,n
X         do 20 i = 1,j-1
X            aa(i,j) = aa(j,i) + bb(i,j)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*(ntimes/n)) )
X      chksum = cs2d(n,aa)
X      call check (chksum,2*(ntimes/n)*((n*n-n)/2),n,t2,'s114 ')
X      return
X      end
c%1.1
X      subroutine s115 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     triangular saxpy loop
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s115 ')
X      t1 = second()
X      do 1 nl = 1,2*(ntimes/n)
X      do 10 j = 1,n
X         do 20 i = j+1, n
X            a(i) = a(i) - aa(i,j) * a(j)
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*(ntimes/n)) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*(ntimes/n)*((n*n-n)/2),n,t2,'s115 ')
X      return
X      end
c%1.1
X      subroutine s116 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s116 ')
X      t1 = second()
X      do 1 nl = 1,5*ntimes
X      do 10 i = 1,n-5,5
X         a(i)   = a(i+1) * a(i)
X         a(i+1) = a(i+2) * a(i+1)
X         a(i+2) = a(i+3) * a(i+2)
X         a(i+3) = a(i+4) * a(i+3)
X         a(i+4) = a(i+5) * a(i+4)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(5*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,5*ntimes*(n/5),n,t2,'s116 ')
X      return
X      end
c%1.1
X      subroutine s118 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     potential dot product recursion
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s118 ')
X      t1 = second()
X      do 1 nl = 1,2*(ntimes/n)
X      do 10 i = 2,n
X         do 20 j = 1,i-1
X               a(i) = a(i) + bb(i,j) * a(i-j)
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*(ntimes/n)) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*(ntimes/n)*((n*n-n)/2),n,t2,'s118 ')
X      return
X      end
c%1.1
X      subroutine s119 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     linear dependence testing
c     no dependence - vectorizable
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s119 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 j = 2,n
X         do 20 i = 2,n
X            aa(i,j) = aa(i-1,j-1) + bb(i,j)
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      call check (chksum,(ntimes/n)*(n-1)*(n-1),n,t2,'s119 ')
X      return
X      end
c%1.2
X      subroutine s121 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     loop with possible ambiguity because of scalar store
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s121 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n-1
X         j = i+1
X         a(i) = a(j) + b(i)
X10    continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X1     continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s121 ')
X      return
X      end
c%1.2
X      subroutine s122 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1,n3)
c
c     induction variable recognition
c     variable lower and upper bound, and stride
c
X      integer ntimes, ld, n, i, nl, j, k, n1, n3
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s122 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      j = 1
X      k = 0
X      do 10 i=n1,n,n3
X         k = k + j
X         a(i) = a(i) + b(n-k+1)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s122 ')
X      return
X      end
c%1.2
X      subroutine s123 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     induction variable under an if
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s123 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      j = 0
X      do 10 i = 1,n/2
X         j = j + 1
X         a(j) = b(i) + d(i) * e(i)
X         if(c(i) .gt. 0.d0) then
X            j = j + 1
X            a(j) = c(i)+ d(i) * e(i)
X         endif
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s123 ')
X      return
X      end
c%1.2
X      subroutine s124 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     induction variable under both sides of if (same value)
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s124 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      j = 0
X      do 10 i = 1,n/2
X         if(b(i) .gt. 0.d0) then
X            j = j + 1
X            a(j) = b(i) + d(i) * e(i)
X            else
X            j = j + 1
X            a(j) = c(i) + d(i) * e(i)
X         endif
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s124 ')
X      return
X      end
c%1.2
X      subroutine s125 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     induction variable in two loops; collapsing possible
c
X
X      integer ntimes, ld, n, i, nl, j, k, nn
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, array
X      real t1, t2, second, ctime, dtime
X      parameter(nn=1000)
X      common /cdata/ array(nn*nn)
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s125 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      k = 0
X      do 10 j = 1,n
X         do 20 i = 1,n
X            k = k + 1
X            array(k) = aa(i,j) + bb(i,j) * cc(i,j)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs1d(n*n,array)
X      call check (chksum,(ntimes/n)*n*n,n,t2,'s125 ')
X      return
X      end
c%1.2
X      subroutine s126 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     induction variable in two loops; recurrence in inner loop
c
X      integer ntimes, ld, n, i, nl, j, k, nn
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d, array
X      real t1, t2, second, ctime, dtime
X      parameter(nn=1000)
X      common /cdata/ array(nn*nn)
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s126 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      k = 1
X      do 10 i = 1,n
X         do 20 j = 2,n
X            bb(i,j) = bb(i,j-1) + array(k) * cc(i,j)
X            k = k + 1
X   20    continue
X         k = k + 1
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,bb)
X      call check (chksum,(ntimes/n)*n*(n-1),n,t2,'s126 ')
X      return
X      end
c%1.2
X      subroutine s127 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variable recognition
c     induction variable with multiple increments
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s127 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      j = 0
X      do 10 i = 1,n/2
X         j = j + 1
X         a(j) = b(i) + c(i) * d(i)
X         j = j + 1
X         a(j) = b(i) + d(i) * e(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s127 ')
X      return
X      end
c%1.2
X      subroutine s128 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     induction variables
c     coupled induction variables
c
X      integer ntimes, ld, n, i, nl, j, k
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s128 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      j = 0
X      do 10 i = 1, n/2
X         k = j + 1
X         a(i) = b(k) - d(i)
X         j = k + 1
X         b(k) = a(i) + c(k)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s128 ')
X      return
X      end
c%1.3
X      subroutine s131 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     global data flow analysis
c     forward substitution
c
X      integer ntimes, ld, n, i, nl, m
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      m = 1
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s131 ')
X      if(a(1).gt.0.d0)then
X         a(1) = b(1)
X      endif
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         a(i) = a(i+m) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s131 ')
X      return
X      end
c%1.3
X      subroutine s132 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     global data flow analysis
c     loop with multiple dimension ambiguous subscripts
c
X      integer ntimes, ld, n, i, nl, j, k, m
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      m = 1
X      j = m
X      k = m+1
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s132 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i=2,n
X         aa(i,j) = aa(i-1,k) + b(i) * c(k)
X10    continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X1     continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs2d(n,aa)
X      call check (chksum,ntimes*n-1,n,t2,'s132 ')
X      return
X      end
c%1.4
X      subroutine s141 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     nonlinear dependence testing
c     walk a row in a symmetric packed array
c     element a(i,j) for (j>i) stored in location j*(j-1)/2+i
c
X      integer ntimes, ld, n, i, nl, j, k, nn
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, array
X      real t1, t2, second, ctime, dtime
X      parameter(nn=1000)
X      common /cdata/ array(nn*nn)
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s141 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 1,n
X         k = i*(i-1)/2+i
X         do 20 j = i,n
X	    array(k) = array(k) + bb(i,j)
X	    k = k + j
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs1d(n*n,array)
X      call check (chksum,(ntimes/n)*n*n,n,t2,'s141 ')
X      return
X      end
c%1.5
X      subroutine s151 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     interprocedural data flow analysis
c     passing parameter information into a subroutine
c
X      integer ntimes, ld, n, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s151 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      call s151s(a,b,n,1)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s151 ')
X      return
X      end
X      subroutine s151s(a,b,n,m)
X      integer i, n, m
X      double precision a(n), b(n)
X      do 10 i = 1,n-1
X         a(i) = a(i+m) + b(i)
X  10  continue
X      return
X      end
c%1.5
X      subroutine s152 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     interprocedural data flow analysis
c     collecting information from a subroutine
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s152 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         b(i) = d(i) * e(i)
X         call s152s(a,b,c,i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s152 ')
X      return
X      end
X      subroutine s152s(a,b,c,i)
X      integer i
X      double precision a(*), b(*), c(*)
X      a(i) = a(i) + b(i) * c(i)
X      return
X      end
c%1.6
X      subroutine s161 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     tests for recognition of loop independent dependences
c     between statements in mutually exclusive regions.
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s161 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         if (b(i) .lt. 0.d0) go to 20
X         a(i)   = c(i) + d(i) * e(i)
X         go to 10
X   20    c(i+1) = a(i) + d(i) * d(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,c)
X      call check (chksum,ntimes*(n-1),n,t2,'s161 ')
X      return
X      end
c%1.6
X      subroutine s162 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,k)
c
c     control flow
c     deriving assertions
c
X      integer ntimes, ld, n, i, nl, k
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s162 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      if ( k .gt. 0 ) then
X         do 10 i = 1,n-1
X            a(i) = a(i+k) + b(i) * c(i)
X10       continue
X      endif
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s162 ')
X      return
X      end
c%1.7
X      subroutine s171 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,inc)
c
c     symbolics
c     symbolic dependence tests
c
X      integer ntimes, ld, n, i, nl, inc
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s171 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i*inc) = a(i*inc) + b(i)
X 10   continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X 1    continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s171 ')
X      return
X      end
c%1.7
X      subroutine s172 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,n1,n3)
c
c     symbolics
c     vectorizable if n3 .ne. 0
c
X      integer ntimes, ld, n, i, nl, n1, n3
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s172 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = n1,n,n3
X         a(i) = a(i) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s172 ')
X      return
X      end
c%1.7
X      subroutine s173 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     symbolics
c     expression in loop bounds and subscripts
c
X      integer ntimes, ld, n, i, nl, k
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      k = n/2
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s173 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      do 10 i = 1,n/2
X            a(i+k) = a(i) +  b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s173 ')
X      return
X      end
c%1.7
X      subroutine s174 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     symbolics
c     loop with subscript that may seem ambiguous
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s174 ')
X      t1 = second()
X      do 1 nl = 1,2*ntimes
X      do 10 i= 1, n/2
X         a(i) = a(i+n/2) + b(i)
X10    continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X1     continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,2*ntimes*(n/2),n,t2,'s174 ')
X      return
X      end
c%1.7
X      subroutine s175 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,inc)
c
c     symbolics
c     symbolic dependence tests
c
X      integer ntimes, ld, n, i, nl, inc
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s175 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1,inc
X         a(i) = a(i+inc) + b(i)
X 10   continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X 1    continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s175 ')
X      return
X      end
c%1.7
X      subroutine s176 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     symbolics
c     convolution
c
X      integer ntimes, ld, n, i, nl, j, m
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      m = n/2
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s176 ')
X      t1 = second()
X      do 1 nl = 1,4*(ntimes/n)
X      do 10 j = 1,n/2
X        do 20 i = 1,m
X           a(i) = a(i) + b(i+m-j) * c(j)
X   20   continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(4*(ntimes/n)) )
X      chksum = cs1d(n,a)
X      call check (chksum,4*(ntimes/n)*(n/2)*(n/2),n,t2,'s176 ')
X      return
X      end
c
c**********************************************************
c                                                         *
c                      VECTORIZATION                      *
c                                                         *
c**********************************************************
c%2.1
X      subroutine s211 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     statement reordering
c     statement reordering allows vectorization
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s211 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n-1
X         a(i) = b(i-1) + c(i) * d(i)
X         b(i) = b(i+1) - e(i) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-2),n,t2,'s211 ')
X      return
X      end
c%2.1
X      subroutine s212 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     statement reordering
c     dependency needing temporary
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s212 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i=1,n-1
X         a(i) = a(i) * c(i)
X         b(i) = b(i) + a(i+1) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s212 ')
X      return
X      end
c%2.2
X      subroutine s221 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop distribution
c     loop that is partially recursive
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s221 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = a(i)   + c(i) * d(i)
X         b(i) = b(i-1) + a(i) + d(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s221 ')
X      return
X      end
c%2.2
X      subroutine s222 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop distribution
c     partial loop vectorization, recurrence in middle
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s222 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = a(i)   + b(i)   * c(i)
X         b(i) = b(i-1) * b(i-1) * a(i)
X         a(i) = a(i)   - b(i)   * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s222 ')
X      return
X      end
c%2.3
X      subroutine s231 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop interchange
c     loop with multiple dimension recursion
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s231 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i=1,n
X         do 20 j=2,n
X            aa(i,j) = aa(i,j-1) + bb(i,j)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      call check (chksum,(ntimes/n)*n*(n-1),n,t2,'s231 ')
X      return
X      end
c%2.3
X      subroutine s232 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop interchange
c     interchanging of triangular loops
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s232 ')
X      t1 = second()
X      do 1 nl = 1,2*(ntimes/n)
X      do 10 j = 2,n
X         do 20 i = 2,j
X            aa(i,j) = aa(i-1,j)*aa(i-1,j)+bb(i,j)
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(2*(ntimes/n)) )
X      chksum = cs2d(n,aa)
X      call check (chksum,2*(ntimes/n)*((n*n-n)/2),n,t2,'s232 ')
X      return
X      end
c%2.3
X      subroutine s233 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop interchange
c     interchanging with one of two inner loops
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s233 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 2,n
X         do 20 j = 2,n
X            aa(i,j) = aa(i,j-1) + cc(i,j)
X  20     continue
X         do 30 j = 2,n
X            bb(i,j) = bb(i-1,j) + cc(i,j)
X  30     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa) + cs2d(n,bb)
X      call check (chksum,(ntimes/n)*(n-1)*(2*n-2),n,t2,'s233 ')
X      return
X      end
c%2.3
X      subroutine s234 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop interchange
c     if loop to do loop, interchanging with if loop necessary
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s234 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      i = 1
X   11 if(i.gt.n) goto 10
X         j = 2
X   21    if(j.gt.n) goto 20
X            aa(i,j) = aa(i,j-1) + bb(i,j-1) * cc(i,j-1)
X            j = j + 1
X         goto 21
X   20 i = i + 1
X      goto 11
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      call check (chksum,(ntimes/n)*n*(n-1),n,t2,'s234 ')
X      return
X      end
c%2.3
X      subroutine s235 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop interchanging
c     imperfectly nested loops
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s235 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 1,n
X         a(i) =  a(i) + b(i) * c(i)
X         do 20 j = 2,n
X            aa(i,j) = aa(i,j-1) +  bb(i,j) * a(i)
X  20     continue
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa) + cs1d(n,a)
X      call check (chksum,(ntimes/n)*n*(n-1),n,t2,'s235 ')
X      return
X      end
c%2.4
X      subroutine s241 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     node splitting
c     preloading necessary to allow vectorization
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s241 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         a(i) = b(i) * c(i)   * d(i)
X         b(i) = a(i) * a(i+1) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s241 ')
X      return
X      end
c%2.4
X      subroutine s242 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s1,s2)
c
c     node splitting
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s1, s2
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s242 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = a(i-1) + s1 + s2 + b(i) + c(i) + d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s242 ')
X      return
X      end
c%2.4
X      subroutine s243 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     node splitting
c     false dependence cycle breaking
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s243 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         a(i) = b(i) + c(i)   * d(i)
X         b(i) = a(i) + d(i)   * e(i)
X         a(i) = b(i) + a(i+1) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s243 ')
X      return
X      end
c%2.4
X      subroutine s244 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     node splitting
c     false dependence cycle breaking
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s244 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         a(i)   = b(i) + c(i)   * d(i)
X         b(i)   = c(i) + b(i)
X         a(i+1) = b(i) + a(i+1) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s244 ')
X      return
X      end
c%2.5
X      subroutine s251 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     scalar expansion
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s251 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         s    = b(i) + c(i) * d(i)
X         a(i) = s * s
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s251 ')
X      return
X      end
c%2.5
X      subroutine s252 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     loop with ambiguous scalar temporary
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s, t
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s252 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      t = 0.d0
X      do 10 i=1,n
X         s    = b(i) * c(i)
X         a(i) = s + t
X         t    = s
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s252 ')
X      return
X      end
c%2.5
X      subroutine s253 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     scalar expansion, assigned under if
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s253 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if(a(i) .gt. b(i))then
X            s    = a(i) - b(i) * d(i)
X            c(i) = c(i) + s
X            a(i) = s
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,c)
X      call check (chksum,ntimes*n,n,t2,'s253 ')
X      return
X      end
c%2.5
X      subroutine s254 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     carry around variable
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s254 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      x = b(n)
X      do 10 i = 1,n
X         a(i) = (b(i) + x) * .5d0
X         x    =  b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s254 ')
X      return
X      end
c%2.5
X      subroutine s255 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     carry around variables, 2 levels
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, x, y
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s255 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      x = b(n)
X      y = b(n-1)
X      do 10 i = 1,n
X         a(i) = (b(i) + x + y) * .333d0
X         y    =  x
X         x    =  b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s255 ')
X      return
X      end
c%2.5
X      subroutine s256 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     array expansion
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s256 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 1,n
X         do 20 j = 2,n
X            a(j)    = aa(i,j) - a(j-1)
X            aa(i,j) = a(j) + bb(i,j)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs1d(n,a) + cs2d(n,aa)
X      call check (chksum,(ntimes/n)*n*(n-1),n,t2,'s256 ')
X      return
X      end
c%2.5
X      subroutine s257 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     array expansion
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s257 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 2,n
X         do 20 j = 1,n
X            a(i)    = aa(i,j) - a(i-1)
X            aa(i,j) = a(i) + bb(i,j)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs1d(n,a) + cs2d(n,aa)
X      call check (chksum,(ntimes/n)*(n-1)*n,n,t2,'s257 ')
X      return
X      end
c%2.5
X      subroutine s258 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar and array expansion
c     wrap-around scalar under an if
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s258 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      s = 0.d0
X      do 10 i = 1,n
X         if (a(i) .gt. 0.d0) then
X            s = d(i) * d(i)
X         endif
X         b(i) = s * c(i) + d(i)
X         e(i) = (s + 1.d0) * aa(i,1)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,b) + cs1d(n,e)
X      call check (chksum,ntimes*n,n,t2,'s258 ')
X      return
X      end
c%2.6
X      subroutine s261 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     scalar renaming
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, t
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s261 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         t    = a(i) + b(i)
X         a(i) = t    + c(i-1)
X         t    = c(i) * d(i)
X         c(i) = t
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,c)
X      call check (chksum,ntimes*(n-1),n,t2,'s261 ')
X      return
X      end
c%2.7
X      subroutine s271 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     loop with singularity handling
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s271 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i=1,n
X         if (b(i) .gt. 0.d0) a(i) = a(i) + b(i) * c(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s271 ')
X      return
X      end
c%2.7
X      subroutine s272 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,t)
c
c     control flow
c     loop with independent conditional
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, t
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s272 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         if (e(i) .ge. t) then
X            a(i) = a(i) + c(i) * d(i)
X            b(i) = b(i) + c(i) * c(i)
X         endif
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*n,n,t2,'s272 ')
X      return
X      end
c%2.7
X      subroutine s273 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     simple loop with dependent conditional
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s273 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1 , n
X         a(i) = a(i) + d(i) * e(i)
X         if (a(i) .lt. 0.d0) b(i) = b(i) + d(i) * e(i)
X         c(i) = c(i) + a(i) * d(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b) + cs1d(n,c)
X      call check (chksum,ntimes*n,n,t2,'s273 ')
X      return
X      end
c%2.7
X      subroutine s274 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     complex loop with dependent conditional
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s274 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1 , n
X         a(i) = c(i) + e(i) * d(i)
X         if (a(i) .gt. 0.d0) then
X            b(i) = a(i) + b(i)
X         else
X            a(i) = d(i) * e(i)
X         endif
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*n,n,t2,'s274 ')
X      return
X      end
c%2.7
X      subroutine s275 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     if around inner loop, interchanging needed
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s275 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 2,n
X         if(aa(i,1) .gt. 0.d0)then
X            do 20 j = 2,n
X              aa(i,j) = aa(i,j-1) + bb(i,j) * cc(i,j)
X  20        continue
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      call check (chksum,(ntimes/n)*(n-1)*(n-1),n,t2,'s275 ')
X      return
X      end
c%2.7
X      subroutine s276(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     if test using loop index
c
X      integer ntimes, ld, n, i, nl, mid
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s276 ')
X      t1 = second()
X      mid = n/2
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X        if ( i .lt. mid ) then
X           a(i) = a(i) + b(i) * c(i)
X        else
X           a(i) = a(i) + b(i) * d(i)
X        endif
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s276 ')
X      return
X      end
c%2.7
X      subroutine s277 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     test for dependences arising from guard variable computation.
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s277 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X        if (a(i) .ge. 0.d0) go to 20
X        if (b(i) .ge. 0.d0) go to 30
X           a(i)   = a(i) + c(i) * d(i)
X   30   continue
X           b(i+1) = c(i) + d(i) * e(i)
X   20 continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s277 ')
X      return
X      end
c%2.7
X      subroutine s278 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     if/goto to block if-then-else
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s278 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if (a(i) .gt. 0.d0) goto 20
X            b(i) = -b(i) + d(i) * e(i)
X         goto 30
X  20     continue
X            c(i) = -c(i) + d(i) * e(i)
X  30     continue
X            a(i) =  b(i) + c(i) * d(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b) + cs1d(n,c)
X      call check (chksum,ntimes*n,n,t2,'s278 ')
X      return
X      end
c%2.7
X      subroutine s279 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     vector if/gotos
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s279 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if (a(i) .gt. 0.d0) goto 20
X            b(i) = -b(i) + d(i) * d(i)
X         if (b(i) .le. a(i)) goto 30
X            c(i) =  c(i) + d(i) * e(i)
X         goto 30
X  20     continue
X            c(i) = -c(i) + e(i) * e(i)
X  30     continue
X            a(i) =  b(i) + c(i) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b) + cs1d(n,c)
X      call check (chksum,ntimes*n,n,t2,'s279 ')
X      return
X      end
c%2.7
X      subroutine s2710(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,x)
c
c     control flow
c     scalar and vector ifs
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2710')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if(a(i) .gt. b(i))then
X            a(i) = a(i) + b(i) * d(i)
X            if(n .gt. 10)then
X               c(i) =  c(i) + d(i) * d(i)
X            else
X               c(i) =  1.0d0  + d(i) * e(i)
X            endif
X         else
X            b(i) = a(i) + e(i) * e(i)
X            if(x .gt. 0.d0)then
X               c(i) =  a(i) + d(i) * d(i)
X            else
X               c(i) =  c(i) + e(i) * e(i)
X            endif
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b) + cs1d(n,c)
X      call check (chksum,ntimes*n,n,t2,'s2710')
X      return
X      end
c%2.7
X      subroutine s2711(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     semantic if removal
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2711')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if(b(i) .ne. 0.d0) a(i) = a(i) + b(i) * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s2711')
X      return
X      end
c%2.7
X      subroutine s2712(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control flow
c     if to elemental min
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2712')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if(a(i) .gt. b(i)) a(i) = a(i) + b(i) * c(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s2712')
X      return
X      end
c%2.8
X      subroutine s281 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     crossing thresholds
c     index set splitting
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s281 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         x    = a(n-i+1) + b(i) * c(i)
X         a(i) = x - 1.0d0
X         b(i) = x
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*n,n,t2,'s281 ')
X      return
X      end
c%2.9
X      subroutine s291 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop peeling
c     wrap around variable, 1 level
c
X      integer ntimes, ld, n, i, nl, im1
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s291 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      im1 = n
X      do 10 i = 1,n
X         a(i) = (b(i) + b(im1)) * .5d0
X         im1  = i
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s291 ')
X      return
X      end
c%2.9
X      subroutine s292 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop peeling
c     wrap around variable, 2 levels
c
X      integer ntimes, ld, n, i, nl, im1, im2
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s292 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      im1 = n
X      im2 = n-1
X      do 10 i = 1,n
X         a(i) = (b(i) + b(im1) + b(im2)) * .333d0
X         im2 = im1
X         im1 = i
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s292 ')
X      return
X      end
c%2.9
X      subroutine s293 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop peeling
c     a(i)=a(1) with actual dependence cycle, loop is vectorizable
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s293 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(1)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s293 ')
X      return
X      end
c%2.10
X      subroutine s2101(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     diagonals
c     main diagonal calculation
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2101')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         aa(i,i) = aa(i,i) + bb(i,i) * cc(i,i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs2d(n,aa)
X      call check (chksum,ntimes*n,n,t2,'s2101')
X      return
X      end
c%2.12
X      subroutine s2102(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     diagonals
c     identity matrix, best results vectorize both inner and outer loops
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2102')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      do 10 i = 1, n
X         do 20 j = 1,n
X            aa(i,j) = 0.d0
X   20    continue
X         aa(i,i) = 1.d0
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      call check (chksum,(ntimes/n)*n*n,n,t2,'s2102')
X      return
X      end
c%2.11
X      subroutine s2111 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     wavefronts
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s2111')
X      t1 = second()
X      do 1 nl = 1,(ntimes/n)
X      do 10 j = 2,n
X         do 20 i = 2,n
X            aa(i,j) = aa(i-1,j) + aa(i,j-1)
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa)
X      if (chksum .eq. 0.d0)chksum = 3.d0
X      call check (chksum,(ntimes/n)*(n-1)*(n-1),n,t2,'s2111')
X      return
X      end
c
c**********************************************************
c                                                         *
c                   IDIOM RECOGNITION                     *
c                                                         *
c**********************************************************
c%3.1
X      subroutine s311 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     sum reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s311 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1,n
X         sum = sum + a(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,sum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*n,n,t2,'s311 ')
X      return
X      end
c%3.1
X      subroutine s312 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     product reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, prod
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s312 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      prod = 1.d0
X      do 10 i = 1,n
X         prod = prod * a(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,prod)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = prod
X      call check (chksum,ntimes*n,n,t2,'s312 ')
X      return
X      end
c%3.1
X      subroutine s313 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     dot product
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, dot
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s313 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      dot = 0.d0
X      do 10 i = 1,n
X         dot = dot + a(i) * b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,dot)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = dot
X      call check (chksum,ntimes*n,n,t2,'s313 ')
X      return
X      end
c%3.1
X      subroutine s314 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     if to max reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s314 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      x = a(1)
X      do 10 i = 2,n
X         if(a(i) .gt. x) x = a(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,x)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = x
X      call check (chksum,ntimes*n,n,t2,'s314 ')
X      return
X      end
c%3.1
X      subroutine s315 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     if to max with index reduction, 1 dimension
c
X      integer ntimes, ld, n, i, nl, index
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s315 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      x     = a(1)
X      index = 1
X      do 10 i = 2,n
X         if(a(i) .gt. x)then
X            x     = a(i)
X            index = i
X         endif
X   10 continue
X      chksum = x+dble(index)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,chksum)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = x + dble(index)
X      call check (chksum,ntimes*n,n,t2,'s315 ')
X      return
X      end
c%3.1
X      subroutine s316 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     if to min reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, x
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s316 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      x = a(1)
X      do 10 i = 2,n
X         if (a(i) .lt. x) x = a(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,x)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = x
X      call check (chksum,ntimes*n,n,t2,'s316 ')
X      return
X      end
c%3.1
X      subroutine s317 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     product reduction, vectorize with
c     1. scalar expansion of factor, and product reduction
c     2. closed form solution: q = factor**n
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, q, factor
X      real t1, t2, second, ctime, dtime
X      parameter(factor=.99999d0)
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s317 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      q = 1.d0
X      do 10 i = 1,n
X         q = factor*q
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,q)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = q
X      call check (chksum,ntimes*n,n,t2,'s317 ')
X      return
X      end
c%3.1
X      subroutine s318 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,inc)
c
c     reductions
c     isamax, max absolute value, increments not equal to 1
c
c
X      integer ntimes, ld, n, i, nl, inc, k, index
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, max
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s318 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      k     = 1
X      index = 1
X      max   = abs(a(1))
X      k     = k + inc
X      do 10 i = 2,n
X         if(abs(a(k)) .le. max) go to 5
X         index = i
X         max   = abs(a(k))
X    5    k     = k + inc
X   10 continue
X      chksum = max + dble(index)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,chksum)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = max + dble(index)
X      call check (chksum,ntimes*(n-1),n,t2,'s318 ')
X      return
X      end
c%3.1
X      subroutine s319 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     coupled reductions
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s319 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1,n
X         a(i) = c(i) + d(i)
X         sum  = sum + a(i)
X         b(i) = c(i) + e(i)
X         sum  = sum + b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,sum)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*n,n,t2,'s319 ')
X      return
X      end
c%3.1
X      subroutine s3110(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     if to max with index reduction, 2 dimensions
c
X      integer ntimes, ld, n, i, nl, j, xindex, yindex
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, max
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s3110')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      max    = aa(1,1)
X      xindex = 1
X      yindex = 1
X      do 10 j = 1,n
X         do 20 i = 1,n
X            if ( aa(i,j) .gt. max ) then
X               max    = aa(i,j)
X               xindex = i
X               yindex = j
X            endif
X  20     continue
X  10  continue
X      chksum = max + dble(xindex) + dble(yindex)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,chksum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = max + dble(xindex) + dble(yindex)
X      call check (chksum,(ntimes/n)*n*n,n,t2,'s3110')
X      return
X      end
c%3.1
X      subroutine s3111(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     conditional sum reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s3111')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1,n
X         if ( a(i) .gt. 0.d0 ) sum = sum + a(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,sum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*n,n,t2,'s3111')
X      return
X      end
c%3.1
X      subroutine s3112(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     sum reduction saving running sums
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s3112')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1,n
X         sum  = sum + a(i)
X         b(i) = sum
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,sum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,b) + sum
X      call check (chksum,ntimes*n,n,t2,'s3112')
X      return
X      end
c%3.1
X      subroutine s3113(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     reductions
c     maximum of absolute value
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, max
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s3113')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      max = abs(a(1))
X      do 10 i = 2,n
X         if(abs(a(i)) .gt. max) max = abs(a(i))
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,max)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = max
X      call check (chksum,ntimes*(n-1),n,t2,'s3113')
X      return
X      end
c%3.2
X      subroutine s321 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     recurrences
c     first order linear recurrence
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s321 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = a(i) + a(i-1) * b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s321 ')
X      return
X      end
c%3.2
X      subroutine s322 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     recurrences
c     second order linear recurrence
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s322 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 3,n
X         a(i) = a(i) + a(i-1) * b(i) + a(i-2) * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-2),n,t2,'s322 ')
X      return
X      end
c%3.2
X      subroutine s323 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     recurrences
c     coupled recurrence
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s323 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = b(i-1) + c(i) * d(i)
X         b(i) = a(i)   + c(i) * e(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s323 ')
X      return
X      end
c%3.3
X      subroutine s331 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     search loops
c     if to last-1
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum
X      real t1, t2, second, ctime, dtime
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s331 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      j  = -1
X      do 10 i = 1,n
X         if(a(i) .lt. 0) j = i
X  10  continue
X      chksum = dble(j)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,chksum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = dble(j)
X      call check (chksum,ntimes*n,n,t2,'s331 ')
X      return
X      end
c%3.3
X      subroutine s332 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,t)
c
c     search loops
c     first value greater than threshold
c
X      integer ntimes, ld, n, i, nl, index
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, t, value
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s332 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      index = -1
X      value = -1.d0
X      do 10 i = 1,n
X         if ( a(i) .gt. t ) then
X            index = i
X            value = a(i)
X            goto 20
X         endif
X   10 continue
X   20 continue
X      chksum = value + dble(index)
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,chksum)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = value + dble(index)
X      call check (chksum,ntimes*n,n,t2,'s332 ')
X      return
X      end
c%3.4
X      subroutine s341 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     packing
c     pack positive values
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s341 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      j = 0
X      do 10 i = 1,n
X         if(b(i) .gt. 0.d0)then
X            j    = j + 1
X            a(j) = b(i)
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s341 ')
X      return
X      end
c%3.4
X      subroutine s342 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     packing
c     unpacking
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s342 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      j = 0
X      do 10 i = 1,n
X         if(a(i) .gt. 0.d0)then
X            j    = j + 1
X            a(i) = b(j)
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s342 ')
X      return
X      end
c%3.4
X      subroutine s343 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     packing
c     pack 2-d array into one dimension
c
X      integer ntimes, ld, n, i, nl, j, k, nn
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, array
X      real t1, t2, second, ctime, dtime
X      parameter(nn=1000)
X      common /cdata/ array(nn*nn)
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s343 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      k = 0
X      do 10 i = 1,n
X         do 20 j= 1,n
X            if (bb(i,j) .gt. 0.d0) then
X               k = k + 1
X               array(k) = aa(i,j)
X            endif
X   20    continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs1d(n*n,array)
X      call check (chksum,(ntimes/n)*n*n,n,t2,'s343 ')
X      return
X      end
c%3.5
X      subroutine s351 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop rerolling
c     unrolled saxpy
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, alpha, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s351 ')
X      t1 = second()
X      alpha = c(1)
X      do 1 nl = 1,5*ntimes
X      do 10 i = 1,n,5
X        a(i)   = a(i)   + alpha * b(i)
X        a(i+1) = a(i+1) + alpha * b(i+1)
X        a(i+2) = a(i+2) + alpha * b(i+2)
X        a(i+3) = a(i+3) + alpha * b(i+3)
X        a(i+4) = a(i+4) + alpha * b(i+4)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(5*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,5*ntimes*(n/5),n,t2,'s351 ')
X      return
X      end
c%3.5
X      subroutine s352 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop rerolling
c     unrolled dot product
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, dot
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s352 ')
X      t1 = second()
X      do 1 nl = 1,5*ntimes
X      dot = 0.d0
X      do 10 i = 1, n, 5
X         dot = dot +   a(i)*b(i)   + a(i+1)*b(i+1) + a(i+2)*b(i+2)
X     +             + a(i+3)*b(i+3) + a(i+4)*b(i+4)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,dot)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(5*ntimes) )
X      chksum = dot
X      call check (chksum,5*ntimes*(n/5),n,t2,'s352 ')
X      return
X      end
c%3.5
X      subroutine s353 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     loop rerolling
c     unrolled sparse saxpy
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, alpha, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s353 ')
X      t1 = second()
X      alpha = c(1)
X      do 1 nl = 1,5*ntimes
X      do 10 i = 1,n,5
X        a(i)   = a(i)   + alpha * b(ip(i))
X        a(i+1) = a(i+1) + alpha * b(ip(i+1))
X        a(i+2) = a(i+2) + alpha * b(ip(i+2))
X        a(i+3) = a(i+3) + alpha * b(ip(i+3))
X        a(i+4) = a(i+4) + alpha * b(ip(i+4))
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(5*ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,5*ntimes*(n/5),n,t2,'s353 ')
X      return
X      end
c
c**********************************************************
c                                                         *
c                 LANGUAGE COMPLETENESS                   *
c                                                         *
c**********************************************************
c%4.1
X      subroutine s411 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop recognition
c     if loop to do loop, zero trip
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s411 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      i = 0
X  10  continue
X      i = i + 1
X      if (i.gt.n) goto 20
X      a(i) = a(i) + b(i) * c(i)
X      goto 10
X  20  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s411 ')
X      return
X      end
c%4.1
X      subroutine s412 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,inc)
c
c     loop recognition
c     if loop with variable increment
c
X      integer ntimes, ld, n, i, nl, inc
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s412 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      i = 0
X  10  continue
X      i = i + inc
X      if(i .gt. n)goto 20
X         a(i) = a(i) + b(i) * c(i)
X      goto 10
X  20  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s412 ')
X      return
X      end
c%4.1
X      subroutine s413 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop recognition
c     if loop to do loop, code on both sides of increment
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s413 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      i = 1
X  10  continue
X      if(i .ge. n)goto 20
X         b(i) = b(i) + d(i) * e(i)
X         i    = i + 1
X         a(i) = c(i) + d(i) * e(i)
X      goto 10
X  20  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a) + cs1d(n,b)
X      call check (chksum,ntimes*(n-1),n,t2,'s413 ')
X      return
X      end
c%4.1
X      subroutine s414 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop recognition
c     if loop to do loop, interchanging with do necessary
c
X      integer ntimes, ld, n, i, nl, j
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs2d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s414 ')
X      t1 = second()
X      do 1 nl = 1,ntimes/n
X      i = 1
X  10  if(i .gt. n) goto 20
X      do 30 j = 2,n
X         aa(i,j) = aa(i,j-1) + bb(i,j-1) * cc(i,j-1)
X   30 continue
X      i = i + 1
X      goto 10
X  20  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes/n) )
X      chksum = cs2d(n,aa) + cs2d(n,bb) + cs2d(n,cc)
X      call check (chksum,(ntimes/n)*n*(n-2),n,t2,'s414 ')
X      return
X      end
c%4.1
X      subroutine s415 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     loop recognition
c     while loop
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s415 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      i = 0
X10    continue
X      i = i + 1
X      if ( a(i) .lt. 0.d0 ) goto 20
X         a(i) = a(i) + b(i) * c(i)
X      goto 10
X20    continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s415 ')
X      return
X      end
c%4.2
X      subroutine s421 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     storage classes and equivalencing
c     equivalence- no overlap
c
X      integer ntimes, ld, n, i, nl, nn
X      parameter(nn=1000)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      double precision x(nn),y(nn)
X      real t1, t2, second, ctime, dtime
X      equivalence (x(1),y(1))
X
X      call set1d(n,x,0.0d0,1)
X      call set1d(n,y,1.0d0,1)
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s421 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         x(i) = y(i+1) + a(i)
X  10  continue
X      call dummy(ld,n,x,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,x)
X      call check (chksum,ntimes*(n-1),n,t2,'s421 ')
X      return
X      end
c%4.2
X      subroutine s422 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     storage classes and equivalencing
c     common and equivalence statement
c     anti-dependence, threshold of 4
c
X      integer ntimes, ld, n, i, nl, nn, vl
X      parameter(nn=1000,vl=64)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision x(nn), array
X      double precision chksum, cs1d
X      equivalence (x(1),array(5))
X      real t1, t2, second, ctime, dtime
X      common /cdata/ array(1000000)
X
X      call set1d(n,x,0.0d0,1)
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s422 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         x(i) = array(i+8) + a(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,x)
X      call check (chksum,ntimes*(n-8),n,t2,'s422 ')
X      return
X      end
c%4.2
X      subroutine s423 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     storage classes and equivalencing
c     common and equivalenced variables - with anti-dependence
c
X      integer ntimes, ld, n, i, nl, nn, vl
X      parameter(nn=1000,vl=64)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision x(nn), array
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X      equivalence (array(vl),x(1))
X      common /cdata/ array(1000000)
X
X      call set1d(n,x,1.0d0,1)
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s423 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n-1
X         array(i+1) = x(i) + a(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,array)
X      call check (chksum,ntimes*(n-1),n,t2,'s423 ')
X      return
X      end
c%4.2
X      subroutine s424 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     storage classes and equivalencing
c     common and equivalenced variables - overlap
c     vectorizeable in strips of 64 or less
c
X      integer ntimes, ld, n, i, nl, nn, vl
X      parameter(nn=1000,vl=64)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision x(nn), array
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X      common /cdata/ array(1000000)
X      equivalence (array(vl),x(1))
X
X      call set1d(n,x,0.0d0,1)
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s424 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n-1
X         x(i+1) = array(i) + a(i)
X   10 continue
X      call dummy(ld,n,x,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,x)
X      call check (chksum,ntimes*(n-1),n,t2,'s424 ')
X      return
X      end
c%4.3
X      subroutine s431 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     parameters
c     parameter statement
c
X      integer ntimes, ld, n, i, nl, k, k1, k2
X      parameter(k1=1, k2=2, k=2*k1-k2)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s431 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i+k) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s431 ')
X      return
X      end
c%4.3
X      subroutine s432 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     parameters
c     data statement
c
X      integer ntimes, ld, n, i, nl, k, k1, k2
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X      data k1,k2 /1,2/
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s432 ')
X      k=2*k1-k2
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i+k) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s432 ')
X      return
X      end
c%4.4
X      subroutine s441 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     non-logical if's
c     arithmetic if
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s441 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         if (d(i)) 20,30,40
X   20    a(i) = a(i) + b(i) * c(i)
X         goto 50
X   30    a(i) = a(i) + b(i) * b(i)
X         goto 50
X   40    a(i) = a(i) + c(i) * c(i)
X   50 continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s441 ')
X      return
X      end
c%4.4
X      subroutine s442 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,indx)
c
c     non-logical if's
c     computed goto
c
X      integer ntimes, ld, n, i, nl, indx(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s442 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         goto (15,20,30,40) indx(i)
X   15    a(i) = a(i) + b(i) * b(i)
X         goto 50
X   20    a(i) = a(i) + c(i) * c(i)
X         goto 50
X   30    a(i) = a(i) + d(i) * d(i)
X         goto 50
X   40    a(i) = a(i) + e(i) * e(i)
X   50 continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s442 ')
X      return
X      end
c%4.4
X      subroutine s443 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     non-logical if's
c     arithmetic if
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s443 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         if (d(i)) 20,20,30
X   20    a(i) = a(i) + b(i) * c(i)
X         goto 50
X   30    a(i) = a(i) + b(i) * b(i)
X   50 continue
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s443 ')
X      return
X      end
c%4.5
X      subroutine s451 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     intrinsic functions
c     intrinsics
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s451 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = sin(b(i)) + cos(c(i))
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s451 ')
X      return
X      end
c%4.5
X      subroutine s452 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     intrinsic functions
c     seq function
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s452 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         a(i) = b(i) + c(i) * dble(i)
X 10   continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X 1    continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s452 ')
X      return
X      end
c%4.5
X      subroutine s453 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     intrinsic functions
c     seq function
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s453 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      s = 0.d0
X      do 10 i = 1, n
X         s    = s + 2.d0
X         a(i) = s * b(i)
X 10   continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X 1    continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s453 ')
X      return
X      end
c%4.7
X      subroutine s471 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,c471s)
c
c     call statements
c
X      integer ntimes, ld, n, i, nl, nn, m
X      parameter(nn=1000)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, x(nn)
X      real t1, t2, second, ctime, dtime, c471s
X
X      m = n
X      call set1d(n,x,0.0d0,1)
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s471 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,m
X         x(i) = b(i) + d(i) * d(i)
X         call s471s
X         b(i) = c(i) + d(i) * e(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) ) -
X     +     ( (n*ntimes) * c471s )
X      chksum = cs1d(n,x) + cs1d(n,b)
X      call check (chksum,ntimes*n,n,t2,'s471 ')
X      return
X      end
c%4.8
X      subroutine s481 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     non-local goto's
c     stop statement
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s481 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X         if (d(i) .lt. 0.d0) stop 'stop 1'
X         a(i) = a(i) + b(i) * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s481 ')
X      return
X      end
c%4.8
X      subroutine s482 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     non-local goto's
c     other loop exit with code before exit
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s482 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + b(i) * c(i)
X         if(c(i) .gt. b(i))goto 20
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s482 ')
X  20  continue
X      return
X      end
c%4.9
X      subroutine s491(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     vector semantics
c     indirect addressing on lhs, store in sequence
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s491 ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(ip(i)) = b(i) + c(i) * d(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s491 ')
X      return
X      end
c%4.11
X      subroutine s4112(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,s)
c
c     indirect addressing
c     sparse saxpy
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4112')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1, n
X          a(i) = a(i) + b(ip(i)) * s
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s4112')
X      return
X      end
c%4.11
X      subroutine s4113(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     indirect addressing
c     indirect addressing on rhs and lhs
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4113')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(ip(i)) = b(ip(i)) + c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s4113')
X      return
X      end
c%4.11
X      subroutine s4114(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,n1)
c
c     indirect addressing
c     mix indirect addressing with variable lower and upper bounds
c
X      integer ntimes, ld, n, i, nl, k, n1, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4114')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i=n1, n
X         k = ip(i)
X         a(i) = b(i) + c(n-k+1) * d(i)
X         k = k + 5
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s4114')
X      return
X      end
c%4.11
X      subroutine s4115(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     indirect addressing
c     sparse dot product
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4115')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1, n
X         sum = sum + a(i) * b(ip(i))
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*n,n,t2,'s4115')
X      return
X      end
c%4.11
X      subroutine s4116(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip,
X     +                 j,inc)
c
c     indirect addressing
c     more complicated sparse sdot
c
X      integer ntimes, ld, n, i, nl, j, off, inc, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4116')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1, n-1
X         off = inc + i
X         sum = sum + a(off) * aa(ip(i),j)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*(n-1),n,t2,'s4116')
X      return
X      end
c%4.11
X      subroutine s4117(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     indirect addressing
c     seq function
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4117')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 2,n
X         a(i) = b(i) + c(i/2) * d(i)
X 10   continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X 1    continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*(n-1),n,t2,'s4117')
X      return
X      end
c%4.12
X      subroutine s4121 (ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     statement functions
c     elementwise multiplication
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, f, x, y
X      real t1, t2, second, ctime, dtime
X      f(x,y) = x*y
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'s4121')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + f(b(i),c(i))
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'s4121')
X      return
X      end
c%5.1
X      subroutine va(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector assignment
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'va   ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'va   ')
X      return
X      end
c%5.1
X      subroutine vag(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     control loops
c     vector assignment, gather
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vag  ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = b(ip(i))
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vag  ')
X      return
X      end
c%5.1
X      subroutine vas(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,ip)
c
c     control loops
c     vector assignment, scatter
c
X      integer ntimes, ld, n, i, nl, ip(n)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vas  ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(ip(i)) = b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vas  ')
X      return
X      end
c%5.1
X      subroutine vif(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector if
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vif  ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         if (b(i) .gt. 0.d0) then
X            a(i) = b(i)
X         endif
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vif  ')
X      return
X      end
X
c%5.1
X      subroutine vpv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector plus vector
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vpv  ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vpv  ')
X      return
X      end
c%5.1
X      subroutine vtv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector times vector
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vtv  ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) * b(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vtv  ')
X      return
X      end
c%5.1
X      subroutine vpvtv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector plus vector times vector
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vpvtv')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + b(i) * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vpvtv')
X      return
X      end
c%5.1
X      subroutine vpvts(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc,s)
c
c     control loops
c     vector plus vector times scalar
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d, s
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vpvts')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + b(i) * s
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vpvts')
X      return
X      end
c%5.1
X      subroutine vpvpv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector plus vector plus vector
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vpvpv')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) + b(i) + c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vpvpv')
X      return
X      end
c%5.1
X      subroutine vtvtv(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector times vector times vector
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vtvtv')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a(i) = a(i) * b(i) * c(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,a)
X      call check (chksum,ntimes*n,n,t2,'vtvtv')
X      return
X      end
c%5.1
X      subroutine vsumr(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector sum reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, sum
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vsumr')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      sum = 0.d0
X      do 10 i = 1,n
X         sum = sum + a(i)
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,sum)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = sum
X      call check (chksum,ntimes*n,n,t2,'vsumr')
X      return
X      end
c%5.1
X      subroutine vdotr(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     vector dot product reduction
c
X      integer ntimes, ld, n, i, nl
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, dot
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vdotr')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      dot = 0.d0
X      do 10 i = 1,n
X         dot = dot + a(i) * b(i)
X   10 continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,dot)
X   1  continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = dot
X      call check (chksum,ntimes*n,n,t2,'vdotr')
X      return
X      end
c%5.1
X      subroutine vbor(ntimes,ld,n,ctime,dtime,a,b,c,d,e,aa,bb,cc)
c
c     control loops
c     basic operations rates, isolate arithmetic from memory traffic
c     all combinations of three, 59 flops for 6 loads and 1 store.
c
X      integer ntimes, ld, n, i, nl, nn
X      parameter(nn=1000)
X      double precision a(n), b(n), c(n), d(n), e(n), aa(ld,n),
X     +                 bb(ld,n), cc(ld,n)
X      double precision chksum, cs1d
X      double precision a1, b1, c1, d1, e1, f1, s(nn)
X      real t1, t2, second, ctime, dtime
X
X      call init(ld,n,a,b,c,d,e,aa,bb,cc,'vbor ')
X      t1 = second()
X      do 1 nl = 1,ntimes
X      do 10 i = 1,n
X         a1 = a(i)
X         b1 = b(i)
X         c1 = c(i)
X         d1 = d(i)
X         e1 = e(i)
X         f1 = aa(i,1)
X         a1   = a1*b1*c1 + a1*b1*d1 + a1*b1*e1 + a1*b1*f1
X     +                   + a1*c1*d1 + a1*c1*e1 + a1*c1*f1
X     +                              + a1*d1*e1 + a1*d1*f1
X     +                                         + a1*e1*f1
X         b1   = b1*c1*d1 + b1*c1*e1 + b1*c1*f1
X     +                   + b1*d1*e1 + b1*d1*f1
X     +                              + b1*e1*f1
X         c1   = c1*d1*e1 + c1*d1*f1
X     +                   + c1*e1*f1
X         d1   = d1*e1*f1
X         s(i) = a1 * b1 * c1 * d1
X  10  continue
X      call dummy(ld,n,a,b,c,d,e,aa,bb,cc,1.d0)
X  1   continue
X      t2 = second() - t1 - ctime - ( dtime * float(ntimes) )
X      chksum = cs1d(n,s)
X      call check (chksum,ntimes*n,n,t2,'vbor ')
X      return
X      end
END_OF_FILE
if test 122064 -ne `wc -c <'loopd.f'`; then
    echo shar: \"'loopd.f'\" unpacked with wrong size!
fi
# end of 'loopd.f'
fi
echo shar: End of shell archive.
exit 0
