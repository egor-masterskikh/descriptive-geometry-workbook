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
    real angle=0, // угол выноса
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

void drawExtensionLine(pair pFrom, real angle=0, real length, int bardir=1, Label L="") {
    path line = ExtensionLine(pFrom, angle, length, bardir, L);
    draw(line);
    label(L, position=point(line, 1.5), align=N);
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
