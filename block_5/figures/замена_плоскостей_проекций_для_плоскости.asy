import "../../env.asy" as env;

real
figwidth = .5 * textwidth,
figheight = .3 * textheight;

real
x = .8 * figwidth,
y = .6 * figheight,
z = figheight - y;

triple
O = (0, 0, 0),
X = (x, 0, 0),
Z = (0, 0, z),
A = (.8x, .2y, .5z),
B = (.1x, .1y, .8z),
C = (.35x, .8y, .15z),
H = findPoint(B, C, z=A.z);

Pair
O12 = Pair(project(O, P=TopView)),
X12 = Pair(project(X, P=TopView));

Pair
A1 = Pair(project(A, P=TopView)),
B1 = Pair(project(B, P=TopView)),
C1 = Pair(project(C, P=TopView)),
H1 = Pair(project(H, P=TopView));

Pair
A2 = Pair(project(A, P=FrontView)),
B2 = Pair(project(B, P=FrontView)),
C2 = Pair(project(C, P=FrontView)),
H2 = Pair(project(H, P=FrontView));

X = scale3(x) * rotate(90, Z) * unit(A - H);  // ось X меняет своё положение

projection ProjView = orthographic(A - H);

Pair
O14 = Pair(project(O, P=ProjView)),
X14 = Pair(project(X, P=ProjView));

Pair
A4 = Pair(project(A, P=ProjView)),
B4 = Pair(project(B, P=ProjView)),
C4 = Pair(project(C, P=ProjView)),
H4 = Pair(project(H, P=ProjView));

projection NaturalView = orthographic(cross(B - A, C - B));

Pair
O45 = Pair(project(O, P=NaturalView)),
X45 = Pair(project(X, P=NaturalView)),
Y45 = Pair(project(Y, P=NaturalView));

Pair
A5 = Pair(project(A, P=NaturalView)),
B5 = Pair(project(B, P=NaturalView)),
C5 = Pair(project(C, P=NaturalView)),
H5 = Pair(project(H, P=NaturalView));


Pairs
plane1 = Pairs(O12, X12, A1, B1, C1, H1),
plane2 = Pairs(A2, B2, C2, H2),
plane4 = Pairs(O14, X14, A4, B4, C4, H4),
plane5 = Pairs(O45, X45, A5, B5, C5, H5);

Pairs[] planes = {plane1, plane2, plane4, plane5};

// преобразования плоскостей
for (int i = 0; i < planes.length; ++i) {
    if (i == 1) continue;

    if (i >= 0) {
        reflect(O12, X12) * planes[i];
    }
    if (i == 2) {
        rotate(degrees(A1 - H1) - 90) * planes[i];
        shiftPerp(X14 - O14, -fontsize) * planes[i];
    }
    if (i == 3) {
        rotate(degrees(C4 - B4) - 90) * planes[i];
        shift(B4 - B5) * planes[i];
        shiftPerp(
            B4 - C4,
            cross(B4 - O45, C4 - B4) / length(C4 - B4)  // расстояние между осью O₄₅X₄₅ и B₄C₄
            + 2.5 * fontsize
        ) * planes[i];
    }
}

// отражение всех плоскостей относительно вертикальной оси
for (int i = 0; i < planes.length; ++i)
    reflect(O12, N) * planes[i];


Pair
A12 = Pair(extension(A1, A2, O12, X12)),
B12 = Pair(extension(B1, B2, O12, X12)),
C12 = Pair(extension(C1, C2, O12, X12));

Pair
A14 = Pair(extension(A1, A4, O14, X14)),
B14 = Pair(extension(B1, B4, O14, X14)),
C14 = Pair(extension(C1, C4, O14, X14));

Pair
A45 = Pair(extension(A4, A5, O45, X45)),
B45 = Pair(extension(B4, B5, O45, X45)),
C45 = Pair(extension(C4, C5, O45, X45));


O14 = shiftParallel(X14 - O14, length(O14 - B14) - fontsize) * O14;
X14 = shiftParallel(X14 - O14, -length(X14 - C14) + 4 * fontsize) * X14;

