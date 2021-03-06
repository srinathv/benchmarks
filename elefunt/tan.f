C     PROGRAM TO TEST TAN/COTAN
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
C                 BE DELETED PROVIDED THE FOLLOWING THREE
C                 PARAMETERS ARE ASSIGNED THE VALUES INDICATED
C
C                 IBETA  - THE RADIX OF THE FLOATING-POINT SYSTEM
C                 IT     - THE NUMBER OF BASE-IBETA DIGITS IN THE
C                          SIGNIFICAND OF A FLOATING-POINT NUMBER
C                 MINEXP - THE LARGEST IN MAGNITUDE NEGATIVE
C                          INTEGER SUCH THAT FLOAT(IBETA)**MINEXP
C                          IS A POSITIVE FLOATING-POINT NUMBER
C
C        REN(K) - A FUNCTION SUBPROGRAM RETURNING RANDOM REAL
C                 NUMBERS UNIFORMLY DISTRIBUTED OVER (0,1)
C
C
C     STANDARD FORTRAN SUBPROGRAMS REQUIRED
C
C         ABS, ALOG, AMAX1, COTAN, FLOAT, TAN, SQRT
C
C
C     LATEST REVISION - DECEMBER 6, 1979
C
C     AUTHOR - W. J. CODY
C              ARGONNE NATIONAL LABORATORY
C
C
      INTEGER I,IBETA,IEXP,IOUT,IRND,IT,I1,J,K1,K2,K3,MACHEP,
     1        MAXEXP,MINEXP,N,NEGEP,NGRD
      REAL A,AIT,ALBETA,B,BETA,BETAP,C1,C2,DEL,EPS,EPSNEG,HALF,
     1     PI,RAN,R6,R7,W,X,XL,XMAX,XMIN,XN,X1,Y,Z,ZERO,ZZ
C
      IOUT = 6
      CALL MACHAR(IBETA,IT,IRND,NGRD,MACHEP,NEGEP,IEXP,MINEXP,
     1            MAXEXP,EPS,EPSNEG,XMIN,XMAX)
      BETA = FLOAT(IBETA)
      ALBETA = ALOG(BETA)
      ZERO = 0.0E0
      HALF = 0.5E0
      AIT = FLOAT(IT)
      PI = 3.14159265E0
      A = ZERO
      B = PI * 0.25E0
      N = 2000
      XN = FLOAT(N)
      I1 = 0
C-----------------------------------------------------------------
C     RANDOM ARGUMENT ACCURACY TESTS
C-----------------------------------------------------------------
      DO 300 J = 1, 4
         K1 = 0
         K3 = 0
         X1 = ZERO
         R6 = ZERO
         R7 = ZERO
         DEL = (B - A) / XN
         XL = A
C
         DO 200 I = 1, N
            X = DEL * REN(I1) + XL
            Y = X * HALF
            X = Y + Y
            IF (J .EQ. 4) GO TO 80
            Z = TAN(X)
            ZZ = TAN(Y)
            W = 1.0E0
            IF (Z .EQ. ZERO) GO TO 110
            W = ((HALF-ZZ)+HALF)*((HALF+ZZ)+HALF)
            W = (Z - (ZZ+ZZ)/W) / Z
            GO TO 110
   80       Z = COTAN(X)
            ZZ = COTAN(Y)
            W = 1.0E0
            IF (Z .EQ. ZERO) GO TO 110
            W = ((HALF-ZZ)+HALF)*((HALF+ZZ)+HALF)
            W = (Z+W/(ZZ+ZZ))/Z
  110       IF (W .GT. ZERO) K1 = K1 + 1
            IF (W .LT. ZERO) K3 = K3 + 1
            W = ABS(W)
            IF (W .LE. R6) GO TO 120
            R6 = W
            X1 = X
  120       R7 = R7 + W * W
            XL = XL + DEL
  200    CONTINUE
C
         K2 = N - K3 - K1
         R7 = SQRT(R7/XN)
         IF (J .NE. 4) WRITE (IOUT,1000)
         IF (J .EQ. 4) WRITE (IOUT,1005)
         WRITE (IOUT,1010) N,A,B
         IF (J .NE. 4) WRITE (IOUT,1011) K1,K2,K3
         IF (J .EQ. 4) WRITE (IOUT,1012) K1,K2,K3
         WRITE (IOUT,1020) IT,IBETA
         W = -999.0E0
         IF (R6 .NE. ZERO) W = ALOG(ABS(R6))/ALBETA
         WRITE (IOUT,1021) R6,IBETA,W,X1
         W = AMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
         W = -999.0E0
         IF (R7 .NE. ZERO) W = ALOG(ABS(R7))/ALBETA
         WRITE (IOUT,1023) R7,IBETA,W
         W = AMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
      IF (J .NE. 1) GO TO 250
         A = PI * 0.875E0
         B = PI * 1.125E0
         GO TO 300
  250    A = PI * 6.0E0
         B = A + PI * 0.25E0
  300 CONTINUE
C-----------------------------------------------------------------
C     SPECIAL TESTS
C-----------------------------------------------------------------
      WRITE (IOUT,1025)
      WRITE (IOUT,1030)
