import three;
import markers;
import geometry;

settings.render = 0;
settings.outformat = "pdf";
settings.tex = "lualatex";

texpreamble(
"""
\usepackage{calc}
\usepackage{stackengine}

\newlength{\realfsize}  % реальный размер шрифта
\setlength{\realfsize}{3.5mm}
\newcommand\fsizefactor{1.57}
\newlength{\fsize}
\setlength{\fsize}{\realfsize * \real\fsizefactor}

% luaotfload
\font\gostrm = name:gost230481typea at \fsize
\font\gostsl = name:gost230481typeaslanted at \fsize
\font\gostsls = name:gost230481typeaslanted at .7\fsize  % script size

\renewcommand\bar[1]{\stackinset{c}{0pt}{b}{.75mm}{¯}{#1}}

\newcommand\Bar[1]{\stackinset{c}{0pt}{b}{1.25mm}{¯}{\bar{#1}}}

\renewcommand\tilde[1]{\stackinset{c}{0pt}{b}{.75mm}{˜}{#1}}
"""
);

// Convert string "<real><unit>" to real pt
real pt(string s) {
    string unit = substr(s, pos=length(s) - 2);
    real val = (real)replace(s, before=unit, after="");

    if (unit == "mm") val *= 2.84528;

    return val*pt;
}

real
defaulttextwidth = 160mm,
defaulttextheight = 250mm;

real
textwidth = defaulttextwidth,
textheight = defaulttextheight;

// Считываем размеры текстовой области документа
file fin = input("textarea.txt");
string line;
string[] keyval;
string key, val;
while (!eof(fin)) {
    line = fin;  // считываем строку
    keyval = split(line, delimiter="=");
    if (keyval.length != 2) continue;

    key = keyval[0]; val = keyval[1];
    if (key == "textwidth")
        textwidth = pt(val);
    else if (key == "textheight")
        textheight = pt(val);
}

real
baselinewidth = .5mm,
thinlinewidth = .4 * baselinewidth;

defaultpen(thinlinewidth);
dotfactor = (1mm + linewidth()) / linewidth();
dotfilltype = UnFill;

real fontsize = 3.5mm;
real perpmarksize = 2.5mm;


/* Аналог типа pair, расширенный методом set().
 * Благодаря методу set() возможно перезаписать данные объекта без его уничтожения.

 * С использованием встроенного pair:

 pair A = (0, 0), B = (1, 1);
 pair[] ps = {A, B};
 ps[0] = (1, 0);
 write(A == ps[0]);  // false

 * С использованием Pair:

 Pair A = Pair(0, 0), B = Pair(1, 1);
 Pair[] ps = {A, B};
 ps[0].set(1, 0);
 write(A == ps[0]);  // true
 */
struct Pair {
    real x, y;

    void operator init(pair p) { this.x = p.x; this.y = p.y; }

    void operator init(real x, real y) { this.x = x; this.y = y; }

    void set(pair p) { this.x = p.x; this.y = p.y; }

    void set(real x, real y) { this.x = x; this.y = y; }
}

pair operator cast(Pair p) { return (p.x, p.y); }

path operator --(Pair p1, Pair p2) { return (pair)p1--(pair)p2; }

path operator --(Pair p1, pair p2) { return (pair)p1--p2; }

path operator --(pair p1, Pair p2) { return p1--(pair)p2; }

path operator --(path p1, Pair p2) { return p1--(pair)p2; }

Pair operator -(Pair p1, Pair p2) { return Pair((pair)p1 - (pair)p2); }

Pair operator *(transform tf, Pair p) { return Pair(tf * (pair)p); }

Pair unit(Pair p) { return Pair(unit((pair)p)); }

Pair realmult(Pair p1, Pair p2) { return Pair(realmult((pair)p1, (pair)p2)); }

real dot(Pair p1, Pair p2) { return dot((pair)p1, (pair)p2); }

real cross(Pair p1, Pair p2) { return cross((pair)p1, (pair)p2); }


struct Pairs {
    Pair[] arr;

    void operator init(... Pair[] arr) { this.arr = arr; }

    void operator init(Pair[] arr) { this.arr = arr; }

    int length() { return this.arr.length; }

    Pair get(int i) { return this.arr[i]; }
}

void operator *(transform tf, Pairs ps) {
    for (int i = 0; i < ps.length(); ++i)
        ps.get(i).set(tf * ps.get(i));
}

