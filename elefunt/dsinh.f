C     PROGRAM TO TEST DSINH/DCOSH
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
C                 BE DELETED PROVIDED THE FOLLOWING SIX
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
C                 EPS    - THE SMALLEST POSITIVE FLOATING-POINT
C                          NUMBER SUCH THAT 1.0+EPS .NE. 1.0
C                 XMAX   - THE LARGEST FINITE FLOATING-POINT NO.
C
C        REN(K) - A FUNCTION SUBPROGRAM RETURNING RANDOM REAL
C                 NUMBERS UNIFORMLY DISTRIBUTED OVER (0,1)
C
C
C     STANDARD FORTRAN SUBPROGRAMS REQUIRED
C
C         DABS, DLOG, DMAX1, DCOSH, DFLOAT, IDINT, DSINH, DSQRT
C
C
C     LATEST REVISION - DECEMBER 6, 1979
C
C     AUTHOR - W. J. CODY
C              ARGONNE NATIONAL LABORATORY
C
C
      INTEGER I,IBETA,IEXP,II,IOUT,IRND,IT,I1,I2,J,K1,K2,K3,
     1        MACHEP,MAXEXP,MINEXP,N,NEGEP,NGRD,NIT
      REAL*8 A,AIND,AIT,ALBETA,ALXMAX,B,BETA,BETAP,C,C0,DEL,DEN,EPS,
     1     EPSNEG,FIVE,ONE,REN,R6,R7,THREE,W,X,XL,XMAX,XMIN,XN,X1,
     2     XSQ,Y,Z,ZERO,ZZ
C
      IOUT = 6
      CALL MACHAR(IBETA,IT,IRND,NGRD,MACHEP,NEGEP,IEXP,MINEXP,
     1            MAXEXP,EPS,EPSNEG,XMIN,XMAX)
      BETA = DFLOAT(IBETA)
      ALBETA = DLOG(BETA)
      ALXMAX = DLOG(XMAX) - 0.5D0
      AIT = DFLOAT(IT)
      ZERO = 0.0D0
      ONE = 1.0D0
      THREE = 3.0D0
      FIVE = 5.0D0
      C0 = FIVE/16.0D0 + 1.152713683194269979D-2
      A = ZERO
      B = 0.5D0
      C = (AIT + ONE) * 0.35D0
      IF (IBETA .EQ. 10) C = C * THREE
      N = 2000
      XN = DFLOAT(N)
      I1 = 0
      I2 = 2
      NIT = 2 - (IDINT(DLOG(EPS)*THREE))/20
      AIND = DFLOAT(NIT+NIT+1)
C-----------------------------------------------------------------
C     RANDOM ARGUMENT ACCURACY TESTS
C-----------------------------------------------------------------
      DO 300 J = 1, 4
         IF (J .NE. 2) GO TO 30
         AIND = AIND - ONE
         I2 = 1
   30    K1 = 0
         K3 = 0
         X1 = ZERO
         R6 = ZERO
         R7 = ZERO
         DEL = (B - A) / XN
         XL = A
C
         DO 200 I = 1, N
            X = DEL * REN(I1) + XL
            IF (J .GT. 2) GO TO 80
            XSQ = X * X
            ZZ = ONE
            DEN = AIND
C
            DO 40 II = I2, NIT
               W = ZZ * XSQ/(DEN*(DEN-ONE))
               ZZ = W + ONE
               DEN = DEN - 2.0D0
   40       CONTINUE
C
            IF (J .EQ. 2) GO TO 50
            W = X*XSQ*ZZ/6.0D0
            ZZ = X + W
            Z = DSINH(X)
            IF (IRND .NE. 0) GO TO 110
            W = (X - ZZ) + W
            ZZ = ZZ + (W + W)
            GO TO 110
   50       Z = DCOSH(X)
            IF (IRND .NE. 0) GO TO 110
            W = (ONE - ZZ) + W
            ZZ = ZZ + (W + W)
            GO TO 110
   80       Y = X
            X = Y - ONE
            W = X - ONE
            IF (J .EQ. 4) GO TO 100
            Z = DSINH(X)
            ZZ = (DSINH(Y) + DSINH(W)) * C0
            GO TO 110
  100       Z = DCOSH(X)
            ZZ = (DCOSH(Y) + DCOSH(W)) * C0
  110       W = ONE
            IF (Z .NE. ZERO) W = (Z - ZZ)/Z
            IF (W .GT. ZERO) K1 = K1 + 1
            IF (W .LT. ZERO) K3 = K3 + 1
            W = DABS(W)
            IF (W .LE. R6) GO TO 120
            R6 = W
            X1 = X
  120       R7 = R7 + W * W
            XL = XL + DEL
  200    CONTINUE
C
         K2 = N - K3 - K1
         R7 = DSQRT(R7/XN)
         I = (J/2) * 2
         IF (J .EQ. 1) WRITE (IOUT,1000)
         IF (J .EQ. 2) WRITE (IOUT,1005)
         IF (J .EQ. 3) WRITE (IOUT,1001)
         IF (J .EQ. 4) WRITE (IOUT,1006)
         WRITE (IOUT,1010) N,A,B
         IF (I .NE. J) WRITE (IOUT,1011) K1,K2,K3
         IF (I .EQ. J) WRITE (IOUT,1012) K1,K2,K3
         WRITE (IOUT,1020) IT,IBETA
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
         IF (J .NE. 2) GO TO 300
         B = ALXMAX
         A = THREE
  300 CONTINUE
