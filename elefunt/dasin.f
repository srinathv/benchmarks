C     PROGRAM TO TEST DASIN/DACOS
C
C     DATA REQUIRED
C
C        NONE
C
C     SUBPROGRAMS REQUIRED FROM THIS PACKAGE
C
C        MACHAR - AN ENVIRONMENTAL INQUIRY PROGRAM PROVIDING
C                 INFORMATION ON THE FLOATING-POINT ARITHMETIC
C                 SYSTEM.  NOTE THAT THE CALL TO MACHAR CAN
C                 BE DELETED PROVIDED THE FOLLOWING FOUR
C                 PARAMETERS ARE ASSIGNED THE VALUES INDICATED
C
C                 IBETA  - THE RADIX OF THE FLOATING-POINT SYSTEM
C                 IT     - THE NUMBER OF BASE-IBETA DIGITS IN THE
C                          SIGNIFICAND OF A FLOATING-POINT NUMBER
C                 IRND   - 0 IF FLOATING-POINT ADDITION CHOPS,
C                          1 IF FLOATING-POINT ADDITION ROUNDS
C                 MINEXP - THE LARGEST IN MAGNITUDE NEGATIVE
C                          INTEGER SUCH THAT DFLOAT(IBETA)**MINEXP
C                          IS A POSITIVE FLOATING-POINT NUMBER
C
C        REN(K) - A FUNCTION SUBPROGRAM RETURNING RANDOM REAL
C                 NUMBERS UNIFORMLY DISTRIBUTED OVER (0,1)
C
C
C     STANDARD FORTRAN SUBPROGRAMS REQUIRED
C
C         DABS, DACOS, DLOG, DLOG10, DMAX1, DASIN, DFLOAT, IDINT, DSQRT
C
C
C     LATEST REVISION - DECEMBER 6, 1979
C
C     AUTHOR - W. J. CODY
C              ARGONNE NATIONAL LABORATORY
C
C
      INTEGER I,IBETA,IEXP,IOUT,IRND,IT,I1,J,K,K1,K2,K3,L,M,
     1        MACHEP,MAXEXP,MINEXP,N,NEGEP,NGRD
      REAL*8 A,AIT,ALBETA,B,BETA,BETAP,C1,C2,DEL,EPS,EPSNEG,HALF,REN,
     1     R6,R7,S,SUM,W,X,XL,XM,XMAX,XMIN,XN,X1,Y,YSQ,Z,ZERO,ZZ
C
      IOUT = 6
      CALL MACHAR(IBETA,IT,IRND,NGRD,MACHEP,NEGEP,IEXP,MINEXP,
     1            MAXEXP,EPS,EPSNEG,XMIN,XMAX)
      BETA = DFLOAT(IBETA)
      ALBETA = DLOG(BETA)
      ZERO = 0.0D0
      HALF = 0.5D0
      AIT = DFLOAT(IT)
      K = IDINT(DLOG10(BETA**IT)) + 1
      IF (IBETA .NE. 10) GO TO 20
      C1 = 1.57D0
      C2 = 7.9632679489661923132D-4
      GO TO 30
   20 C1 = 201.0D0/128.0D0
      C2 = 4.8382679489661923132D-4
   30 A = -0.125D0
      B = -A
      N = 2000
      XN = DFLOAT(N)
      I1 = 0
      L = -1
C-----------------------------------------------------------------
C     RANDOM ARGUMENT ACCURACY TESTS
C-----------------------------------------------------------------
      DO 300 J = 1, 5
         K1 = 0
         K3 = 0
         L = -L
         X1 = ZERO
         R6 = ZERO
         R7 = ZERO
         DEL = (B - A) / XN
         XL = A
