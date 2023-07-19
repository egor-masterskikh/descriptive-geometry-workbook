string wd = cd("./");
cd("../../");
import env;
cd(wd);

real
figwidth = textwidth,
figheight = .3 * textheight;

currentprojection = orthographic(.35, 1, .5);

real
z = .75 * figheight,
x = 1.25 * z,
y = x;

triple
Xm = scale3(x) * X,
Ym = scale3(y) * Y,
Zm = scale3(z) * Z;


path3
plane1 = O--Ym--shift(Xm - 1.5 * ahsize * X) * (Ym--O),
plane2 = O--Zm--shift(point(plane1, 3)) * (Zm--O);

triple cO = (.5x, .5y, .6z);
real R = .25x;
path3 circ = circle(cO, R);

path3 i = shift(cO) * ((cO.z * -Z)--(4 * fontsize * Z));
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


draw(plane1);
label(project(MyLabel("Π₁", sl=false, align=-X - Y), -X, -Y), position=point(plane1, 2));

draw(plane2);
label(project(MyLabel("Π₂", sl=false, align=-X - Z), -X, Z), position=point(plane2, 2));

draw(circ, p=linewidth(baselinewidth));

draw(Path3(i, circ));
label(MyLabel("i", align=WSW), position=relpoint(i, 1));
draw(cO--A);
draw(A--A1);
draw(A--A2);

draw(cO--A_tf);
draw(A_tf--A1_tf);
draw(A_tf--A2_tf);

dot(cO, L=MyLabel("O", align=WNW));

projection[] projections = {currentprojection, TopView, FrontView};
picture[] pictures = {currentpicture, new picture, new picture};
projection curproj;
picture curpic;

for (int i = 0; i < 3; ++i) {
    curproj = projections[i];
    curpic = pictures[i];

    if (i == 0 || i == 1) {
        draw(pic=curpic, circ1, p=linewidth(baselinewidth));

        draw(pic=curpic, cO1--A1);
        draw(pic=curpic, planeproject(-Z) * (A--A2));
        dot(pic=curpic, A1, L=project(MyLabel("A₁", align=X + Y), -X, -Y, P=curproj));

        draw(pic=curpic, cO1--A1_tf);
        draw(pic=curpic, planeproject(-Z) * (A_tf--A2_tf));
        dot(pic=curpic, A1_tf, L=project(MyLabel("\bar{A}₁", align=-X), -X, -Y, P=curproj));

        if (i == 1) {
            path3 Rline = cO1--rotate(-55, cO1, cO1 + normal(circ1)) * point(circ1, 0);
            draw(pic=curpic, Rline);
            drawMyArrowHead3(pic=curpic, Rline);
            label(
                pic=curpic,
                project(MyLabel("R", align=-X - .5Y), -X, -Y, P=curproj),
                position=point(Rline, .75)
            );
        }

        draw(pic=curpic, planeproject(-Z) * (cO--cO2));
        dot(pic=curpic, cO1, L=project(MyLabel("O₁ ≡ i₁", align=-X - Y), -X, -Y, P=curproj));

        path3 anglemark = arc(
            cO1, .4R,
            theta1=90, phi1=longitude(A1 - cO1),
            theta2=90, phi2=longitude(A1_tf - cO1)
        );
        draw(pic=curpic, anglemark, L=project(MyLabel("φ", align=.5Y), -X, -Y, P=curproj));
        drawMyArrowHead3(pic=curpic, anglemark);
    }
    if (i == 0 || i == 2) {
        draw(pic=curpic, O--Xm);
        drawMyArrowHead3(pic=curpic, O--Xm, normal=Y);
        label(
            pic=curpic,
            project(MyLabel("X₁₂", align=Z), -X, Z, P=curproj),
            position=relpoint(O--Xm, 1)
        );

        draw(pic=curpic, circ2, p=linewidth(baselinewidth));
        draw(pic=curpic, Path3(i2, circ, P=curproj));
        label(
            pic=curpic,
            project(MyLabel("i₂", align=X), -X, Z, P=curproj),
            position=relpoint(i2, 1)
        );
        draw(pic=curpic, planeproject(-Y) * (A--A1));
        draw(pic=curpic, Path3(planeproject(-Y) * (A_tf--A1_tf), circ, P=curproj));

        path3 Sigma2_line = shift(min(circ2)) * (O--(3.5 * fontsize * -X));
        draw(pic=curpic, Sigma2_line);
        label(
            pic=curpic,
            project(MyLabel("Σ₂", align=Z + .5X), -X, Z, P=curproj),
            position=relpoint(Sigma2_line, 1)
        );

        dot(pic=curpic, cO2, L=project(MyLabel("O₂", align=-X + Z), -X, Z, P=curproj));
        dot(pic=curpic, A2, L=project(MyLabel("A₂", align=Z), -X, Z, P=curproj));
        dot(pic=curpic, A2_tf, L=project(MyLabel("\bar{A}₂", align=Z), -X, Z, P=curproj));
    }
}

dot(A, L=MyLabel("A", align=SW, filltype=UnFill(xmargin=.1 * fontsize)));
dot(A_tf, L=MyLabel("\bar{A}", align=SE, filltype=UnFill(ymargin=.2 * fontsize)));
label(
    MyLabel("Σ", filltype=UnFill(xmargin=.2 * fontsize)),
    position=point(cO--intersectionpoints(circ, A--A2)[1], .5)
);

frame[] frames = new frame[2];

frames[0] = rotate(180) * pictures[1].fit(projections[1]);
frames[1] = reflect((0, 0), (0, 1)) * pictures[2].fit(projections[2]);

picture twoviews;

add(dest=twoviews, src=frames[0]);
add(dest=twoviews, src=frames[1]);

add(twoviews.fit(), align=E, position=max(currentpicture.fit()).x * right);
