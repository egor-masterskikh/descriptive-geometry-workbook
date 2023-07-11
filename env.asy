import three;
import markers;
import geometry;

settings.render = 0;
settings.outformat = "pdf";
settings.tex = "lualatex";

texpreamble(
"""
\usepackage{calc}

\newlength{\realfsize}  % реальный размер шрифта
\setlength{\realfsize}{3.5mm}
\newcommand\fsizefactor{1.57}
\newlength{\fsize}
\setlength{\fsize}{\realfsize * \real\fsizefactor}

% luaotfload
\font\gostrm = name:gost230481typea at \fsize
\font\gostsl = name:gost230481typeaslanted at \fsize
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
thinlinewidth = baselinewidth / 2;

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

    int length() { return this.arr.length; }

    Pair get(int i) { return this.arr[i]; }
}

void operator *(transform tf, Pairs ps) {
    for (int i = 0; i < ps.length(); ++i)
        ps.get(i).set(tf * ps.get(i));
}


arrowhead ahtype = SimpleHead;
real ahsize = 3.5mm;
real ahangle = 10;

arrowbar MyArrow(
    arrowhead arrowhead=ahtype,
    real size=ahsize,
    real angle=ahangle,
    real position=1
) { return Arrow(arrowhead, size, angle, position); }

arrowbar MyArrow = MyArrow();


Label MyLabel(
    string s,
    bool sl=true,  // bool slanted
    string size="", position position=(inf, inf),
    align align=NoAlign, pen p=nullpen,
    embed embed=Rotate, filltype filltype=NoFill
) {
    string res = "\gost" + (sl ? "sl" : "rm") + " " + s;
    if ((pair)position == (inf, inf))
        return Label(res, size, align, p, embed, filltype);
    else
        return Label(res, size, position, align, p, embed, filltype);
}


real stickmarkersize = 1.5mm;
real stickmarkerspace = .5mm;

marker StickMarker(
    int i=1, int n=1,
    real size=stickmarkersize,
    real space=stickmarkerspace,
    real angle=0,
    pair offset=0,
    bool rotated=true,
    pen p=currentpen,
    frame uniform=newframe,
    bool above=true
) { return StickIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }

real tildemarkersize = 1mm;

marker TildeMarker(
    int i=1, int n=1,
    real size=tildemarkersize,
    real space=0,
    real angle=0,
    pair offset=0,
    bool rotated=true,
    pen p=currentpen,
    frame uniform=newframe,
    bool above=true
) { return TildeIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }

real crossmarkersize = 1mm;

marker CrossMarker(
    int i=1, int n=3,
    real size=crossmarkersize,
    real space=0,
    real angle=0,
    pair offset=0,
    bool rotated=true,
    pen p=currentpen,
    frame uniform=newframe,
    bool above=true
) { return CrossIntervalMarker(i, n, size, space, angle, offset, rotated, p, uniform, above); }


// Return the pair (left, bottom) for the bounding box of paths.
pair min(path[] paths) {
    Pair glob_min, loc_min;
    for (var p : paths) {
        loc_min = Pair(min(p));
        if (loc_min.x < glob_min.x) glob_min.x = loc_min.x;
        if (loc_min.y < glob_min.y) glob_min.y = loc_min.y;
    }
    return (pair) glob_min;
}

// Return the pair (right, top) for the bounding box of paths.
pair max(path[] paths) {
    Pair glob_max, loc_max;
    for (var p : paths) {
        loc_max = Pair(max(p));
        if (loc_max.x > glob_max.x) glob_max.x = loc_max.x;
        if (loc_max.y > glob_max.y) glob_max.y = loc_max.y;
    }
    return (pair) glob_max;
}

real width(path[] paths) { return (max(paths) - min(paths)).x; }

real height(path[] paths) { return (max(paths) - min(paths)).y; }


transform shiftParallel(pair vec, real distance) {
    return shift(scale(distance) * unit(vec));
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


void extensionLine(pair pFrom, real angle=0, real length, Label L="") {
    real barwidth = width(texpath(L));

    pair
    barvec = scale(barwidth) * right,
    extvec = scale(length) * rotate(angle) * right;

    path
    extline = shift(pFrom) * ((0, 0)--extvec),
    barline = shift(point(extline, 1)) * ((0, 0)--barvec);

    draw(extline--barline);
    label(L, position=point(barline, .5), align=N);
}
