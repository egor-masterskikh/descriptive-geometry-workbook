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
S = (.86x, .46y, .23z),
T = (.73x, .13y, .85z),
U = (.26x, .15y, .4z),
H = findPoint(T, U, z=S.z);

triple h_dir = unit(H - S);
path3 h = S--H;

triple T_proj = planeproject(Z, O=H) * T;
triple cO = planeproject(rotate(90, Z) * h_dir, O=H) * T_proj;
triple T_tf = rotate(180 - abs(latitude(T - cO)), cO, H) * T;
triple T_tilde = rotate(-90, cO, T_proj) * T;

triple U_proj = planeproject(Z, O=H) * U;
triple U_tf = (
    planeproject(n=rotate(90, Z) * (H - T_tf), O=H, dir=rotate(90, Z) * h_dir)
    * U_proj
);
triple cO_tmp = intersectionpoint(U_proj--U_tf, h);

path3 h_extline = H--shiftParallel(H - cO, 2 * fontsize) * H;

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

    for (var p: new triple[] {T, U, H, cO})
        draw(curpic, p--planeproject(projections[(proj_i + 1) % 2].normal) * p);

    CurLabel = getCurLabel(curlbldirs[0], curlbldirs[1], P=curproj);

    if (proj_i == 0) {
        draw(curpic, O--Xm);
        drawMyArrowHead3(curpic, O--Xm, normal=Z);
        label(curpic, CurLabel("X₁₂", align=-Y - .5X), position=Xm);
        // draw(curpic, O--Ym);

        label(curpic, CurLabel("T₁", align=-.5Y + .5X), position=T);
        label(curpic, CurLabel("U₁", align=-.5X - .5Y), position=U);
        label(
            curpic,
            CurLabel("h₁", align=.5 * (rotate(90, Z) * h_dir)),
            position=point(h_extline, 1)
        );
        label(curpic, CurLabel("1₁", align=Y), position=H);
        drawExtensionLine(
            curpic, cO, barvec=-X, length=3 * fontsize,
            angle=1.6 * (longitude(bisector(T_tf - cO, H - cO)) - 180),
            L=CurLabel("O₁", align=-.25Y)
        );

        drawMyArrowHead3(curpic, cO--T_tf, normal=Z, position=.5);

        draw(curpic, T--T_proj);

        path3 SigmaT_extline = T_tf--shiftParallel(T_tf - cO, 3 * fontsize) * T_tf;
        draw(curpic, SigmaT_extline);
        label(
            curpic,
            CurLabel("Σ^T_1", align=.5 * (rotate(90, Z) * unit(T_tf - cO))),
            position=relpoint(SigmaT_extline, 1)
        );

        draw(curpic, cO--T_proj--T_tilde--cycle);
        perpendicular(curpic, T_tf, cO, S);
        perpendicular(curpic, cO, T_proj, T_tilde);
        // label(
        //     curpic,
        //     rotate(longitude(T - cO) + 90)
        //     * CurLabel("R^T_1", align=.5 * unit(T_tilde - T_proj)),
        //     position=point(cO--T_proj, .55)
        // );
        label(
            curpic,
            CurLabel("R^T", align=.75 * (rotate(-90, Z) * unit(T_tilde - cO))),
            position=point(cO--T_tilde, .58)
        );
        label(
            curpic,
            rotate(longitude(T_tilde - T))
            * CurLabel("δZ_{OT}", align=.5 * unit(T_proj - cO)),
            position=point(T_proj--T_tilde, .5)
        );

        path3 S_projline = S--planeproject(Y) * S;
        draw(curpic, subpath(S_projline, 0, .6 * intersect(S_projline, cO--T_tilde)[0]));

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

        draw(curpic, S--T_tf--U_tf--cycle, p=linewidth(baselinewidth));

        label(curpic, CurLabel("\tilde{T}", align=X), position=T_tilde);
        label(
            curpic,
            CurLabel("\bar{T}₁", align=1.5 * bisector(T_tf - cO, H - T_tf)),
            position=T_tf
        );
        label(
            curpic,
            CurLabel("\bar{U}₁", align=1.25 * bisector(H - U_tf, U_tf - cO_tmp)),
            position=U_tf
        );

        path3 SigmaU_extline = U_tf--shiftParallel(U_tf - cO_tmp, 3 * fontsize) * U_tf;
        draw(curpic, SigmaU_extline);
        label(
            curpic,
            CurLabel("Σ^U_1", align=.5 * (rotate(90, Z) * unit(U_tf - cO_tmp))),
            position=relpoint(SigmaU_extline, 1)
        );

        triple pFrom = point(
            intersectionpoint(S--U_tf, cO--T_tf)--point(T_tf--U_tf, .5), .75
        );
        extdot(curpic, pFrom);
        drawExtensionLine(
            curpic, pFrom, barvec=-X, angle=-45, length=3.5 * fontsize,
            L=CurLabel("н.в.", align=-.75Y)
        );

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
        label(curpic, CurLabel("O₂", align=-.5Z -.5X), position=cO);

        draw(curpic, subpath(S--planeproject(Z) * S, 0, .75));

        drawDimLine(
            curpic, S, T, distance=3.5 * fontsize,
            normal=rotate(longitude(T - S), Z) * Y,
            angle=180 + latitude(T - S),
            L=rotate(-90) * CurLabel("δZ_{OT}", align=.5X), position=.5
        );
        label(
            curpic,
            CurLabel("R^T_2", align=rotate(90, Y) * unit(cO - T)),
            position=point(T--cO, .55)
        );
    }

    for (var p: new triple[] {S, T, U, H, cO})
        dot(curpic, p);
}

add(rotate(180) * pictures[0].fit(projections[0]));
add(reflect((0, 0), up) * pictures[1].fit(projections[1]));
