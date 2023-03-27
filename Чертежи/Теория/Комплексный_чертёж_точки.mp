input mparrows;

prologues := 3;

u = 1mm;
base_line_thickness = .15u;

ahangle := 20;
ahlength := 10 * base_line_thickness;

setarrows(open);

beginfig(1)

x_max := 30u;   % максимальное значение X
z_max := 26u;   % максимальное значение Z
y3_max := 21u;  % максимальное значение Y в плоскости П3
y1_max := 26u;  % максимальное значение Y в плоскости П1

pair O, X, Z, Y[];

O := (0, 0);
X := (-x_max, 0);
Z := (0, z_max);
Y1 := (0, -y1_max);
Y3 := (y3_max, 0);

path hor_axis, vert_axis, k, dot;

hor_axis := X--Y3;
vert_axis := Y1--Z;
k := O--(y3_max, -y3_max);  % постоянная прямая чертежа
dot := fullcircle scaled .75u;

pair A[];

A.x := 21u;
A.y := 12u;
A.z := 17u;

A1 := (-A.x, -A.y);
A2 := (-A.x, A.z);
A3 := (A.y, A.z);

A12 = whatever[A1, A2] = whatever[O, X];
A23 = whatever[A2, A3] = whatever[O, Z];
A13 = whatever[O, (y3_max, -y3_max)];
(A13 - A1) dotprod (Y1 - O) = 0;


pickup pencircle scaled base_line_thickness;

drawdblarrow hor_axis;
label.top(btex $X_{12}$ etex, X);
label.top(btex $Y_3$ etex, Y3);
drawdblarrow vert_axis;
label.rt(btex $Y_1$ etex, Y1);
label.rt(btex $Z_{23}$ etex, Z);
draw k;
label.rt(btex $k_0$ etex, (y3_max, -y3_max));
label.ulft("0", O);

draw A1 -- A2;
draw A1 -- A13;
draw A13 -- A3;
draw A2 -- A3;

for point=A1, A2, A3, A12, A23:
    fill dot shifted point withcolor white;
    draw dot shifted point;
endfor

label.bot(btex $A_1$ etex, A1);
label.top(btex $A_2$ etex, A2);
label.top(btex $A_3$ etex, A3);
label.urt(btex $A_{12}$ etex, A12);
label.ulft(btex $A_{23}$ etex, A23);

label.top(btex $X_A$ etex, .4[A2, A23]);
label.top(btex $X_A$ etex, .6[A12, O]);
label.top(btex $X_A$ etex, .3[A1, A13]);  % TODO

label.lft(btex $Z_A$ etex rotated 90, .5[A12, A2]);
label.lft(btex $Z_A$ etex rotated 90, .5[O, A23]);
label.lft(btex $Z_A$ etex rotated 90, .3[A3, A13]);  % TODO

label.lft(btex $Y_A$ etex rotated 90, .5[A1, A12]);
label.lft(btex $Y_A$ etex rotated 90, .25[O, Y1]);  % TODO
label.top(btex $Y_A$ etex, .3[O, Y3]);
label.top(btex $Y_A$ etex, .25[A13, A1]);  % TODO
label.lft(btex $Y_A$ etex rotated 90, .3[A13, A3]);  % TODO

endfig;

end.