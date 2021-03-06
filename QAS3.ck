//
// quartet for algorithmic strings op.3.0
// akihiro kubota, 2013-2017
//
// coded by ChucK program
//

// basic frequency;
440.0 => float base;

// strings
Bowed s[4][2];

// strings
JCRev r[4];

// fft
adc => LPF lpf => FFT fft => blackhole;

// low pass filter
lpf.freq (base);

// fft setting
1024 => fft.size;
Windowing.hann(fft.size()) => fft.window;
second / samp => float srate;

// listening
base => float pitch;
0.0 => float volume;
pitch/base => float ratio;

fun void listening() {
    complex spec[fft.size()/2];
    // pitch detection
    fft.upchuck();
    fft.spectrum(spec);
    // calculate spectrum magnitude
    float mag[fft.size()/2];
    for (1 => int i; i < fft.size()/2; i++) (spec[i]$polar).mag => mag[i];
    // find the largest magnitude
    float magmax;
    int imax;
    for (1 => int i; i < fft.size()/2; i++) {
        if (mag[i] > magmax) {
            mag[i] => magmax;
            i => imax;
        }
    }
    // calculate pitch
    float tmp;
    (imax$float / fft.size()) * (srate / 2) => pitch;
    if (pitch <= 0.0) base => pitch;
    // calculate ratio
    pitch => tmp;
    if (tmp >= base*2) { while (tmp >= base*2) tmp / 2 => tmp; }
    if (tmp < base) { while (tmp < base) tmp * 2 => tmp; }
    tmp/base => ratio;
}


// tuning
float f[4][4];

// first violin
fun void tuning1(float base) {
    base / 1.5 / 1.5 => f[0][0];
    base / 1.5 => f[0][1];
    base => f[0][2];
    base * 1.5 => f[0][3];
}
tuning1(base);

// second violin
fun void tuning2(float base) {
    base / 1.5 / 1.5 => f[1][0];
    base / 1.5 => f[1][1];
    base => f[1][2];
    base * 1.5 => f[1][3];
}
tuning2(base);

// viola
fun void tuning3(float base) {
    base / 1.5 / 1.5 / 1.5 => f[2][0];
    base / 1.5 / 1.5 => f[2][1];
    base / 1.5 => f[2][2];
    base => f[2][3];
}
tuning3(base);

// cello
fun void tuning4(float base) {
    base / 2 / 1.5 / 1.5 / 1.5 => f[3][0];
    base / 2 / 1.5 / 1.5 => f[3][1];
    base / 2 / 1.5 => f[3][2];
    base / 2 => f[3][3];
}
tuning4(base);

// compositions
//
// stringNumber
[
[[0, 1], [1, 2], [2, 3]],
[[3, 2], [2, 1], [1, 0]],
[[0, 1], [3, 2]],
[[1, 2], [2, 1]],
[[0, 1]],
[[3, 2]]
] @=> int sn[][][];
fun int snumber(int i, int n, int j) {
    return sn[i%sn.cap()][n%sn[i%sn.cap()].cap()][j];
}

// bowPressure
[
[0.1, 0.9],
[0.9, 0.8, 0.7],
[0.1, 0.05, 0.1],
[0.1, 0.3, 0.5, 0.7, 0.9],
[0.9, 0.7, 0.5, 0.3, 0.1]
] @=> float pr[][];
fun float bpressure(int i, int n) {
    return pr[i%pr.cap()][n%pr[i%pr.cap()].cap()];
}

