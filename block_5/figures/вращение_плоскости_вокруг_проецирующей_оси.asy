string wd = cd("./");
cd("../..");
import env;
cd(wd);

projection[] projections = {TopView, FrontView};
triple[][] labeldirs = {{-X, -Y}, {-X, Z}};

real
figwidth = .7 * textwidth,
figheight = .35 * textheight;

real
x = figwidth,
y = .6 * figheight,
z = figheight - y;

triple Xm = scale3(x) * X;

triple
L = (.95x, .7y, .9z),
M = (.45x, .3y, .5z),
N = (.65x, .15y, .25z),
H = findPoint(L, N, z=M.z);

path3 Psi = L--M--N--cycle;

path3 i = (
    planeproject(-Z) * M--shiftParallel(
        Z, length(planeproject(X) * planeproject(-Y) * (L - M)) + 2 * fontsize
    ) * M
);

real H_t = intersections(Psi, M--H)[1][0];

path3 Psi_tf1 = rotate(
    -longitude(point(i, 0) - H) - 90,
    point(i, 0), point(i, 1)
) * Psi;
triple
L_tf1 = point(Psi_tf1, 0),
M_tf1 = point(Psi_tf1, 1),
N_tf1 = point(Psi_tf1, 2),
H_tf1 = point(Psi_tf1, H_t);

path3 j = planeproject(-Y) * L_tf1--shiftParallel(Y, 3 * fontsize) * L_tf1;

path3 Psi_tf2 = rotate(-colatitude(normal(Psi_tf1)) + 180, point(j, 0), point(j, 1)) * Psi_tf1;
triple
L_tf2 = point(Psi_tf2, 0),
M_tf2 = point(Psi_tf2, 1),
N_tf2 = point(Psi_tf2, 2),
H_tf2 = point(Psi_tf2, H_t);

path3
h = M--shiftParallel(H - M, abs((L - H).x) + 2 * fontsize) * H,
h_tf1 = M_tf1--shiftParallel(H_tf1 - M_tf1, 3.5 * fontsize) * H_tf1,
h_tf2 = M_tf2--shiftParallel(H_tf2 - M_tf2, 3.5 * fontsize) * H_tf2;

path3
L_rotmark1 = arc(i, L, L_tf1),
M_rotmark1 = arc(i, M, M_tf1),
N_rotmark1 = arc(i, N, N_tf1),
H_rotmark1 = arc(i, H, H_tf1),
L_rotmark2 = arc(j, L_tf1, L_tf2),
M_rotmark2 = arc(j, M_tf1, M_tf2),
N_rotmark2 = arc(j, N_tf1, N_tf2),
H_rotmark2 = arc(j, H_tf1, H_tf2);

triple[] points = {L, M, N, H, L_tf1, M_tf1, N_tf1, H_tf1, L_tf2, M_tf2, N_tf2, H_tf2};
path3[] rotmarks = {
    L_rotmark1, M_rotmark1, N_rotmark1, H_rotmark1,
    L_rotmark2, M_rotmark2, N_rotmark2, H_rotmark2
};

picture[] pictures = {new picture, new picture};

