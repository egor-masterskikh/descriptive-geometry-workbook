string wd = cd("./");
cd("../..");
import env;
cd(wd);

real
figwidth = .5 * textwidth,
figheight = .3 * textheight;

real
x = figwidth,
y = .7 * figheight,
z = figheight - y;

triple
Xm = scale3(x) * X,
Ym = scale3(y) * Y,
Zm = scale3(z) * Z;

triple
W = (.35x, .15y, .8z),
cO = (.5x, .55y, .2z);

triple
h_dir = unit(rotate(90, Z) * planeproject(Z) * (W - cO)),
h_start = min(
    planeproject(n=-X, O=Xm - 2 * fontsize * X, dir=-h_dir) * cO,
    planeproject(n=Y, O=Xm + fontsize * Y, dir=-h_dir) * cO
),
h_end = min(
    planeproject(n=X, O=Ym + fontsize * X, dir=h_dir) * cO,
    planeproject(n=-Y, O=Ym - fontsize * Y, dir=h_dir) * cO
);

path3 h = h_start--h_end;

triple W_tf = rotate(180 - latitude(W - cO), h_start, h_end) * W;

picture[] pictures = {new picture, new picture};

picture curpic;
projection curproj;
triple[] curlbldirs;
CurLabel CurLabel;

for (int proj_i = 0; proj_i < 2; ++proj_i) {
    curpic = pictures[proj_i];
    curproj = projections[proj_i];
    curlbldirs = labeldirs[proj_i];

    draw(curpic, h);
    draw(curpic, cO--W);
    draw(curpic, cO--W_tf);

    for (var p: new triple[] {W, cO, W_tf})
        draw(curpic, p--planeproject(projections[(proj_i + 1) % 2].normal) * p);

    CurLabel = getCurLabel(curlbldirs[0], curlbldirs[1], P=curproj);

    if (proj_i == 0) {
        draw(curpic, O--Xm);
        drawMyArrowHead3(curpic, O--Xm, normal=Z);
        label(curpic, CurLabel("X₁₂", align=-Y), position=Xm);

        label(curpic, CurLabel("W₁", align=-X - .5Y), position=W);
        label(
            curpic,
            CurLabel("h₁", align=.5 * (rotate(-90, Z) * h_dir)),
            position=point(h, 1)
        );
        label(curpic, CurLabel("O₁", align=bisector(W_tf - cO, -h_dir)), position=cO);
        perpendicular(curpic, W_tf, cO, h_start);
        
        triple
        W_tmp = rotate(90, W_tf, cO) * W,
        W_proj = planeproject(Z, O=cO) * W;
        draw(curpic, cO--W_proj);
        label(
            curpic,
            CurLabel("R^W_1", align=.01 * (rotate(90, Z) * dir(cO--W_proj))),
            position=point(cO--W_proj, .65)
        );
        draw(curpic, W_proj--W_tmp);
        perpendicular(curpic, cO, W_proj, W_tmp);
        drawExtensionLine(
            curpic, point(W_proj--W_tmp, .5), angle=45, barvec=-X, length=1.5 * fontsize,
            L=CurLabel("δZ_{WO}", align=-.5Y)
        );
        draw(curpic, cO--W_tmp);
        label(
            curpic,
            CurLabel("R^W", align=.01 * (rotate(90, Z) * dir(cO--W_tmp))),
            position=point(cO--W_tmp, .65)
        );
        path3 W_rotmark = arc(cO, W_tmp, W_tf);
        draw(curpic, W_rotmark);

        real[] W_rotmark_start_ = intersect(W_rotmark, h);
        real W_rotmark_start;
        if (W_rotmark_start_.length > 0)
            W_rotmark_start = W_rotmark_start_[0];
        else
            W_rotmark_start = 0;

        drawMyArrowHead3(
            curpic,
            subpath(W_rotmark, W_rotmark_start, length(W_rotmark)),
            position=.5
        );

        label(curpic, CurLabel("\bar{W}₁", align=X - .25Y), position=W_tf);
        label(
            curpic,
            CurLabel("Λ₁", align=.75 * (rotate(90, Z) * unit(cO - W_tf))),
            position=relpoint(cO--W_tf, .4)
        );

        dot(curpic, W_tmp, L=CurLabel("\tilde{W}", align=-X - .5Y));
    }
    else if (proj_i == 1) {
        label(curpic, CurLabel("W₂", align=Z), position=W);
        label(curpic, CurLabel("Σ₂ ≡ h₂", align=.75Z - .25X), position=relpoint(h, 0));
        label(curpic, CurLabel("O₂", align=Z + .5X), position=cO);
        triple W_proj = planeproject(Y, O=cO) * W;
        draw(curpic, cO--W_proj);
        label(
            curpic,
            CurLabel("R^W_2", align=.25 * (rotate(90, Y) * unit(W_proj - cO))),
            position=point(cO--W_proj, .6)
        );
        drawDimLine(
            curpic, W_proj, cO, normal=Y,
            angle=colatitude(W_proj - cO) + 90, distance=3 * fontsize,
            L=rotate(-90) * CurLabel("δZ_{WO}", align=.75X)
        );

        label(curpic, CurLabel("\bar{W}₂", align=Z), position=W_tf);
    }

    dot(curpic, W);
    dot(curpic, cO);
    dot(curpic, W_tf);
}

add(rotate(180) * pictures[0].fit(projections[0]));
add(reflect((0, 0), up) * pictures[1].fit(projections[1]));