C
         DO 200 I = 1, N
            X = DEL*REN(I1) + XL
            IF (J .LE. 2) GO TO 40
            YSQ = HALF - HALF*DABS(X)
            X = (HALF - (YSQ+YSQ)) + HALF
            IF (J .EQ. 5) X = -X
            Y = DSQRT(YSQ)
            Y = Y + Y
            GO TO 50
   40       Y = X
            YSQ = Y*Y
   50       SUM = ZERO
            XM = DFLOAT(K+K+1)
            IF (L .GT. 0) Z = DASIN(X)
            IF (L .LT. 0) Z = DACOS(X)
C
            DO 60 M = 1, K
               SUM = YSQ*(SUM + 1.0D0/XM)
               XM = XM - 2.0D0
               SUM = SUM*(XM/(XM+1.0D0))
   60       CONTINUE
C
            SUM = SUM*Y
            IF ((J .NE. 1) .AND. (J .NE. 4)) GO TO 70
            ZZ = Y + SUM
            SUM = (Y - ZZ) + SUM
            IF (IRND .NE. 1) ZZ = ZZ + (SUM+SUM)
            GO TO 110
   70       S = C1 + C2
            SUM = ((C1 - S) + C2) - SUM
            ZZ = S + SUM
            SUM = ((S - ZZ) + SUM) - Y
            S = ZZ
            ZZ = S + SUM
            SUM = (S - ZZ) + SUM
            IF (IRND .NE. 1) ZZ = ZZ + (SUM+SUM)
  110       W = 1.0D0
            IF (Z .NE. ZERO) W = (Z-ZZ)/Z
            IF (W .GT. ZERO) K1 = K1 + 1
            IF (W .LT. ZERO) K3 = K3 + 1
            W = DABS(W)
            IF (W .LE. R6) GO TO 120
            R6 = W
            X1 = X
  120       R7 = R7 + W*W
            XL = XL + DEL
  200    CONTINUE
C
         K2 = N - K3 - K1
         R7 = DSQRT(R7/XN)
         IF (L .LT. 0) GO TO 210
         WRITE (IOUT,1000)
         WRITE (IOUT,1010) N,A,B
         WRITE (IOUT,1011) K1,K2,K3
         GO TO 220
  210    WRITE (IOUT,1005)
         WRITE (IOUT,1010) N,A,B
         WRITE (IOUT,1012) K1,K2,K3
  220    WRITE (IOUT,1020) IT,IBETA
         W = -999.0D0
         IF (R6 .NE. ZERO) W = DLOG(DABS(R6))/ALBETA
         WRITE (IOUT,1021) R6,IBETA,W,X1
         W = DMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
         W = -999.0D0
         IF (R7 .NE. ZERO) W = DLOG(DABS(R7))/ALBETA
         WRITE (IOUT,1023) R7,IBETA,W
         W = DMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
         IF (J .NE. 2) GO TO 250
         A = 0.75D0
         B = 1.0D0
  250    IF (J .NE. 4) GO TO 300
         B = -A
         A = -1.0D0
         C1 = C1 + C1
         C2 = C2 + C2
         L = -L
  300 CONTINUE
C-----------------------------------------------------------------
C     SPECIAL TESTS
C-----------------------------------------------------------------
      WRITE (IOUT,1025)
      WRITE (IOUT,1030)
C
      DO 320 I = 1, 5
         X = REN(I1)*A
         Z = DASIN(X) + DASIN(-X)
         WRITE (IOUT,1060) X, Z
  320 CONTINUE
C
      WRITE (IOUT,1031)
      BETAP = BETA ** IT
      X = REN(I1) / BETAP
C
      DO 330 I = 1, 5
         Z = X - DASIN(X)
         WRITE (IOUT,1060) X, Z
         X = X / BETA
  330 CONTINUE
C
      WRITE (IOUT,1035)
      X = BETA ** (DFLOAT(MINEXP)*0.75D0)
      Y = DASIN(X)
      WRITE (IOUT,1061) X, Y
