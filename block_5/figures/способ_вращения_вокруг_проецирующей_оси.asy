string wd = cd("./");
cd("../../");
import env;
cd(wd);

// settings.render = 1;
// settings.outformat = "html";

real
figwidth = textwidth,
figheight = .3 * textheight;

real
x = .4 * figwidth,
z = .6 * figheight,
y = (figheight - z) / (.5 * Cos(45));

triple
Xm = scale3(x) * X,
Ym = scale3(y) * Y,
Zm = scale3(z) * Z;


transform3 baseTF = identity4;
baseTF[0][0] = -1;            // масштаб по оси X
baseTF[0][1] =  .5 * Cos(45); // сдвиг по оси Y
baseTF[1][1] = -.5 * Cos(45); // масштаб по оси Y
baseTF[1][2] =  1;            // масштаб по оси Z
baseTF[2][1] =  1;
baseTF[2][2] =  0;  // сдвиг по оси Z

transform3 labelTF = copy(baseTF);
labelTF[0][1] /= Cos(45);
labelTF[1][1] /= Cos(45);

currentprojection = projection(
    camera=(.5, -1, .5),
    normal=(0, -1, 0),
    projector=new transformation(triple, triple, triple) { return transformation(baseTF); }
);

projection
labelprojection = projection(
    camera=currentprojection.camera,
    normal=currentprojection.normal,
    projector=new transformation(triple, triple, triple) { return transformation(labelTF); }
);


path3
plane1 = O--Ym--shift(Xm - 1.5 * ahsize * X) * (Ym--O),
plane2 = O--Zm--shift(point(plane1, 3)) * (Zm--O);

real R = .25x;  // радиус окружности

triple cO = (.5x, .4y, .7z);
path3 circ = circle(cO, R);
path3 i = shift(cO) * ((cO.z * -Z)--(.75 * (Zm - cO).z * Z));
triple A    = rotate(45, cO, point(i, 1)) * point(circ, 0);
triple A_tf = rotate(117, cO, point(i, 1)) * A;

triple cO1   = planeproject(-Z) * cO;
path3 circ1  = planeproject(-Z) * circ;
triple A1    = planeproject(-Z) * A;
triple A1_tf = planeproject(-Z) * A_tf;

triple cO2   = planeproject(-Y) * cO;
path3 circ2  = planeproject(-Y) * circ;
triple A2    = planeproject(-Y) * A;
path3 i2     = planeproject(-Y) * i;
triple A2_tf = planeproject(-Y) * A_tf;


draw(O--Xm, L=MyLabel("X₁₂", position=1, align=N));
drawMyArrowHead3(O--Xm, normal=Y);

draw(plane1);
label(
    project(MyLabel("Π₁", sl=false, align=NE), -X, -Y, P=labelprojection),
    position=point(plane1, 2)
);

draw(plane2);
label(MyLabel("Π₂", sl=false, align=SE), position=point(plane2, 2));


draw(circ, p=linewidth(baselinewidth));

draw(i, L=MyLabel("i", align=WSW, position=1));
draw(cO--A);
draw(A--A1);
draw(A--A2);
dot(A, L=MyLabel("A", align=SW));

draw(cO--A_tf);
draw(A_tf--A1_tf);
draw(A_tf--A2_tf);
dot(A_tf, L=MyLabel("\bar{A}", align=SE, filltype=UnFill(ymargin=.2 * fontsize)));

dot(cO, L=MyLabel("O", align=WNW));
label(MyLabel("Σ"), position=point(cO--intersectionpoints(circ, A--A2)[1], .5));


draw(circ1, p=linewidth(baselinewidth));

draw(cO1--A1);
draw(planeproject(-Z) * (A--A2));
dot(A1, L=project(MyLabel("A₁", align=SW), -X, -Y, P=labelprojection));

draw(cO1--A1_tf);
draw(planeproject(-Z) * (A_tf--A2_tf));
dot(A1_tf, L=project(MyLabel("\bar{A}₁", align=SE), -X, -Y, P=labelprojection));

draw(planeproject(-Z) * (cO--cO2));
dot(cO1, L=project(MyLabel("O₁ ≡ i₁", align=ENE), -X, -Y, P=labelprojection));

path3 anglemark = arc(
    cO1, .4R,
    theta1=90, phi1=longitude(A1 - cO1),
    theta2=90, phi2=longitude(A1_tf - cO1)
);
draw(anglemark, L=project(MyLabel("φ", align=.4S), -X, -Y, P=labelprojection));
drawMyArrowHead3(anglemark);


draw(circ2, p=linewidth(baselinewidth));
draw(i2, L=MyLabel("i₂", align=W, position=1));
draw(planeproject(-Y) * (A--A1));
draw(planeproject(-Y) * (A_tf--A1_tf));
draw(
    shift(min(circ2)) * (O--(3.5 * fontsize * -X)),
    L=MyLabel("Σ₂", align=NW, position=EndPoint)
);

dot(cO2, L=MyLabel("O₂", align=NE));
dot(A2, L=MyLabel("A₂", align=N));
dot(A2_tf, L=MyLabel("\bar{A}₂", align=N));