C-----------------------------------------------------------------
C     SPECIAL TESTS
C-----------------------------------------------------------------
      WRITE (IOUT,1025)
      WRITE (IOUT,1030)
C
      DO 320 I = 1, 5
         X = REN(I1) * A
         Z = DSINH(X) + DSINH(-X)
         WRITE (IOUT,1060) X, Z
  320 CONTINUE
C
      WRITE (IOUT,1031)
      BETAP = BETA ** IT
      X = REN(I1) / BETAP
C
      DO 330 I = 1, 5
         Z = X - DSINH(X)
         WRITE (IOUT,1060) X, Z
         X = X / BETA
  330 CONTINUE
C
      WRITE (IOUT,1032)
C
      DO 340 I = 1, 5
         X = REN(I1) * A
         Z = DCOSH(X) - DCOSH(-X)
         WRITE (IOUT,1060) X, Z
  340 CONTINUE
C
      WRITE (IOUT,1035)
      X = BETA ** (DFLOAT(MINEXP)*0.75D0)
      Y = DSINH(X)
      WRITE (IOUT,1061) X, Y
C-----------------------------------------------------------------
C     TEST OF ERROR RETURNS
C-----------------------------------------------------------------
      WRITE (IOUT,1050)
      X = ALXMAX + 0.125D0
      WRITE (IOUT,1051) X
      Y = DSINH(X)
      WRITE (IOUT,1055) Y
      X = BETAP
      WRITE (IOUT,1052) X
      Y = DSINH(X)
      WRITE (IOUT,1055) Y
      WRITE (IOUT,1100)
      STOP
 1000 FORMAT(47H1TEST OF DSINH(X) VS T.S. EXPANSION OF DSINH(X) //)
 1001 FORMAT(46H1TEST OF DSINH(X) VS C*(DSINH(X+1)+DSINH(X-1))   //)
 1005 FORMAT(47H1TEST OF DCOSH(X) VS T.S. EXPANSION OF DCOSH(X) //)
 1006 FORMAT(46H1TEST OF DCOSH(X) VS C*(DCOSH(X+1)+DCOSH(X-1))   //)
 1010 FORMAT(I7,47H RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL /
     1 6X,1H(,E15.4,1H,,E15.4,1H)//)
 1011 FORMAT(20H DSINH(X) WAS LARGER,I6,7H TIMES, /
     1     12X,7H AGREED,I6,11H TIMES, AND /
     1   8X,11HWAS SMALLER,I6,7H TIMES.//)
 1012 FORMAT(20H DCOSH(X) WAS LARGER,I6,7H TIMES, /
     1     12X,7H AGREED,I6,11H TIMES, AND /
     1   8X,11HWAS SMALLER,I6,7H TIMES.//)
 1020 FORMAT(10H THERE ARE,I4,5H BASE,I4,
     1    46H SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER  //)
 1021 FORMAT(30H THE MAXIMUM RELATIVE ERROR OF,E15.4,3H = ,I4,3H **,
     1  F7.2/4X,16HOCCURRED FOR X =,E17.6)
 1022 FORMAT(27H THE ESTIMATED LOSS OF BASE,I4,
     1  22H SIGNIFICANT DIGITS IS,F7.2//)
 1023 FORMAT(40H THE ROOT MEAN SQUARE RELATIVE ERROR WAS,E15.4,
     1    3H = ,I4,3H **,F7.2)
 1025 FORMAT(14H1SPECIAL TESTS//)
 1030 FORMAT(53H THE IDENTITY  DSINH(-X) = -DSINH(X)  WILL BE TESTED.//
     1      8X,1HX,9X,12HF(X) + F(-X)/)
 1031 FORMAT(53H THE IDENTITY DSINH(X) = X , X SMALL, WILL BE TESTED.//
     1       8X,1HX,9X,8HX - F(X)/)
 1032 FORMAT(52H THE IDENTITY  DCOSH(-X) = DCOSH(X)  WILL BE TESTED.//
     1      8X,1HX,9X,12HF(X) - F(-X)/)
 1035 FORMAT(43H TEST OF UNDERFLOW FOR VERY SMALL ARGUMENT. /)
 1050 FORMAT(22H1TEST OF ERROR RETURNS//)
 1051 FORMAT(39H DSINH WILL BE CALLED WITH THE ARGUMENT,E15.4/
     1       41H THIS SHOULD NOT TRIGGER AN ERROR MESSAGE//)
 1052 FORMAT(39H0DSINH WILL BE CALLED WITH THE ARGUMENT,E15.4/
     1       37H THIS SHOULD TRIGGER AN ERROR MESSAGE//)
 1055 FORMAT(25H DSINH RETURNED THE VALUE,E15.4///)
 1060 FORMAT(2E15.7/)
 1061 FORMAT(6X,7H DSINH(,E13.6,3H) =,E13.6/)
 1100 FORMAT(25H THIS CONCLUDES THE TESTS )
C     ---------- LAST CARD OF DSINH/DCOSH TEST PROGRAM ----------
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
