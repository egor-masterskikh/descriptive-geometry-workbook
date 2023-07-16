string wd = cd("./");
cd("../../");
import env;
cd(wd);

real
figwidth = textwidth,
figheight = .33 * textheight;

real
x = figwidth / 3,
y = .5 * figheight,
z = figheight - y;

triple
T = (.75x, .15y, .48z),
U = (.15x, .4y,  .85z),
V = (.5x,  .7y, .2z),
H = findPoint(U, V, z=T.z);

triple[] Theta = {T, U, V, H};

Pair
T1 = Pair(project(Theta[0], TopView)),
T2 = Pair(project(Theta[0], FrontView)),
U1 = Pair(project(Theta[1], TopView)),
U2 = Pair(project(Theta[1], FrontView)),
V1 = Pair(project(Theta[2], TopView)),
V2 = Pair(project(Theta[2], FrontView)),
H1 = Pair(project(Theta[3], TopView)),
H2 = Pair(project(Theta[3], FrontView));

Pairs
plane1 = Pairs(T1, U1, V1, H1),
plane2 = Pairs(T2, U2, V2, H2);

triple[] Theta_tf1 = map(
    new triple(triple p) {
        return rotate(-degrees(H1 - T1) + 90, Theta[1], shift(Z) * Theta[1]) * p;
    }, Theta
);

Pair
T1_tf1 = Pair(project(Theta_tf1[0], TopView)),
T2_tf1 = Pair(project(Theta_tf1[0], FrontView)),
U1_tf1 = Pair(project(Theta_tf1[1], TopView)),
U2_tf1 = Pair(project(Theta_tf1[1], FrontView)),
V1_tf1 = Pair(project(Theta_tf1[2], TopView)),
V2_tf1 = Pair(project(Theta_tf1[2], FrontView)),
H1_tf1 = Pair(project(Theta_tf1[3], TopView)),
H2_tf1 = Pair(project(Theta_tf1[3], FrontView));

Pairs
plane1_tf1 = Pairs(T1_tf1, U1_tf1, V1_tf1, H1_tf1),
plane2_tf1 = Pairs(T2_tf1, U2_tf1, V2_tf1, H2_tf1);

triple[] Theta_tf2 = map(
    new triple(triple p) {
        return rotate(degrees(U2_tf1 - V2_tf1) + 180, Theta_tf1[2], shift(Y) * Theta_tf1[2]) * p;
    }, Theta_tf1
);

Pair
T1_tf2 = Pair(project(Theta_tf2[0], TopView)),
T2_tf2 = Pair(project(Theta_tf2[0], FrontView)),
U1_tf2 = Pair(project(Theta_tf2[1], TopView)),
U2_tf2 = Pair(project(Theta_tf2[1], FrontView)),
V1_tf2 = Pair(project(Theta_tf2[2], TopView)),
V2_tf2 = Pair(project(Theta_tf2[2], FrontView)),
H1_tf2 = Pair(project(Theta_tf2[3], TopView)),
H2_tf2 = Pair(project(Theta_tf2[3], FrontView));

Pairs
plane1_tf2 = Pairs(T1_tf2, U1_tf2, V1_tf2, H1_tf2),
plane2_tf2 = Pairs(T2_tf2, U2_tf2, V2_tf2, H2_tf2);


Pairs[] planes = {
    plane1, plane2,
    plane1_tf1, plane2_tf1,
    plane1_tf2, plane2_tf2
};

