C     PROGRAM TO TEST POWER FUNCTION (**)
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
C                 MINEXP - THE LARGEST IN MAGNITUDE NEGATIVE
C                          INTEGER SUCH THAT  FLOAT(IBETA)**MINEXP
C                          IS A POSITIVE FLOATING-POINT NUMBER
C                 MAXEXP - THE LARGEST POSITIVE INTEGER EXPONENT
C                          FOR A FINITE FLOATING-POINT NUMBER
C                 XMIN   - THE SMALLEST NON-VANISHING FLOATING-POINT
C                          POWER OF THE RADIX
C                 XMAX   - THE LARGEST FINITE FLOATING-POINT
C                          NUMBER
C
C        REN(K) - A FUNCTION SUBPROGRAM RETURNING RANDOM REAL
C                 NUMBERS UNIFORMLY DISTRIBUTED OVER (0,1)
C
C
C     STANDARD FORTRAN SUBPROGRAMS REQUIRED
C
C         ABS, ALOG, AMAX1, EXP, FLOAT, SQRT
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
      REAL A,AIT,ALBETA,ALXMAX,B,BETA,C,DEL,DELY,EPS,EPSNEG,ONE,
     1     ONEP5,RAN,R6,R7,SCALE,TWO,W,X,XL,XMAX,XMIN,XN,
     2     XSQ,X1,Y,Y1,Y2,Z,ZERO,ZZ
C
      IOUT = 6
      CALL MACHAR(IBETA,IT,IRND,NGRD,MACHEP,NEGEP,IEXP,MINEXP,
     1            MAXEXP,EPS,EPSNEG,XMIN,XMAX)
      BETA = FLOAT(IBETA)
      ALBETA = ALOG(BETA)
      AIT = FLOAT(IT)
      ALXMAX = ALOG(XMAX)
      ZERO = 0.0E0
      ONE = FLOAT(1)
      TWO = ONE + ONE
      ONEP5 = (TWO + ONE) / TWO
      SCALE = ONE
      J = (IT+1) / 2
C
      DO 20 I = 1, J
         SCALE = SCALE * BETA
   20 CONTINUE
C
      A = ONE / BETA
      B = ONE
      C = -AMAX1(ALXMAX,-ALOG(XMIN))/ALOG(100E0)
      DELY = -C - C
      N = 2000
      XN = FLOAT(N)
      I1 = 0
      Y1 = ZERO
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
            IF (J .NE. 1) GO TO 50
            ZZ = X ** ONE
            Z = X
            GO TO 110
   50       W = SCALE * X
            X = (X + W) - W
            XSQ = X * X
            IF (J .EQ. 4) GO TO 70
            ZZ = XSQ ** ONEP5
            Z = X * XSQ
            GO TO 110
   70       Y = DELY * REN(I1) + C
            Y2 = (Y/TWO + Y) - Y
            Y = Y2 + Y2
            Z = X ** Y
            ZZ = XSQ ** Y2
  110       W = ONE
            IF (Z .NE. ZERO) W = (Z - ZZ) / Z
            IF (W .GT. ZERO) K1 = K1 + 1
            IF (W .LT. ZERO) K3 = K3 + 1
            W = ABS(W)
            IF (W .LE. R6) GO TO 120
            R6 = W
            X1 = X
            IF (J .EQ. 4) Y1 = Y
  120       R7 = R7 + W * W
            XL = XL + DEL
  200    CONTINUE
C
         K2 = N - K3 - K1
         R7 = SQRT(R7/XN)
         IF (J .GT. 1) GO TO 210
         WRITE (IOUT,1000)
         WRITE (IOUT,1010) N,A,B
         WRITE (IOUT,1011) K1,K2,K3
         GO TO 220
  210    IF (J .EQ. 4) GO TO 215
         WRITE (IOUT,1001)
         WRITE (IOUT,1010) N,A,B
         WRITE (IOUT,1012) K1,K2,K3
         GO TO 220
  215    WRITE (IOUT,1002)
         W = C + DELY
         WRITE (IOUT,1014) N,A,B,C,W
         WRITE (IOUT,1013) K1,K2,K3
  220    WRITE (IOUT,1020) IT,IBETA
         W = -999.0E0
         IF (R6 .NE. ZERO) W = ALOG(ABS(R6))/ALBETA
         IF (J .NE. 4) WRITE (IOUT,1021) R6,IBETA,W,X1
         IF (J .EQ. 4) WRITE (IOUT,1024) R6,IBETA,W,X1,Y1
         W = AMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
         W = -999.0E0
         IF (R7 .NE. ZERO) W = ALOG(ABS(R7))/ALBETA
         WRITE (IOUT,1023) R7,IBETA,W
         W = AMAX1(AIT+W,ZERO)
         WRITE (IOUT,1022) IBETA,W
         IF (J .EQ. 1) GO TO 300
         B = 10.0E0
         A = 0.01E0
         IF (J .EQ. 3) GO TO 300
         A = ONE
         B = EXP(ALXMAX/3.0E0)
  300 CONTINUE
