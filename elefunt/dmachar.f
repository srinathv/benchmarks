      SUBROUTINE MACHAR(IBETA,IT,IRND,NGRD,MACHEP,NEGEP,IEXP,MINEXP,
     1                    MAXEXP,EPS,EPSNEG,XMIN,XMAX)
C
      DOUBLE PRECISION A,B,BETA,BETAIN,BETAM1,EPS,EPSNEG,ONE,XMAX,
     1                  XMIN,Y,Z,ZERO
C
      ONE = DBLE(FLOAT(1))
      ZERO = 0.0D0
      A = ONE
   10 A = A + A
         IF (((A+ONE)-A)-ONE .EQ. ZERO) GO TO 10
      B = ONE
   20 B = B + B
         IF ((A+B)-A .EQ. ZERO) GO TO 20
      IBETA = IDINT((A+B)-A)
      BETA = DBLE(FLOAT(IBETA))
      IT = 0
      B = ONE
  100 IT = IT + 1
         B = B * BETA
         IF (((B+ONE)-B)-ONE .EQ. ZERO) GO TO 100
      IRND = 0
      BETAM1 = BETA - ONE
      IF ((A+BETAM1)-A .NE. ZERO) IRND = 1
      NEGEP = IT + 3
      BETAIN = ONE / BETA
      A = ONE
      DO 200 I = 1, NEGEP
         A = A * BETAIN
  200 CONTINUE
      B = A
  210 IF ((ONE-A)-ONE .NE. ZERO) GO TO 220
         A = A * BETA
         NEGEP = NEGEP - 1
      GO TO 210
  220 NEGEP = -NEGEP
      EPSNEG = A
      IF ((IBETA .EQ. 2) .OR. (IRND .EQ. 0)) GO TO 300
      A = (A*(ONE+A)) / (ONE+ONE)
      IF ((ONE-A)-ONE .NE. ZERO) EPSNEG = A
  300 MACHEP = -IT-3
      A = B
  310 IF ((ONE+A)-ONE .NE. ZERO) GO TO 320
         A = A * BETA
         MACHEP = MACHEP + 1
      GO TO 310
  320 EPS = A
      IF ((IBETA .EQ. 2) .OR. (IRND .EQ. 0)) GO TO 350
      A = (A*(ONE+A)) / (ONE+ONE)
      IF ((ONE+A)-ONE .NE. ZERO) EPS = A
  350 NGRD = 0
      IF ((IRND .EQ. 0) .AND. ((ONE+EPS)*ONE-ONE) .NE. ZERO) NGRD = 1
      I = 0
      K = 1
      Z = BETAIN
  400 Y = Z
         Z = Y * Y
         A = Z * ONE
         IF ((A+A .EQ. ZERO) .OR. (ABS(Z) .GE. Y)) GO TO 410
         I = I + 1
         K = K + K
      GO TO 400
  410 IF (IBETA .EQ. 10) GO TO 420
      IEXP = I + 1
      MX = K + K
      GO TO 450
  420 IEXB = 2
      IZ = BETA
  430 IF (K .LT. Z) GO TO 440
         IZ = IZ * IBETA
         IEXP = IEXP + 1
      GO TO 430
  440 MX = IZ + IZ - 1
  450 XMIN = Y
         Y = Y * BETAIN
         A = Y * ONE
         IF (((A+A) .EQ. ZERO) .OR. (ABS(Y) .GE. XMIN)) GO TO 460
         K = K + 1
      GO TO 450
  460 MINEXP = -K
      IF ((MX .GT. K+K-3) .OR. (IBETA .EQ. 10)) GO TO 500
      MX = MX + MX
      IEXP = IEXP + 1
  500 MAXEXP = MX + MINEXP
      I = MAXEXP + MINEXP
      IF ((IBETA .EQ. 2) .AND. (I .EQ. 0)) MAXEXP = MAXEXP - 1
      IF (I .GT. 20) MAXEXP = MAXEXP - 1
      IF (A .NE. Y) MAXEXP = MAXEXP - 2
      XMAX = ONE - EPSNEG
      IF (XMAX*ONE .NE. XMAX) XMAX = ONE - BETA * EPSNEG
      XMAX = XMAX / (BETA * BETA * BETA * XMIN)
      I = MAXEXP + MINEXP + 3
      IF (I .LE. 0) GO TO 520
      DO 510 J = 1, I
         IF (IBETA .EQ. 2) XMAX = XMAX + XMAX
         IF (IBETA .NE. 2) XMAX = XMAX * BETA
  510 CONTINUE
  520 RETURN
C ---------- LAST CAR OF MACHAR ----------
      END
