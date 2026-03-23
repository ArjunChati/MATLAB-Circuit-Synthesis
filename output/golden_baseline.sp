* Equivalent circuit model for output\golden_baseline.sp
.SUBCKT golden_baseline po1
Vsp1 po1 p1 0
Vsr1 p1 pr1 0
Rp1 pr1 0 50
Ru1 u1 0 50
Fr1 u1 0 Vsr1 -1
Fu1 u1 0 Vsp1 -1
Ry1 y1 0 1
Gy1 p1 0 y1 0 -0.02
Rx1 x1 0 1
Cx1 x1 0 7.24038398689957e-29
Gx1_1 x1 0 u1 0 -1
Rx2 x2 0 1
Cx2 x2 0 4.51416229645136e-11
Gx2_1 x2 0 u1 0 -2.26778683805536
Rx3 x3 0 1
Cx3 x3 0 2.21525043702153e-10
Gx3_1 x3 0 u1 0 -2.26778683805536
Gyc1_1 y1 0 x1 0 1
Gyc1_2 y1 0 x2 0 -1
Gyc1_3 y1 0 x3 0 1
.ENDS