// преобразования плоскостей
for (int i = 0; i < planes.length; ++i) {
    if (i % 2 == 0)
        reflect((0, 0), right) * planes[i];
    if (i # 2 >= 1)
        shiftParallel(left, abs((U1_tf1 - V1_tf1).x) + 4 * fontsize) * planes[i];
    if (i # 2 >= 2)
        shiftParallel(left, abs((U2_tf1 - V2_tf1).x) + 4 * fontsize) * planes[i];
}

shiftParallel(down, abs((T1 - T1_tf1).y)) * plane1_tf1;
shiftParallel(up, (T1_tf1 - T1_tf2).y) * plane1_tf2;
shiftParallel(up, abs(.5(U2_tf1 - V2_tf1).y)) * plane2_tf2;

// отражение всех плоскостей относительно вертикали
for (int i = 0; i < planes.length; ++i)
    reflect((0, 0), N) * planes[i];


draw(T1--T2);
draw(U1--U2);
draw(V1--V2);
draw(H1--H2);

draw(T1--U1--V1--cycle, p=linewidth(baselinewidth));
draw(T1--shiftParallel(H1 - T1, 2 * fontsize) * H1, L=MyLabel("h₁", position=1, align=E));

draw(T2--U2--V2--cycle, p=linewidth(baselinewidth));
draw(T2--H2);

draw(T2--H2, L=MyLabel("h₂", position=.65, align=NE));
draw(H2--H2_tf1);
drawMyArrowHead(firstcut(H2--H2_tf1, U1--U2).after, .5);
label(MyLabel("Σ^{T,1}_2", align=N), position=point(firstcut(H2--H2_tf1, U1--U2).after, .5));

draw(U2--U2_tf1, L=MyLabel("Σ^U_2", position=.5, align=N), arrow=MyArrow(position=.5));

draw(V2--shiftParallel(
    V2_tf1 - V2,
    abs((T2_tf1 - V2_tf1).x) + .5 * abs((U2_tf1 - T2_tf1).x)
) * V2_tf1);
drawMyArrowHead(firstcut(V2--V2_tf1, U1--U2).after, .5);
label(MyLabel("Σ^V_2", align=N), position=point(firstcut(V2--V2_tf1, U1--U2).after, .5));


draw(T1_tf1--T2_tf1);
drawMyArrowHead(
    extension(T1_tf1, T2_tf1, (0, 0), right)
    --extension(T1_tf1, T2_tf1, V2_tf1, shift(right) * V2_tf1),
    position=.75
);
draw(U1_tf1--U2_tf1);
drawMyArrowHead(V1_tf1--extension(V1_tf1, V2_tf1, (0, 0), right), position=.75);
draw(V1_tf1--V2_tf1);
drawMyArrowHead(U1_tf1--extension(U1_tf1, U2_tf1, (0, 0), right), position=.75);

draw(T1_tf1--U1_tf1--V1_tf1--cycle, p=linewidth(baselinewidth));
draw(
    T1_tf1--shiftParallel(H1_tf1 - T1_tf1, 3 * fontsize) * H1_tf1,
    L=MyLabel("\bar{h}₁", position=1, align=E)
);

draw(T2_tf1--U2_tf1--V2_tf1--cycle, p=linewidth(baselinewidth));
markangle(
    L=MyLabel("α"),
    shift(right) * V2_tf1, V2_tf1, U2_tf1,
    radius=length(T2_tf1 - V2_tf1) / 3
);

draw(T1_tf1--T1_tf2);
// working part of path
path wp = firstcut(firstcut(T1_tf1--T1_tf2, U1_tf1--U2_tf1).after, V1_tf2--V2_tf2).before;
drawMyArrowHead(wp, position=.75);
label(MyLabel("Δ^T_1", align=S), position=point(wp, .5));

draw(
    U1_tf1--U1_tf2,
    arrow=MyArrow(position=.5),
    L=MyLabel("Δ^U_1", position=.4, align=S)
);

draw(V1_tf1--V1_tf2);
path wp = firstcut(V1_tf1--V1_tf2, U1_tf1--U2_tf1).after;
drawMyArrowHead(wp, position=.5);
label(MyLabel("Δ^V_1", align=N), position=point(wp, .35));

draw(H1_tf1--H1_tf2);
drawMyArrowHead(firstcut(H1_tf1--H1_tf2, U1_tf1--U2_tf1).after, position=.5);


draw(T2_tf2--T1_tf2);
drawMyArrowHead(T2_tf2--extension(T1_tf2, T2_tf2, (0, 0), right), position=.75);
draw(U1_tf2--U2_tf2);
drawMyArrowHead(U2_tf2--extension(U1_tf2, U2_tf2, (0, 0), right), position=.75);
draw(V1_tf2--V2_tf2);
drawMyArrowHead(V2_tf2--extension(V1_tf2, V2_tf2, (0, 0), right), position=.75);

draw(T1_tf2--U1_tf2--V1_tf2--cycle, p=linewidth(baselinewidth));
draw(T1_tf2--H1_tf2, L=MyLabel("\Bar{h}₁", position=.6, align=W));
pair pFrom = point(T1_tf2--point(U1_tf2--H1_tf2, .5), .5);
dot(pFrom, filltype=Fill, p=linewidth(baselinewidth));
drawExtensionLine(
    pFrom,
    angle=45,
    length=arclength(pFrom--extension(pFrom, pFrom + dir(45), T1_tf2, U1_tf2)) + fontsize,
    L=MyLabel("н.в.", align=N)
);

draw(T2_tf2--U2_tf2--V2_tf2--cycle, p=linewidth(baselinewidth));


dot(T1, L=MyLabel("T₁", align=W));
dot(U1, L=MyLabel("U₁", align=E));
dot(V1, L=MyLabel("V₁", align=SSW));
dot(H1, L=MyLabel("1₁", align=S));

dot(T2, L=MyLabel("T₂", align=W));
dot(U2, L=MyLabel("U₂", align=N));
dot(V2, L=MyLabel("V₂", align=SW));
dot(H2, L=MyLabel("1₂", align=.4SE));

dot(T1_tf1, L=MyLabel("\bar{T}₁", align=W));
dot(U1_tf1, L=MyLabel("\bar{U}₁", align=S));
dot(V1_tf1, L=MyLabel("\bar{V}₁", align=W));
dot(H1_tf1, L=MyLabel("\bar{1}₁", align=SW));

Label T2_tf1_lbl = MyLabel("\bar{1}₂ ≡ (\bar{T}₂)", align=ESE);
unfill(
    shift(T2_tf1) * box(
        shift(.2 * fontsize * down) * shift(.5 * width(texpath(T2_tf1_lbl)) * right)
        * min(texpath(T2_tf1_lbl)),
        shift(.5 * fontsize * right)
        * max(texpath(T2_tf1_lbl))
    )
);
dot(T2_tf1, L=T2_tf1_lbl);
dot(U2_tf1, L=MyLabel("\bar{U}₂", align=N));
dot(V2_tf1, L=MyLabel("\bar{V}₂", align=SW));

dot(T1_tf2, L=MyLabel("\Bar{T}₁", align=E));
dot(U1_tf2, L=MyLabel("\Bar{U}₁", align=S));
dot(V1_tf2, L=MyLabel("\Bar{V}₁", align=NW));
dot(H1_tf2, L=MyLabel("\Bar{1}₁", align=NE));

dot(T2_tf2, L=MyLabel("\Bar{1}₂ ≡ (\Bar{T}₂)", align=N));
dot(U2_tf2, L=MyLabel("\Bar{U}₂", align=N));
dot(V2_tf2, L=MyLabel("\Bar{V}₂", align=N));

draw(
    max(currentpicture).x * right
    --shiftParallel(left, fontsize) * (min(currentpicture).x * right),
    L=MyLabel("X₁₂", position=EndPoint, align=N), arrow=MyArrow
);