Pair[] operator cast(Pairs ps) { return ps.arr; }


real ahsize = 3.5mm;
real ahangle = 10;
real ahwidth = 2 * ahsize * Sin(ahangle);

arrowbar MyArrow(
    position position=EndPoint, filltype filltype=null,
    real size=ahsize, real angle=ahangle
) { return Arrow(SimpleHead, size, angle, filltype, position); }

arrowbar MyArrow = MyArrow();

path MyArrowHead(
    path g, position position=EndPoint,
    pen p=currentpen,
    real size=ahsize, real angle=ahangle
) { return SimpleHead.head(g, position, p, size, angle); }

void drawMyArrowHead(
    picture pic=currentpicture,
    path g, position position=EndPoint,
    pen p=currentpen,
    real size=ahsize, real angle=ahangle
) { draw(pic, MyArrowHead(g, position, p, size, angle)); }


path3 MyArrowHead3(
    path3 g, triple normal=normal(g), real position=1,
    real size=ahsize, real angle=ahangle
) {
    position = reltime(g, position);
    path3 r = subpath(g, position, 0);
    triple x = point(r, 0);
    real t = arctime(r, size);
    path3 left = rotate(-angle, x, x + normal) * r;
    path3 right = rotate(angle, x, x + normal) * r;
    return subpath(left, t, 0)--subpath(right, 0, t);
}

void drawMyArrowHead3(
    picture pic=currentpicture,
    path3 g, triple normal=normal(g), real position=1,
    real size=ahsize, real angle=ahangle
) { draw(pic, MyArrowHead3(g, normal, position, size, angle)); }


Label MyLabel(
    string s,
    bool sl=true,  // bool slanted
    string size="", position position=null,
    align align=NoAlign, pen p=nullpen,
    embed embed=Rotate, filltype filltype=NoFill
) {
    string fontcmd = "\gost" + (sl ? "sl" : "rm");
    // string res_s = fontcmd + " " + s;

    // parse string s
    string[] parts = {""};
    int cur_i = 0;
    bool mathmode = false;
    for (var ch : array(s)) {
        if (ch == "^" || ch == "_") {
            mathmode = true;
            parts[cur_i] = "{\hbox{" + parts[cur_i] + "}}" + ch;
            ++cur_i;
            parts.push(fontcmd + "s ");
        }
        else
            parts[cur_i] += ch;
    }
    parts[cur_i] = "{\hbox{" + parts[cur_i] + "}}";

    string res_s = operator +(... parts);
    if (mathmode)
        res_s = "$" + res_s + "$";
    res_s = fontcmd + " " + res_s;

    if (position == null)
        return Label(res_s, size, align, p, embed, filltype);
    else
        return Label(res_s, size, position, align, p, embed, filltype);
}


real stickmarkersize = 1.5mm;
real stickmarkerspace = .5mm;

marker StickMarker(
    int i=1, int n=1,
    real size=stickmarkersize, real space=stickmarkerspace,
    real angle=0, pair offset=0,
    bool rotated=true, pen p=currentpen,
    frame uniform=newframe, bool above=true
) { return StickIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }

real tildemarkersize = 1mm;

marker TildeMarker(
    int i=1, int n=1,
    real size=tildemarkersize, real space=0,
    real angle=0, pair offset=0,
    bool rotated=true, pen p=currentpen,
    frame uniform=newframe, bool above=true
) { return TildeIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }

real crossmarkersize = 1mm;

marker CrossMarker(
    int i=1, int n=3,
    real size=crossmarkersize, real space=0,
    real angle=0, pair offset=0,
    bool rotated=true, pen p=currentpen,
    frame uniform=newframe, bool above=true
) { return CrossIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }


real width(path[] paths) { return (max(paths) - min(paths)).x; }

real height(path[] paths) { return (max(paths) - min(paths)).y; }


transform shiftParallel(pair vec, real distance) {
    return shift(scale(distance) * unit(vec));
}

transform3 shiftParallel(triple vec, real distance) {
    return shift(scale3(distance) * unit(vec));
}

transform shiftPerp(pair vec, real distance) {
    return shift(scale(distance) * rotate(90) * unit(vec));
}