C
      DO 320 I = 1, 5
         X = REN(I1) * A
         Z = TAN(X) + TAN(-X)
         WRITE (IOUT,1060) X, Z
  320 CONTINUE
C
      WRITE (IOUT,1031)
      BETAP = BETA ** IT
      X = REN(I1) / BETAP
C
      DO 330 I = 1, 5
         Z = X - TAN(X)
         WRITE (IOUT,1060) X, Z
         X = X / BETA
  330 CONTINUE
C
      WRITE (IOUT,1035)
      X = BETA ** (FLOAT(MINEXP)*0.75E0)
      Y = TAN(X)
      WRITE (IOUT,1061) X, Y
      C1 = -225.0E0
      C2 = -.950846454195142026E0
      X = 11.0E0
      Y = TAN(X)
      W = ((C1-Y)+C2)/(C1+C2)
      Z = ALOG(ABS(W))/ALBETA
      WRITE (IOUT,1040) W, IBETA, Z
      WRITE (IOUT,1061) X, Y
      W = AMAX1(AIT+Z,ZERO)
      WRITE (IOUT,1022) IBETA, W
C-----------------------------------------------------------------
C     TEST OF ERROR RETURNS
C-----------------------------------------------------------------
      WRITE (IOUT,1050)
      X = BETA ** (IT/2)
      WRITE (IOUT,1051) X
      Y = TAN(X)
      WRITE (IOUT,1055) Y
      X = BETAP
      WRITE (IOUT,1052) X
      Y = TAN(X)
      WRITE (IOUT,1055) Y
      WRITE (IOUT,1100)
      STOP
 1000 FORMAT(45H1TEST OF TAN(X) VS 2*TAN(X/2)/(1-TAN(X/2)**2) //)
 1005 FORMAT(47H1TEST OF COT(X) VS (COT(X/2)**2-1)/(2*COT(X/2)) //)
 1010 FORMAT(I7,47H RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL /
     1 6X,1H(,E15.4,1H,,E15.4,1H)//)
 1011 FORMAT(18H TAN(X) WAS LARGER,I6,7H TIMES, /
     1     11X,7H AGREED,I6,11H TIMES, AND /
     1   7X,11HWAS SMALLER,I6,7H TIMES.//)
 1012 FORMAT(18H COT(X) WAS LARGER,I6,7H TIMES, /
     1     11X,7H AGREED,I6,11H TIMES, AND /
     1   7X,11HWAS SMALLER,I6,7H TIMES.//)
 1020 FORMAT(10H THERE ARE,I4,5H BASE,I4,
     1    46H SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER  //)
 1021 FORMAT(30H THE MAXIMUM RELATIVE ERROR OF,E15.4,3H = ,I4,3H **,
     1  F7.2/4X,16HOCCURRED FOR X =,E17.6)
 1022 FORMAT(27H THE ESTIMATED LOSS OF BASE,I4,
     1  22H SIGNIFICANT DIGITS IS,F7.2//)
 1023 FORMAT(40H THE ROOT MEAN SQUARE RELATIVE ERROR WAS,E15.4,
     1    3H = ,I4,3H **,F7.2)
 1025 FORMAT(14H1SPECIAL TESTS//)
 1030 FORMAT(49H THE IDENTITY  TAN(-X) = -TAN(X)  WILL BE TESTED.//
     1      8X,1HX,9X,12HF(X) + F(-X)/)
 1031 FORMAT(51H THE IDENTITY TAN(X) = X , X SMALL, WILL BE TESTED.//
     1       8X,1HX,9X,8HX - F(X)/)
 1035 FORMAT(43H TEST OF UNDERFLOW FOR VERY SMALL ARGUMENT. /)
 1040 FORMAT(33H THE RELATIVE ERROR IN TAN(11) IS  ,E15.7,3H = ,
     1     I4,3H **,F7.2,6H WHERE /)
 1050 FORMAT(22H1TEST OF ERROR RETURNS//)
 1051 FORMAT(37H TAN WILL BE CALLED WITH THE ARGUMENT,E15.4/
     1       41H THIS SHOULD NOT TRIGGER AN ERROR MESSAGE//)
 1052 FORMAT(37H0TAN WILL BE CALLED WITH THE ARGUMENT,E15.4/
     1       37H THIS SHOULD TRIGGER AN ERROR MESSAGE//)
 1055 FORMAT(23H TAN RETURNED THE VALUE,E15.4///)
 1060 FORMAT(2E15.7/)
 1061 FORMAT(6X,5H TAN(,E13.6,3H) =,E13.6/)
 1100 FORMAT(25H THIS CONCLUDES THE TESTS )
C     ---------- LAST CARD OF TAN/COTAN TEST PROGRAM ----------
      END
      REAL FUNCTION REN(K)
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
      REN = FLOAT(IY) / 2796203.0E0
      RETURN
C     ---------- LAST CARD OF RAN ----------
      END
      FUNCTION COTAN(X)
C
      T = TAN(X)
      COTAN = -1.1111E-11
      IF (T .NE. 0.0E0) COTAN = 1.0E0 / T
      RETURN
      END
