string wd = cd("./");
cd("../../");
import env;
cd(wd);

real
figwidth = .8 * textwidth,
figheight = .27 * textheight;

real
x = figwidth / 3,
y = .4 * figheight,
z = figheight - y;

triple
D = (.7x, .85y, .2z),
E = (.15x, .2y, .45z);

Pair
D1 = Pair(project(D, TopView)),
D2 = Pair(project(D, FrontView)),
E1 = Pair(project(E, TopView)),
E2 = Pair(project(E, FrontView));

Pairs
plane1 = Pairs(D1, E1),
plane2 = Pairs(D2, E2);

E = rotate(-degrees(D1 - E1), (D.x, D.y, 0), D) * E;

Pair
D1_tf1 = Pair(project(D, TopView)),
D2_tf1 = Pair(project(D, FrontView)),
E1_tf1 = Pair(project(E, TopView)),
E2_tf1 = Pair(project(E, FrontView));

Pairs
plane1_tf1 = Pairs(D1_tf1, E1_tf1),
plane2_tf1 = Pairs(D2_tf1, E2_tf1);

E = rotate(degrees(E2_tf1 - D2_tf1) - 90, (D.x, 0, D.z), D) * E;

Pair
D1_tf2 = Pair(project(D, TopView)),
D2_tf2 = Pair(project(D, FrontView)),
E1_tf2 = Pair(project(E, TopView)),
E2_tf2 = Pair(project(E, FrontView));

Pairs
plane1_tf2 = Pairs(D1_tf2, E1_tf2),
plane2_tf2 = Pairs(D2_tf2, E2_tf2);


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
        shiftParallel(left, abs((D1 - E1).x) + 2.5 * fontsize) * planes[i];
    if (i # 2 >= 2)
        shiftParallel(left, abs((D1_tf1 - E1_tf1).x) + 4 * fontsize) * planes[i];
}

shiftPerp(D1_tf1 - E1_tf1, .4 * (E1 - D1).y) * plane1_tf1;
shiftPerp(D1_tf1 - E1_tf1, abs((D1_tf2 - D1_tf1).y)) * plane1_tf2;
shiftParallel(D2_tf2 - E2_tf2, D.z - fontsize) * plane2_tf2;

// отражение всех плоскостей относительно вертикали
for (int i = 0; i < planes.length; ++i)
    reflect((0, 0), N) * planes[i];


draw(D1--D2);
draw(E1--E2);

draw(D1--E1, p=linewidth(baselinewidth), marker=StickMarker());
draw(D2--E2, p=linewidth(baselinewidth));

draw(
    D2--shiftParallel(D2_tf1 - D2, abs((E2_tf1 - D2_tf1).x) + 2 * fontsize) * D2_tf1,
    L=MyLabel("Σ^D_2", position=EndPoint, align=NNW)
);
draw(
    E2--shiftParallel(E2_tf1 - E2, 2 * fontsize) * E2_tf1,
    L=MyLabel("Σ^E_2", position=EndPoint, align=NNW)
);

draw(D1_tf1--D2_tf1);
draw(E1_tf1--E2_tf1);

draw(D1_tf1--E1_tf1, p=linewidth(baselinewidth), marker=StickMarker());
draw(D2_tf1--E2_tf1, p=linewidth(baselinewidth), marker=TildeMarker(offset=fontsize));
extensionLine(
    point(D2_tf1--E2_tf1, .46), angle=135,
    length=abs((E2_tf1 - D2_tf1).y) + 2 * fontsize,
    L=MyLabel("н.в. DE")
);
markangle(L=MyLabel("α"), shift(D2_tf1) * right, D2_tf1, E2_tf1);

draw(
    E1_tf1--shiftParallel(E1_tf2 - E1_tf1, 3 * fontsize) * E1_tf2,
    L=MyLabel("Δ^{A,B}_1", position=EndPoint, align=NNW)
);

draw(E1_tf2--E2_tf2);

dot(D1_tf2);
draw(D2_tf2--E2_tf2, p=linewidth(baselinewidth), marker=TildeMarker());


dot(D1, L=MyLabel("D₁", align=S));
dot(E1, L=MyLabel("E₁", align=SSE));

dot(D2, L=MyLabel("D₂", align=NNW));
dot(E2, L=MyLabel("E₂", align=N));

dot(D1_tf1, L=MyLabel("\bar{D}₁", align=S));
dot(E1_tf1, L=MyLabel("\bar{E}₁", align=S));

dot(D2_tf1, L=MyLabel("\bar{D}₂", align=NNW));
dot(E2_tf1, L=MyLabel("\bar{E}₂", align=NNW));

dot(D1_tf2, L=MyLabel("\Bar{D}₁ ≡ \Bar{E}₁", align=S));

dot(D2_tf2, L=MyLabel("\Bar{D}₂", align=ENE));
dot(E2_tf2, L=MyLabel("\Bar{E}₂", align=plain.E));

draw(
    max(currentpicture).x * right
    --shiftParallel(left, fontsize) * (min(currentpicture).x * right),
    L=MyLabel("X₁₂", position=EndPoint, align=N), arrow=MyArrow
);