C-----------------------------------------------------------------
C     TEST OF ERROR RETURNS
C-----------------------------------------------------------------
      WRITE (IOUT,1050)
      X = 1.2D0
      WRITE (IOUT,1052) X
      Y = DASIN(X)
      WRITE (IOUT,1055) Y
      WRITE (IOUT,1100)
      STOP
 1000 FORMAT(34H1TEST OF DASIN(X) VS TAYLOR SERIES //)
 1005 FORMAT(34H1TEST OF DACOS(X) VS TAYLOR SERIES //)
 1010 FORMAT(I7,47H RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL /
     1 6X,1H(,E15.4,1H,,E15.4,1H)//)
 1011 FORMAT(20H DASIN(X) WAS LARGER,I6,7H TIMES, /
     1     12X,7H AGREED,I6,11H TIMES, AND /
     2   8X,11HWAS SMALLER,I6,7H TIMES.//)
 1012 FORMAT(20H DACOS(X) WAS LARGER,I6,7H TIMES, /
     1     12X,7H AGREED,I6,11H TIMES, AND /
     2   8X,11HWAS SMALLER,I6,7H TIMES.//)
 1020 FORMAT(10H THERE ARE,I4,5H BASE,I4,
     1    46H SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER  //)
 1021 FORMAT(30H THE MAXIMUM RELATIVE ERROR OF,E15.4,3H = ,I4,3H **,
     1  F7.2/4X,16HOCCURRED FOR X =,E17.6)
 1022 FORMAT(27H THE ESTIMATED LOSS OF BASE,I4,
     1  22H SIGNIFICANT DIGITS IS,F7.2//)
 1023 FORMAT(40H THE ROOT MEAN SQUARE RELATIVE ERROR WAS,E15.4,
     1    3H = ,I4,3H **,F7.2)
 1025 FORMAT(14H1SPECIAL TESTS//)
 1030 FORMAT(53H THE IDENTITY  DASIN(-X) = -DASIN(X)  WILL BE TESTED.//
     1      8X,1HX,9X,12HF(X) + F(-X)/)
 1031 FORMAT(53H THE IDENTITY DASIN(X) = X , X SMALL, WILL BE TESTED.//
     1       8X,1HX,9X,8HX - F(X)/)
 1035 FORMAT(43H TEST OF UNDERFLOW FOR VERY SMALL ARGUMENT. /)
 1050 FORMAT(22H1TEST OF ERROR RETURNS//)
 1052 FORMAT(39H DASIN WILL BE CALLED WITH THE ARGUMENT,E15.4/
     1       37H THIS SHOULD TRIGGER AN ERROR MESSAGE//)
 1055 FORMAT(25H DASIN RETURNED THE VALUE,E15.4///)
 1060 FORMAT(2E15.7/)
 1061 FORMAT(6X,7H DASIN(,E13.6,3H) =,E13.6/)
 1100 FORMAT(25H THIS CONCLUDES THE TESTS )
C     ---------- LAST CARD OF DASIN/DACOS TEST PROGRAM ----------
      END
      DOUBLE PRECISION FUNCTION REN(K)
C
C     RANDOM NUMBER GENERATOR - BASED ON ALGORITHM 266 BY PIKE AND
C      HILL (MODIFIED BY HANSSON), COMMUNICATIONS OF THE ACM,
C      VOL. 8, NO. 10, OCTOBER 1965.
C
C     THIS SUBPROGRAM IS INTENDED FOR USE ON COMPUTERS WITH
C      FIXED POINT WORDLENGTH OF AT LEAST 29 BITS.  IT IS
C      BEST IF THE FLOATING POINT SIGNIFICAND HAS AT MOST
C      29 BITS.
C
      INTEGER IY,J,K
      DATA IY/100001/
C
      J = K
      IY = IY * 125
      IY = IY - (IY/2796203) * 2796203
      REN = DFLOAT(IY) / 2796203.0D0 * (1.0D0 + 1.0D-6 + 1.0D-12)
      RETURN
C     ---------- LAST CARD OF REN ----------
      END