picture curpic;
projection curproj;
triple[] curlbldirs;
for (int proj_i = 0; proj_i < 2; ++proj_i) {
    curpic = pictures[proj_i];
    curproj = projections[proj_i];
    curlbldirs = labeldirs[proj_i];

    for (var curplane : new path3[] {Psi, Psi_tf1, Psi_tf2})
        draw(curpic, curplane, p=linewidth(baselinewidth));

    for (var curh : new path3[] {h, h_tf1, h_tf2})
        draw(curpic, curh);

    for (var p : points)
        draw(curpic, p--planeproject(projections[(proj_i + 1) % 2].normal) * p);

    draw(curpic, i);
    draw(curpic, j);

    for (var rotmark : rotmarks)
        draw(curpic, rotmark);

    Label CurLabel(string s, bool sl=true, align align=NoAlign, filltype filltype=NoFill) {
        return project(
            MyLabel(s=s, sl=sl, align=align, filltype=filltype),
            curlbldirs[0], curlbldirs[1], P=curproj
        );
    }

    if (proj_i == 0) {
        draw(curpic, O--Xm);
        drawMyArrowHead3(curpic, O--Xm, normal=Z);
        label(curpic, CurLabel("X₁₂", align=-Y), position=Xm);

        drawMyArrowHead3(curpic, L_rotmark1, position=.5);
        drawMyArrowHead3(curpic, position=.5, subpath(
            N_rotmark1,
            intersect(project(N_rotmark1, curproj), project(L--M, curproj))[0],
            length(N_rotmark1)
        ));
        drawMyArrowHead3(curpic, position=.5, subpath(
            H_rotmark1,
            intersect(project(H_rotmark1, curproj), project(L--M, curproj))[0],
            length(H_rotmark1)
        ));

        label(curpic, CurLabel("L₁", align=X), position=L);
        label(curpic, position=M, CurLabel(
            "M₁ ≡ i₁ ≡ \bar{M}₁", align=-Y - X, filltype=UnFill(xmargin=.1 * fontsize)
        ));
        label(curpic, CurLabel("N₁", align=X - .5Y), position=N);
        label(curpic, CurLabel("1₁", align=X - .75Y), position=H);
        label(curpic, CurLabel("h₁", align=-.75Y - .5X), position=point(h, 1));

        label(curpic, CurLabel("\bar{L}₁ ≡ \Bar{L}₁", align=-X + .5Y), position=L_tf1);
        label(curpic, CurLabel("\bar{N}₁", align=X + .75Y), position=N_tf1);
        label(curpic, CurLabel("\bar{1}₁", align=X + .8Y), position=H_tf1);
        label(curpic, CurLabel("\bar{h}₁", align=-.5X), position=point(h_tf1, 1));

        label(curpic, CurLabel("j₁", align=X), position=point(j, 1));

        drawMyArrowHead3(curpic, normal=Z, position=.4, subpath(
            M_rotmark2,
            intersect(project(M_rotmark2, curproj), project(j, curproj))[0],
            length(M_rotmark2)
        ));
        drawMyArrowHead3(curpic, normal=Z, position=.6, subpath(
            N_rotmark2,
            intersect(project(N_rotmark2, curproj), project(j, curproj))[0],
            intersect(project(N_rotmark2, curproj), project(L_tf2--M_tf2, curproj))[0]
        ));
        drawMyArrowHead3(curpic, normal=Z, position=.75, subpath(
            H_rotmark2,
            intersect(project(H_rotmark2, curproj), project(j, curproj))[0],
            intersect(project(H_rotmark2, curproj), project(L_tf2--M_tf2, curproj))[0]
        ));

        label(curpic, CurLabel("\Bar{M}₁", align=-.5Y - X), position=M_tf2);
        label(curpic, CurLabel("\Bar{N}₁", align=-X), position=N_tf2);
        label(curpic, CurLabel("\Bar{1}₁", align=-X + .5Y), position=H_tf2);
        label(curpic, CurLabel("\Bar{h}₁", align=X), position=point(h_tf2, 1));

        path3 line = point(h_tf2, intersect(
            project(h_tf2, curproj), project(N_tf1--N_tf2, curproj)
        )[0])--point(N_tf2--H_tf2, .5);
        triple pFrom = point(line, .6);
        extdot(curpic, pFrom);
        drawExtensionLine(
            curpic, pFrom, angle=-45, barvec=-X,
            length=arclength(project(line, curproj)), L=CurLabel("н.в.", align=-Y)
        );
    }
    else if (proj_i == 1) {
        drawMyArrowHead3(curpic, L_rotmark1, normal=Y, position=.5);
        drawMyArrowHead3(curpic, N_rotmark1, normal=Y, position=.9);
        drawMyArrowHead3(curpic, H_rotmark1, normal=Y, position=.6);

        label(curpic, CurLabel("L₂", align=X), position=L);

        real M_extline_angle = 90 + .75 * colatitude(L - M);
        drawExtensionLine(
            curpic, M, angle=M_extline_angle,
            length=abs(
                (length(planeproject(-X) * planeproject(-Y) * (L - M)) + 2 * fontsize)
                / Sin(M_extline_angle)
            ),
            barvec=-X, normal=Y,
            L=CurLabel("M₂ ≡ \bar{1}₂ ≡ \bar{M}₂", align=Z)
        );

        label(curpic, CurLabel("N₂", align=X - .5Z), position=N);
        label(curpic, CurLabel("1₂", align=-Z + .75X), position=H);
        label(curpic, CurLabel("h₂", align=Z - .5X), position=point(h, 1));

        label(curpic, CurLabel("i₂", align=X - .25Z), position=point(i, 1));

        label(curpic, CurLabel("\bar{L}₂ ≡ j₂ ≡ \Bar{L}₂", align=Z), position=L_tf1);
        label(curpic, CurLabel("\bar{N}₂", align=-Z + .75X), position=N_tf1);

        triple L1_tf1 = planeproject(-Z) * L_tf1;
        drawMyArrowHead3(curpic, normal=Y, position=.5, subpath(
            M_rotmark2,
            intersect(project(M_rotmark2, curproj), project(L_tf1--L1_tf1, curproj))[0],
            length(M_rotmark2)
        ));
        triple M1_tf2 = planeproject(-Z) * M_tf2;
        drawMyArrowHead3(curpic, normal=Y, position=.5, subpath(
            N_rotmark2,
            intersect(project(N_rotmark2, curproj), project(M_tf2--M1_tf2, curproj))[0],
            length(N_rotmark2)
        ));

        label(curpic, CurLabel("\Bar{1}₂ ≡ (\Bar{M}₂)", align=Z - .25X), position=M_tf2);
        label(curpic, CurLabel("\Bar{N}₂", align=-X), position=N_tf2);
    }

    for (var p : points)
        dot(curpic, p);
}

add(rotate(180) * pictures[0].fit(projections[0]));
add(reflect((0, 0), up) * pictures[1].fit(projections[1]));