O45 = shiftParallel(X45 - O45, -length(O45 - B45) - fontsize) * O45;
X45 = shiftParallel(X45 - O45, -length(X45 - C45) + 4 * fontsize) * X45;


draw(O12--X12, L=MyLabel("X_{12}", position=EndPoint, align=N), arrow=MyArrow);
label(MyLabel("Π_1", italic=false, position=arcpoint(X12--O12, 1.6 * ahsize), align=SSE));
label(MyLabel("Π_2", italic=false, position=arcpoint(X12--O12, 1.6 * ahsize), align=NNE));

draw(A1--A12);
draw(A12--A2, marker=StickMarker(n=3));

draw(B1--B12);
draw(B12--B2, marker=StickMarker(n=2));

draw(C1--C12);
draw(C12--C2, marker=StickMarker(n=1));

draw(H1--H2);

draw(A1--B1--C1--cycle, p=linewidth(baselinewidth));
label(MyLabel("h_1", position=point(A1--H1, .9), align=N));

draw(A2--B2--C2--cycle, p=linewidth(baselinewidth));
draw(
    shift(A2) * 
    scale(length(H2 - A2) + abs(B.x - H.x) + fontsize) * 
    (O12--unit(H2 - A2)),
    L=MyLabel("h_2", position=EndPoint, align=N)
);


draw(O14--X14, L=MyLabel("X_{14}", position=EndPoint, align=W), arrow=MyArrow);
label(MyLabel("Π_1", italic=false, position=arcpoint(X14--O14, 1.6 * ahsize), align=WNW));
label(MyLabel("Π_4", italic=false, position=arcpoint(X14--O14, 1.6 * ahsize), align=SE));

draw(A1--A14, marker=TildeMarker());
draw(A14--A4, marker=StickMarker(n=3));

draw(B1--B14, marker=CrossMarker());
draw(B14--B4, marker=StickMarker(n=2));

draw(C1--C14, marker=CrossMarker(n=4));
draw(C14--C4, marker=StickMarker(n=1));

perpendicular(A14, align=SE, dir=X14 - O14, size=perpmarksize);

draw(A4--B4--C4--cycle, p=linewidth(baselinewidth));
pair anglevec = scale(markangleradius() + fontsize) * unit(O14 - X14);
path angleline = shift(C4) * ((0, 0)--anglevec);
draw(angleline);
markangle(L="\textit{α}", B4, C4, point(angleline, 1));


draw(O45--X45, L=MyLabel("X_{45}", position=EndPoint, align=S), arrow=MyArrow);
label("$\mathrm{Π_5}$", position=arcpoint(X45--O45, 1.6 * ahsize), align=SE);

draw(A4--A45);
draw(A45--A5, marker=TildeMarker());

draw(B4--B45);
draw(B45--B5, marker=CrossMarker());

draw(C4--C45);
draw(C45--C5, marker=CrossMarker(n=4));

draw(A5--B5--C5--cycle, p=linewidth(baselinewidth));
label(MyLabel("h_5", position=point(A5--H5, .7), align=NNE));


dot(A1, L=MyLabel("A_1", align=W));
dot(B1, L=MyLabel("B_1", align=SSE));
dot(C1, L=MyLabel("C_1", align=S));
dot(H1, L=MyLabel("1_1", align=SSE));

dot(A2, L=MyLabel("A_2", align=W));
dot(B2, L=MyLabel("B_2", align=N));
dot(C2, L=MyLabel("C_2", align=E));
dot(H2, L=MyLabel("1_2", align=NW));

extensionLine(
    pFrom=A4,
    angle=degrees(B4 - A4) + 25,
    length=length(B4 - A4) + fontsize,
    L=MyLabel("A_4 \mathop{≡} h_4")
);
dot(A4);
dot(B4, L=MyLabel("B_4", align=N));
dot(C4, L=MyLabel("C_4", align=SSW));

draw(A5--H5);
dot(A5, L=MyLabel("A_5", align=E));
dot(B5, L=MyLabel("B_5", align=ENE));
dot(C5, L=MyLabel("C_5", align=SSW));
dot(H5, L=MyLabel("1_5", align=W));
