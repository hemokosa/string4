//
// code quartet for algorithmic strings op.5.1
// akihiro kubota, 2006-2017
//
// coded by ChucK program
//

// basic frequency;
440.0 => float base;

// strings
Bowed s[4][2];
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
    base / Math.sqrt(2.0) / Math.sqrt(2.0) => f[1][0];
    base / Math.sqrt(2.0) => f[1][1];
    base => f[1][2];
    base * Math.sqrt(2.0) => f[1][3];
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
[0.1, 0.5],
[0.1, 0.2],
[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
[0.1, 0.2, 0.4, 0.6, 0.8],
[0.1, 0.8, 0.6, 0.4, 0.2]
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
[0.1, 0.02, 0.03, 0.04, 0.05],
[0.05, 0.04, 0.03, 0.02, 0.01]
] @=> float vg[][];
fun float vgain(int i, int n) {
    return vg[i%vg.cap()][n%vg[i%vg.cap()].cap()];
}

// configurations
//
// channels
int ich;

// volume (distance)
[
[0.1],
[0.2],
[0.3],
[0.4],
[0.5]
] @=> float vol[][];
fun float distance(int i, int n) {
    return vol[i%vol.cap()][n%vol[i%vol.cap()].cap()];
}

// reverberation mix level
[
[0.1],
[0.2],
[0.3],
[0.4],
[0.5]
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
[5.0, 7.0, 11.0, 13.0, 17.0],
[17.0, 13.0, 11.0, 7.0, 5.0],
[10.0, 20.0],
[30.0, 5.0],
[15.0, 20.0, 10.0]
] @=> float dr[][];
fun float duration(int i, int n) {
    return dr[i%dr.cap()][n%dr[i%dr.cap()].cap()];
}

// play or not (stochastic)
0.2 => float onoff0;
0.5 => float onoff1;

// play a string
fun void play(Bowed s, float f, float pr, float po, float vf, float vg, float vol, int onoff) {
    if (f < 0.0) 0 => onoff;
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    vol => s.volume;
    if (onoff == 1) 1 => s.noteOn; else 0 => s.noteOff;
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
    int i0; int i1; int n; float d; float pr0; float po0; float vf0; float vg0; float vol0; int on0; int on1;
    // ugen connections
    Math.random2(0, 1) => ich;
    s[k][0] => r[k] => dac.chan(ich);
    s[k][1] => r[k];
    0.1 => s[k][0].gain;
    0.1 => s[k][1].gain;
    1.0 => r[k].gain;
    // select patterns
    Math.random2(0, sn.cap()-1) => int isn;
    Math.random2(0, pr.cap()-1) => int ipr;
    Math.random2(0, po.cap()-1) => int ipo;
    Math.random2(0, vf.cap()-1) => int ivf;
    Math.random2(0, vg.cap()-1) => int ivg;
    Math.random2(0, vol.cap()-1) => int ivol;
    Math.random2(0, rev.cap()-1) => int irev;
    Math.random2(0, dr.cap()-1) => int idur;
    repetition(Math.random2(0, nmax.cap()-1)) => int nm;
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
        if (Math.randomf() > onoff0) { 0 => on0; 0 => on1; } 
        else { 1 => on0; if (Math.randomf() > onoff1) { 0 => on1; } else { 1 => on1; } }
        // first string
        play(s[k][0], f[k][i0]*ratio, pr0, po0, vf0, vg0, vol0, on0);
        // second string (double-stop)
        Math.random2f(0.0, 5.0)::second => now;
        play(s[k][1], f[k][i1]*ratio, pr0, po0, vf0, vg0, vol0, on1);
        // advance time
        duration(idur, n) => d;
        d::second => now;
        // stop playing
        play(s[k][0], f[k][i0], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
        play(s[k][1], f[k][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
        Math.random2f(0.0, 5.0)::second => now;
    }
}

// main
Math.random2f(120.0, 180.0) => float tdur;
while(true){
    for( 0 => int i; i < 4 ; i++ ) spork ~ instrument(i);
    tdur::second => now;
}