// Найти точку на пространственной прямой AB, если задана какая-либо из её координат.
triple findPoint(triple A, triple B, real x=nan, real y=nan, real z=nan) {
    real t;  // параметр в уравнении прямой
    triple q = B - A;  // направляющий вектор
    if (!isnan(x) && isnan(y) && isnan(z))
        t = (x - A.x) / q.x;
    else if (!isnan(y) && isnan(x) && isnan(z))
        t = (y - A.y) / q.y;
    else if (!isnan(z) && isnan(x) && isnan(y))
        t = (z - A.z) / q.z;

    return A + q * t;
}

path ExtensionLine(
    pair pFrom,   // точка, от которой будет вынос
    real angle=45, // угол выноса
    real length,  // длина выносной линии
    int bardir=1, // направление полки относительно выносной линии (-1 или 1)
    Label L=""
) {
    frame f;
    label(f, L);
    real barwidth = (max(f) - min(f)).x;

    pair
    barvec = scale(barwidth * sgn(bardir)) * right,
    extvec = scale(length) * rotate(angle) * right;

    return pFrom--(pFrom + extvec)--(pFrom + extvec + barvec);
}

path3 ExtensionLine(
    triple pFrom, real angle=45,
    triple barvec=-X, triple normal=Z,
    real length, Label L=""
) {
    frame f;
    label(f, L);
    real barwidth = (max(f) - min(f)).x;

    barvec = scale3(barwidth) * unit(barvec);

    triple extvec = scale3(length) * rotate(angle, normal) * unit(barvec);

    return pFrom--(pFrom + extvec)--(pFrom + extvec + barvec);
}

void drawExtensionLine(pair pFrom, real angle=45, real length, int bardir=1, Label L="") {
    path line = ExtensionLine(pFrom, angle, length, bardir, L);
    draw(line);
    label(L, position=point(line, 1.5), align=N);
}

void drawExtensionLine(
    picture pic=currentpicture,
    triple pFrom, real angle=45,
    triple barvec=-X, triple normal=Z,
    real length, Label L=""
) {
    path3 line = ExtensionLine(pFrom, angle, barvec, normal, length, L);
    draw(pic, line);
    label(pic, L, position=point(line, 1.5));
}


/*
A, B -- координаты точек, от которых будет сделан вынос
normal -- нормаль к выносным линиям
angle -- угол, соответствующий направлению выноса относительно базовой линии
distance -- длина короткой выносной линии
*/
path3 DimLine(
    picture pic=currentpicture, 
    triple A, triple B, triple normal=Z,
    real angle=90, real distance
) {
    distance = abs(distance);

    triple
    shortExtLineVec = scale3(distance) * rotate(angle, normal) * unit(B - A),
    longExtLineVec = (
        scale3(1 + length(B - A) * abs(Cos(angle)) / length(shortExtLineVec))
        * shortExtLineVec
    ),
    dimLineVec = (
        scale3(length(B - A) * abs(Sin(angle))) * rotate(90, normal)
        * unit(shortExtLineVec)
    );

    path3
    shortExtLine = (
        shift(A) * scale3(1 + ahwidth / length(shortExtLineVec))
        * (O--shortExtLineVec)
    ),
    longExtLine = (
        shift(B) * scale3(1 + ahwidth / length(longExtLineVec))
        * (O--longExtLineVec)
    ),
    dimLine = shift(A + shortExtLineVec) * (O--dimLineVec);

    draw(pic, shortExtLine);
    draw(pic,longExtLine);

    return dimLine;
}

path3 drawDimLine(
    picture pic=currentpicture,
    triple A, triple B, triple normal=Z,
    real angle=90, real distance,
    Label L="", real position=.5
) {
    path3 dimLine = DimLine(pic=pic, A, B, normal=normal, angle=angle, distance=distance);
    draw(pic, dimLine);
    drawMyArrowHead3(pic, reverse(dimLine), normal=normal, position=1);
    drawMyArrowHead3(pic, dimLine, normal=normal, position=1);
    label(pic, L, position=point(dimLine, position));
    return dimLine;
}


struct Path3Part {
    path3 p;
    bool visible;

    void operator init(path3 p, bool visible=true) {
        this.p = p;
        this.visible = visible;
    }
}

path3 operator cast(Path3Part part) { return part.p; }

struct Path3 {
    Path3Part[] parts;