C-----------------------------------------------------------------
C     SPECIAL TESTS
C-----------------------------------------------------------------
      WRITE (IOUT,1025)
      WRITE (IOUT,1030)
      B = 10.0E0
C
      DO 320 I = 1, 5
         X = REN(I1) * B + ONE
         Y = REN(I1) * B + ONE
         Z = X ** Y
         ZZ = (ONE/X) ** (-Y)
         W = (Z - ZZ) / Z
         WRITE (IOUT,1060) X, Y, W
  320 CONTINUE
C-----------------------------------------------------------------
C     TEST OF ERROR RETURNS
C-----------------------------------------------------------------
      WRITE (IOUT,1050)
      X = BETA
      Y = FLOAT(MINEXP)
      WRITE (IOUT,1051) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      Y = FLOAT(MAXEXP-1)
      WRITE (IOUT,1051) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      X = ZERO
      Y = TWO
      WRITE (IOUT,1051) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      X = -Y
      Y = ZERO
      WRITE (IOUT,1052) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      Y = TWO
      WRITE (IOUT,1052) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      X = ZERO
      Y = ZERO
      WRITE (IOUT,1052) X, Y
      Z = X ** Y
      WRITE (IOUT,1055) Z
      WRITE (IOUT,1100)
      STOP
 1000 FORMAT(20H1TEST OF X**1.0 VS X  //)
 1001 FORMAT(26H1TEST OF XSQ**1.5 VS XSQ*X  //)
 1002 FORMAT(27H1TEST OF X**Y VS XSQ**(Y/2)  //)
 1010 FORMAT(I7,47H RANDOM ARGUMENTS WERE TESTED FROM THE INTERVAL /
     1 6X,1H(,E15.4,1H,,E15.4,1H)//)
 1011 FORMAT(18H X**1.0 WAS LARGER,I6,7H TIMES, /
     1     11X,7H AGREED,I6,11H TIMES, AND /
     2   7X,11HWAS SMALLER,I6,7H TIMES.//)
 1012 FORMAT(18H X**1.5 WAS LARGER,I6,7H TIMES, /
     1     11X,7H AGREED,I6,11H TIMES, AND /
     2   7X,11HWAS SMALLER,I6,7H TIMES.//)
 1013 FORMAT(18H  X**Y  WAS LARGER,I6,7H TIMES, /
     1     11X,7H AGREED,I6,11H TIMES, AND /
     2   7X,11HWAS SMALLER,I6,7H TIMES.//)
 1014 FORMAT(I7,45H RANDOM ARGUMENTS WERE TESTED FROM THE REGION /
     1 6X,6HX IN (,E15.4,1H,,E15.4,9H), Y IN (,E15.4,1H,,E15.4,1H)//)
 1020 FORMAT(10H THERE ARE,I4,5H BASE,I4,
     1    46H SIGNIFICANT DIGITS IN A FLOATING-POINT NUMBER  //)
 1021 FORMAT(30H THE MAXIMUM RELATIVE ERROR OF,E15.4,3H = ,I4,3H **,
     1  F7.2/4X,16HOCCURRED FOR X =,E17.6)
 1022 FORMAT(27H THE ESTIMATED LOSS OF BASE,I4,
     1  22H SIGNIFICANT DIGITS IS,F7.2//)
 1023 FORMAT(40H THE ROOT MEAN SQUARE RELATIVE ERROR WAS,E15.4,
     1    3H = ,I4,3H **,F7.2)
 1024 FORMAT(30H THE MAXIMUM RELATIVE ERROR OF,E15.4,3H = ,I4,3H **,
     1  F7.2/4X,16HOCCURRED FOR X =,E17.6,4H Y =,E17.6)
 1025 FORMAT(14H1SPECIAL TESTS//)
 1030 FORMAT(54H THE IDENTITY  X ** Y = (1/X) ** (-Y)  WILL BE TESTED.
     1    //8X,1HX,14X,1HY,9X,24H(X**Y-(1/X)**(-Y) / X**Y /)
 1050 FORMAT(22H1TEST OF ERROR RETURNS//)
 1051 FORMAT(2H (,E14.7,7H ) ** (,E14.7,20H ) WILL BE COMPUTED.,/
     1       41H THIS SHOULD NOT TRIGGER AN ERROR MESSAGE//)
 1052 FORMAT(2H (,E14.7,7H ) ** (,E14.7,20H ) WILL BE COMPUTED.,/
     1       37H THIS SHOULD TRIGGER AN ERROR MESSAGE//)
 1055 FORMAT(22H THE VALUE RETURNED IS,E15.4///)
 1060 FORMAT(2E15.7,6X,E15.7/)
 1100 FORMAT(25H THIS CONCLUDES THE TESTS )
C     ---------- LAST CARD OF POWER TEST PROGRAM ----------
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
