* Foster Equivalent RLC Circuit for simple_model
.SUBCKT simple_model p1 0
R_D p1 nd_D 1.00001
* Real Pole Branch 1
C_1 nd_D n_1 1.85887e-09
R_1 nd_D n_1 1.42334e-05
* Complex Pole Branch 2
R_short_2 n_1 n_2 1e-3
* Complex Pole Branch 3
C_3 n_2 n_3 0.00807015
R_3 n_2 n_3 0.000290863
L_3 n_2 n_3 9.25086e-20
* Complex Pole Branch 4
C_4 n_3 n_4 0.00351378
R_4 n_3 n_4 1.69861e-06
L_4 n_3 n_4 1.17826e-18
* Complex Pole Branch 5
R_short_5 n_4 0 1e-3
.ENDS