    void operator init(path3 p, path3 sf, projection P=currentprojection) {
        // моменты пересечения кривой с поверхностью и проекции кривой с проекцией поверхности
        real[][] times_ = transpose(intersections(p, surface(sf, planar=true)));
        real[] times;
        if (times_.length > 0) times = times_[0];

        real[][] projtimes_ = transpose(intersections(project(p), project(sf)));
        real[] projtimes;
        if (projtimes_.length > 0) projtimes = projtimes_[0];

        // добавляем момент пересечения проекции кривой и проекции поверхности
        // только если он не совпадает с моментом пересечения кривой с поверхностью
        bool unique;
        for (int j = 0; j < projtimes.length; ++j) {
            unique = true;
            for (int i = 0; i < times.length; ++i)
                if (times[i] == projtimes[j]) {
                    unique = false;
                    break;
                }
            if (unique) times.push(projtimes[j]);
        }

        times = sort(times);

        if (times[0] != 0) times.insert(0, 0);

        // проекционная линия (предполагается ортогональная проекция)
        path3 projline = (
            scale3(max(textwidth, textheight)) * shift(-P.normal / 2) * (O--P.normal)
        );

        real cur_t, next_t;

        for (int i = 0; i < times.length; ++i) {
            cur_t = times[i];
            next_t = (i != times.length - 1) ? times[i + 1] : length(p);

            // точка на кривой справа от точки пересечения
            triple p_rp = point(p, (cur_t + next_t) / 2);

            // точки на поверхности, соответствующие проекции точки p_rp
            triple[] sf_rps = intersectionpoints(
                shift(p_rp) * projline,
                surface(sf)
            );
            bool visible = true;  // флаг видимости точки p_rp

            if (sf_rps.length > 0) {
                // предполагается, что точка, соответствующая проекции точки p_rp, единственна для поверхности
                triple sf_rp = sf_rps[0];
                // P.normal направлена к наблюдателю
                visible = dot(sf_rp - p_rp, -P.normal) > 0;
            }

            this.parts.push(Path3Part(subpath(p, cur_t, next_t), visible));
        }
    }
}

pen gostdashed = linetype(new real[] {2mm, 1mm}, offset=-1mm, scale=false);

void draw(
    picture pic=currentpicture, Path3 g,
    light light=nolight, string name="",
    render render=defaultrender
) {
    for (Path3Part part : g.parts) {
        pen p = part.visible ? solid : gostdashed;
        draw(pic=pic, part, p=p, light=light, name=name, render=render);
    }
}

path3 arc(path3 axis, triple p1, triple p2) {
    return p1{cross(point(axis, 0) - p1, dir(axis))}..p2;
}

triple bisector(triple u, triple v) {
    return relpoint(arc(O, unit(u), unit(v)), .5);
}

void extdot(
    picture pic=currentpicture, triple v, material p=linewidth(baselinewidth),
    light light=nolight, string name="", render render=defaultrender
) {
    // копия определения функции dot из модуля three_surface.asy
    pen q = (pen)p;
    real size = .5 * linewidth(dotsize(q) + q);
    pic.add(new void(frame f, transform3 t, picture pic, projection P) {
        triple V = t * v;
        transform3 T = shift(v) * scale3(size);
        draw(f, T * unitsphere, p, light, name, render, P);
        if (pic != null)
            dot(
                pic, project(V, P.t), q,
                filltype=Fill  // локальное изменение типа заполнения
            );
    }, true);
    triple R = size * (1, 1, 1);
    pic.addBox(v, v, -R, R);
}

triple min(... triple[] ps) {
    triple min_p = (inf, inf, inf);
    for (var p : ps)
        if (length(p) < length(min_p)) min_p = p;
    return min_p;
}

projection[] projections = {TopView, FrontView};
triple[][] labeldirs = {{-X, -Y}, {-X, Z}};


typedef Label CurLabel(
    string s, bool sl=true, align align=NoAlign, filltype filltype=NoFill
);

CurLabel getCurLabel(triple lbldir1, triple lbldir2, projection P) {
    return new Label(
        string s, bool sl=true, align align=NoAlign, filltype filltype=NoFill
    ) {
        return project(
            MyLabel(s=s, sl=sl, align=align, filltype=filltype),
            lbldir1, lbldir2, P=P
        );
    };
}


void perpendicular(picture pic=currentpicture, triple A, triple B, triple C) {
    triple
    v1 = unit(A - B),
    v2 = unit(C - B);
    path3 perpmark = shift(B) * scale3(perpmarksize) * (v1--(v1 + v2)--v2);
    draw(pic, perpmark);
}
