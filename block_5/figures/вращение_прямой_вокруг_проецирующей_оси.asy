string wd = cd("./");
cd("../..");
import env;
cd(wd);

real
figwidth = .5 * textwidth,
figheight = .3 * textheight;

real
x = figwidth,
y = .5 * figheight,
z = figheight - y;

triple Xm = scale3(x) * X;

triple
A = (.8x, .65y, .35z),
B = (.55x, .3y, .7z);
path3 q = shiftParallel(A - B, 3 * fontsize) * A--shiftParallel(B - A, 3 * fontsize) * B;

real
A_t = arctime(q, length(A - point(q, 0))),
B_t = arctime(q, length(B - point(q, 0)));

path3 q_tf1 = rotate(-longitude(dir(q)), B, B + Z) * q;
triple A_tf1 = point(q_tf1, A_t);

path3 q_tf2 = rotate(-colatitude(dir(q_tf1)), A_tf1, A_tf1 + Y) * q_tf1;
triple B_tf2 = point(q_tf2, B_t);

path3
i = planeproject(-Z) * B--shiftParallel(Z, 3 * fontsize) * B,
j = planeproject(-Y) * A_tf1--shiftParallel(Y, 4 * fontsize) * A_tf1;

picture[] pictures = {new picture, new picture};
projection[] projections = {TopView, FrontView};
triple[][] labeldirs = {{-X, -Y}, {-X, Z}};

picture curpic;
projection curproj;
triple[] curlbldirs;

for (int ix = 0; ix < 2; ++ix) {
    curpic = pictures[ix];
    curproj = projections[ix];
    curlbldirs = labeldirs[ix];

    draw(curpic, q, p=linewidth(baselinewidth));
    draw(curpic, q_tf1, p=linewidth(baselinewidth));
    draw(curpic, q_tf2, p=linewidth(baselinewidth));

    path3 A_rotmark = A{cross(dir(q), Z)}..A_tf1;
    draw(curpic, A_rotmark);

    Label CurLabel(string s, bool sl=true, align align=NoAlign) {
        return project(
            MyLabel(s=s, sl=sl, align=align),
            curlbldirs[0], curlbldirs[1], P=curproj
        );
    }

    if (ix == 0) {
        draw(curpic, O--Xm);
        drawMyArrowHead3(curpic, O--Xm, normal=Z);
        label(curpic, CurLabel("X₁₂", align=-Y - .5X), position=Xm);

        label(curpic, CurLabel("A₁", align=-Y + X), position=A);
        draw(curpic, A--planeproject(-Y) * A);
        label(curpic, CurLabel("B₁ ≡ i₁ ≡ \bar{B}₁", align=Y - .8X), position=B);
        label(curpic, CurLabel("q₁", align=X), position=point(q, 0));

        draw(curpic, B--planeproject(-Y) * B);

        label(curpic, CurLabel("Δ₁ ≡ \bar{q}₁", align=-Y + .25X), position=point(q_tf1, 1));

        label(curpic, CurLabel("\bar{A}₁ ≡ \Bar{B}₁ ≡ (\Bar{A}₁)", align=-X - Y), position=A_tf1);

        drawMyArrowHead3(curpic, A_rotmark, position=.5);

        path3 Rline = B--rotate(30, B, B + Z) * A;
        draw(curpic, Rline);
        drawMyArrowHead3(curpic, Rline, normal=Z);
        label(curpic, CurLabel("R_A", align=-Y + .6X), position=point(Rline, .8));

        draw(curpic, j);
        label(curpic, CurLabel("j₁", align=-X - .25Y), position=point(j, 1));
    }
    else if (ix == 1) {
        label(curpic, CurLabel("A₂", align=Z + X), position=A);
        draw(curpic, A--planeproject(-Z) * A);
        label(curpic, CurLabel("B₂ ≡ \bar{B}₂", align=4X), position=B);
        label(curpic, CurLabel("q₂", align=Z + .5X), position=point(q, 0));
        draw(curpic, i);
        label(curpic, CurLabel("i₂", align=-X + .25Z), position=point(i, 1));

        drawMyArrowHead3(curpic, A_rotmark, normal=Y, position=.6);
        label(curpic, CurLabel("Σ₂", align=Z), position=point(A_rotmark, .3));
        label(curpic, CurLabel("\bar{q}₂", align=Z), position=point(q_tf1, 1));
        label(curpic, CurLabel("\bar{A}₂ ≡ j ≡ \Bar{A}₂", align=-X + .6Z), position=A_tf1);

        path3 B_rotmark = B{cross(dir(q_tf1), Y)}..B_tf2;
        draw(curpic, B_rotmark);
        drawMyArrowHead3(curpic, B_rotmark, position=.75);
        path3 Rline = A_tf1--point(B_rotmark, .5);
        draw(curpic, Rline);
        drawMyArrowHead3(curpic, Rline, normal=Y);
        label(curpic, CurLabel("R_B", align=-X + .25Z), position=point(Rline, .75));

        draw(curpic, A_tf1--planeproject(-Z) * A_tf1);

        dot(curpic, B_tf2, L=CurLabel("\Bar{B}₂", align=-X));
        label(curpic, L=CurLabel("\Bar{q}₂", align=-X), position=point(A_tf1--B_tf2, .5));
    }

    dot(curpic, A);
    dot(curpic, B);
    dot(curpic, A_tf1);
}

add(rotate(180) * pictures[0].fit(projections[0]));
add(reflect((0, 0), (0, 1)) * pictures[1].fit(projections[1]));
