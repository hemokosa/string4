//
// The Art of Code - string quartet no.2 "reflective intervals" ver.1.0
//
// akihiro kubota (2008)
//

// baseic frequency;
440.0 => float base;

// strings
Bowed s[4][2];

// strings
JCRev r[4];

// channels
int ch[4];
[0, 1, 0, 1] @=> ch;

// first violin
s[0][0] => r[0] => dac.chan(ch[0]);
s[0][1] => r[0];

// second violin
s[1][0] => r[1] => dac.chan(ch[1]);
s[1][1] => r[1];

// viola
s[2][0] => r[2] => dac.chan(ch[2]);
s[2][1] => r[2];

// cello
s[3][0] => r[3] => dac.chan(ch[3]);
s[3][1] => r[3];

// fft
adc => LPF lpf => FFT fft =^ RMS rms => blackhole;

// low pass filter
lpf.freq (base);

// gain of strings
for( 0 => int i; i < 4 ; i++ ) {
    for( 0 => int j; j < 2 ; j++ ) 1.0 => s[i][j].gain;
}

// parameters of reverberation
for( 0 => int i; i < 4 ; i++ ) { 1.0 => r[i].gain; 0.3 => r[i].mix; }

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
    float pitchold;
    float volumeold;
    while( true )
    {
        pitch => pitchold;
        volume => volumeold;
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
        if (magmax > 0.001) {
            (imax$float / fft.size()) * (srate / 2) => pitch;
            if (pitch <= 0.0) base => pitch;
            (pitch + pitchold) * 0.5 => pitch;
            // calculate ratio
            pitch => tmp;
            if (tmp >= base*2) { while (tmp >= base*2) tmp / 2 => tmp; }
            if (tmp < base) { while (tmp < base) tmp * 2 => tmp; }
            tmp/base => ratio;
            <<< "pitch:", pitch, "magmax", magmax, "ratio:", ratio >>>;
        }
        // volume
        rms.upchuck() @=> UAnaBlob blob;
        blob.fval(0) => volume;
        (volume + volumeold) * 0.5 => volume;
        // advance time
        500::ms => now;
    }
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
[0.0],
[0.01],
[0.02],
[0.03],
[0.04],
[0.05]
] @=> float vf[][];
fun float vfrequency(int i, int n) {
    return vf[i%vf.cap()][n%vf[i%vf.cap()].cap()];
}

// vibratoGain
[
[0.0],
[0.01],
[0.02],
[0.03],
[0.04],
[0.05]
] @=> float vg[][];
fun float vgain(int i, int n) {
    return vg[i%vg.cap()][n%vg[i%vg.cap()].cap()];
}

// Volume (Distance)
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

// reverberation
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
[2.0, 3.0, 5.0, 7.0, 11.0],
[10.0, 20.0],
[30.0, 3.0],
[15.0, 20.0, 10.0]
] @=> float dr[][];
fun float duration(int i, int n) {
    return dr[i%dr.cap()][n%dr[i%dr.cap()].cap()];
}

// play or not (stochastic)
0.0 => float onoff1;
0.5 => float onoff2;


// playing
fun void playString(Bowed s, float f, float pr, float po, float vf, float vg, float vol, int onoff) {
    if (f < 0.0) 0 => onoff;
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    vol => s.volume;
    if (onoff == 1) 1.0 => s.noteOn; else 0.0 => s.noteOff;
    // print parameters
    <<< "---", me.id() >>>;
    <<< "frequency:", s.freq() >>>;
    <<< "bow pressure:", s.bowPressure() >>>;
    <<< "bow position:", s.bowPosition() >>>;
    <<< "vibrato freq:", s.vibratoFreq() >>>;
    <<< "vibrato gain:", s.vibratoGain() >>>;
    <<< "volume:", s.volume() >>>;
    <<< "onoff:", onoff >>>;
}

// instruments
fun void instrument(int k){
    int i0; int i1; int n; float d; float rt; float pr0; float po0; float vf0; float vg0; float vol0; int on1; int on2;
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
        revmix(irev, n) => r[k].gain;
        // first string
        if (Std.randf() > onoff1) { 0 => on1; 0 => on2; } 
        else { 1 => on1; if (Std.randf() > onoff2) { 0 => on2; } else { 1 => on2; } }
        if (Std.randf() > 0.0) 1.0 => rt; else ratio => rt;
        playString(s[k][0], f[k][i0]*rt, pr0, po0, vf0, vg0, vol0, on1);
        // second string (double-stop)
        Std.rand2f(0.0, 3.0)::second => now;
        if (Std.randf() > 0.0) 1.0 => rt; else ratio => rt;
        playString(s[k][1], f[k][i1]*rt, pr0, po0, vf0, vg0, vol0, on1);
        // advance time
        duration(idur, n) => d;
        d::second => now;
    }
    playString(s[k][0], f[k][i0], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
    playString(s[k][1], f[k][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
}


// main
180.0 => float tdur;
while(true){
    spork ~ listening();
    spork ~ instrument(0);
    spork ~ instrument(1);
    spork ~ instrument(2);
    spork ~ instrument(3);
	tdur::second => now;
}