// bowPosition
[
[0.05, 0.5],
[0.08, 0.02],
[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
[0.02, 0.04, 0.06, 0.08, 0.1],
[0.1, 0.08, 0.06, 0.04, 0.02]
] @=> float po[][];
fun float bposition(int i, int n) {
    return po[i%po.cap()][n%po[i%po.cap()].cap()];
}

// vibratoFreq
[
[0.01, 0.02, 0.03, 0.04, 0.05],
[0.05, 0.04, 0.03, 0.02, 0.01]
] @=> float vf[][];
fun float vfrequency(int i, int n) {
    return vf[i%vf.cap()][n%vf[i%vf.cap()].cap()];
}

// vibratoGain
[
[0.01, 0.02, 0.03, 0.04, 0.05],
[0.05, 0.04, 0.03, 0.02, 0.01]
] @=> float vg[][];
fun float vgain(int i, int n) {
    return vg[i%vg.cap()][n%vg[i%vg.cap()].cap()];
}

// configurations
//
// channels
int ich;
[
[0, 1, 0, 1],
[0, 1, 1, 0],
[0, 0, 1, 1],
[1, 1, 0, 0]
] @=> int ch[][];
fun int channel(int i, int n) {
    return ch[i%ch.cap()][n%ch[i%ch.cap()].cap()];
}

// volume (distance)
[
[0.1],
[0.3],
[0.5],
[0.7],
[0.9]
] @=> float vol[][];
fun float distance(int i, int n) {
    return vol[i%vol.cap()][n%vol[i%vol.cap()].cap()];
}

// reverberation mix level
[
[0.1],
[0.3],
[0.5],
[0.7],
[0.9]
] @=> float rev[][];
fun float revmix(int i, int n) {
    return rev[i%rev.cap()][n%rev[i%rev.cap()].cap()];
}

// repeat
[ 2, 3, 5, 7, 11 ] @=> int nmax[];
fun int repetition(int i) {
    return nmax[i%nmax.cap()];
}

// duration
[
[2.0, 3.0, 5.0, 7.0, 11.0, 13.0, 17.0],
[17.0, 13.0, 11.0, 7.0, 5.0, 3.0, 2.0],
[10.0, 20.0],
[30.0, 3.0],
[15.0, 20.0, 10.0]
] @=> float dr[][];
fun float duration(int i, int n) {
    return dr[i%dr.cap()][n%dr[i%dr.cap()].cap()];
}

// play or not (stochastic)
0.0 => float onoff0;
0.5 => float onoff1;

// gain of strings
for( 0 => int i; i < 4 ; i++ ) {
    for( 0 => int j; j < 2 ; j++ ) 1.0 => s[i][j].gain;
}

// gain of reverberation
for( 0 => int i; i < 4 ; i++ ) 1.0 => r[i].gain;


// play a string
fun void play(Bowed s, float f, float pr, float po, float vf, float vg, float vol, int onoff) {
    if (f < 0.0) 0 => onoff;
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    vol => s.volume;
    if (onoff == 1) 1.0 => s.noteOn; else 0.0 => s.noteOff;
    // print parameters
    if (onoff == 1) {
        <<< "---", me.id() >>>;
        <<< "pitch:", pitch, "ratio:", ratio >>>;
        <<< "frequency:", s.freq() >>>;
        <<< "bow pressure:", s.bowPressure() >>>;
        <<< "bow position:", s.bowPosition() >>>;
        <<< "vibrato freq:", s.vibratoFreq() >>>;
        <<< "vibrato gain:", s.vibratoGain() >>>;
        <<< "volume:", s.volume() >>>;
    }
}

// instruments
fun void instrument(int k){
    int i0; int i1; int n; float d; float rt; float pr0; float po0; float vf0; float vg0; float vol0; int on0; int on1;
    // ugen connections
    s[k][0] => r[k] => dac.chan(channel(ich, k));
    s[k][1] => r[k];
    // select patterns
    Std.rand2(0, sn.cap()-1) => int isn;
    Std.rand2(0, pr.cap()-1) => int ipr;
    Std.rand2(0, po.cap()-1) => int ipo;
    Std.rand2(0, vf.cap()-1) => int ivf;
    Std.rand2(0, vg.cap()-1) => int ivg;
    Std.rand2(0, vol.cap()-1) => int ivol;
    Std.rand2(0, rev.cap()-1) => int irev;
    Std.rand2(0, dr.cap()-1) => int idur;
    repetition(Std.rand2(0, nmax.cap()-1)) => int nm;
    for( 0 => n; n < nm; n++ ) {
        snumber(isn, n, 0) => i0;
        snumber(isn, n, 1) => i1;
        bpressure(ipr, n) => pr0;
        bposition(ipo, n) => po0;
        vfrequency(ivf, n) => vf0;
        vgain(ivg, n) => vg0;
        distance(ivol, n) => vol0;
        // reverbration
        revmix(irev, n) => r[k].mix;
        // listening
        listening();
        // play or not
        if (Std.randf() > onoff0) { 0 => on0; 0 => on1; } 
        else { 1 => on0; if (Std.randf() > onoff1) { 0 => on1; } else { 1 => on1; } }
        // first string
        if (Std.randf() > 0.0) 1.0 => rt; else ratio => rt;
        play(s[k][0], f[k][i0]*rt, pr0, po0, vf0, vg0, vol0, on0);
        // second string (double-stop)
        Std.rand2f(0.0, 3.0)::second => now;
        if (Std.randf() > 0.0) 1.0 => rt; else ratio => rt;
        play(s[k][1], f[k][i1]*rt, pr0, po0, vf0, vg0, vol0, on1);
        // advance time
        duration(idur, n) => d;
        d::second => now;
        // stop playing
        play(s[k][0], f[k][i0], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
        play(s[k][1], f[k][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
        Std.rand2f(0.0, 3.0)::second => now;
    }
}


// main
120.0 => float tdur;
while(true){
    Std.rand2(0, ch.cap()-1) => ich;
    for( 0 => int i; i < 4 ; i++ ) spork ~ instrument(i);
    tdur::second => now;
}
