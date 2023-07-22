string wd = cd("./");
cd("../..");
import env;
cd(wd);

real
figwidth = .6 * textwidth,
figheight = .35 * textheight;

real
x = figwidth,
y = .65 * figheight,
z = figheight - y;

triple
Xm = scale3(x) * X,
Ym = scale3(y) * Y,
Zm = scale3(z) * Z;

triple
S = (.83x, .7y, .23z),
T = (.6x, .85y, .85z),
U = (.25x, .4y, .43z),
H = findPoint(T, U, z=S.z);

triple h_dir = unit(H - S);
path3 h = S--H;

triple T_proj = planeproject(Z, O=H) * T;
triple cO = planeproject(rotate(90, Z) * h_dir, O=H) * T_proj;
triple T_tf = rotate(180 - latitude(T - cO), H, cO) * T;
triple T_tilde = rotate(90, cO, T_proj) * T;

triple U_proj = planeproject(Z, O=H) * U;
triple U_tf = (
    planeproject(n=rotate(90, Z) * (H - T_tf), O=H, dir=rotate(90, Z) * h_dir)
    * U_proj
);
triple cO_tmp = intersectionpoint(U_proj--U_tf, h);

path3 h_extline = H--shiftParallel(H - cO, 2 * fontsize) * H;

triple[] points = {S, T, U, H, cO};

picture[] pictures = {new picture, new picture};

picture curpic;
projection curproj;
triple[] curlbldirs;
CurLabel CurLabel;

for (int proj_i = 0; proj_i < 2; ++proj_i) {
    curpic = pictures[proj_i];
    curproj = projections[proj_i];
    curlbldirs = labeldirs[proj_i];

    draw(curpic, S--T--U--cycle, p=linewidth(baselinewidth));
    draw(curpic, T--H);
    draw(curpic, h);
    draw(curpic, h_extline);
    draw(curpic, cO--T);
    draw(curpic, cO--T_tf);

    for (var p: points)
        draw(curpic, p--planeproject(projections[(proj_i + 1) % 2].normal) * p);

    CurLabel = getCurLabel(curlbldirs[0], curlbldirs[1], P=curproj);

    if (proj_i == 0) {
        draw(curpic, O--Xm);
        drawMyArrowHead3(curpic, O--Xm, normal=Z);
        label(curpic, CurLabel("X₁₂", align=-Y - .5X), position=Xm);
        // draw(curpic, O--Ym);

        label(curpic, CurLabel("T₁", align=1.75 * bisector(T_proj - cO, U - T)), position=T);
        label(curpic, CurLabel("U₁", align=-.5X + .5Y), position=U);
        label(curpic, CurLabel("1₁", align=Y), position=H);
        drawExtensionLine(
            curpic, cO, angle=-20, barvec=X, length=1.5 * fontsize,
            L=CurLabel("O₁", align=-.25Y)
        );

        drawMyArrowHead3(curpic, cO--T_tf, normal=Z, position=.5);

        draw(curpic, T--T_proj);

        path3 Sigma_extline = T_proj--shiftParallel(T_proj - cO, 3 * fontsize) * T_proj;
        draw(curpic, Sigma_extline);
        label(
            curpic,
            CurLabel("Σ^T_1", align=.75 * (rotate(100, Z) * dir(Sigma_extline))),
            position=relpoint(Sigma_extline, 1)
        );

        draw(curpic, cO--T_proj--T_tilde--cycle);
        perpendicular(curpic, T_proj, cO, H);
        perpendicular(curpic, cO, T_proj, T_tilde);
        label(
            curpic,
            rotate(longitude(cO - T_proj) + 90)
             * CurLabel("R^T_1", align=.01 * unit(T_tilde - T_proj)),
            position=point(cO--T_proj, .4)
        );
        label(
            curpic,
            CurLabel("R^T", align=.01 * (rotate(90, Z) * unit(cO - T_tilde))),
            position=point(cO--T_tilde, .7)
        );

        triple pFrom = point(T--T_tilde, .75);
        extdot(curpic, pFrom);
        drawExtensionLine(
            curpic, pFrom, angle=-60, barvec=-X, length=1.6 * fontsize,
            L=CurLabel("δZ_{OT}", align=-.5Y)
        );

        path3 T_rotmark = arc(cO, T_tilde, T_tf);
        draw(curpic, T_rotmark);
        drawMyArrowHead3(curpic, T_rotmark, position=.6);

        label(
            curpic,
            CurLabel("S₁ ≡ \bar{S}₁", align=X, filltype=UnFill(ymargin=.1 * fontsize)), 
            position=S
        );

        draw(curpic, T_tf--H);
        drawMyArrowHead3(curpic, T_tf--U_tf, normal=Z, position=.7);
        draw(curpic, U--U_proj);
        draw(curpic, U_proj--U_tf);
        drawMyArrowHead3(curpic, cO_tmp--U_tf, normal=Z, position=1);
        perpendicular(curpic, cO, cO_tmp, U_tf);

        label(
            curpic,
            CurLabel("h₁", align=.5 * (rotate(90, Z) * h_dir)),
            position=point(h_extline, 1)
        );

        draw(curpic, S--T_tf--U_tf--cycle, p=linewidth(baselinewidth));

        label(curpic, CurLabel("\tilde{T}", align=X + .5Y), position=T_tilde);
        label(curpic, CurLabel("\bar{T}₁", align=-.75Y), position=T_tf);
        label(curpic, CurLabel("\bar{U}₁", align=-.5Y), position=U_tf);

        dot(curpic, T_proj);
        dot(curpic, T_tilde);
        dot(curpic, T_tf);
        dot(curpic, U_tf);
    }
    else if (proj_i == 1) {
        // draw(curpic, O--Zm);
        label(curpic, CurLabel("S₂", align=.5X - .5Z), position=S);
        label(curpic, CurLabel("T₂", align=Z), position=T);
        label(curpic, CurLabel("U₂", align=Z - .5X), position=U);
        label(curpic, CurLabel("1₂", align=Z), position=H);
        label(curpic, CurLabel("h₂", align=.5Z), position=point(h_extline, 1));
        
        label(curpic, CurLabel("O₂", align=.5X - .5Z), position=cO);

        drawDimLine(
            curpic, S, T, distance=2.5 * fontsize,
            normal=rotate(longitude(T - S), Z) * Y,
            angle=180 - latitude(planeproject(Y, O=S) * T - S),
            L=rotate(-90) * CurLabel("δZ_{OT}", align=.5X), position=.5
        );
        label(
            curpic,
            CurLabel("R^T_2", align=.5 * (rotate(-90, Y) * unit(cO - T))),
            position=point(T--cO, .65)
        );
    }

    for (var p: points)
        dot(curpic, p);
}

add(rotate(180) * pictures[0].fit(projections[0]));
add(reflect((0, 0), up) * pictures[1].fit(projections[1]));
