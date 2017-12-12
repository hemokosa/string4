//
// quartet for algorithmic strings op.5, 
// "Music for Library"
// akihiro kubota, 2017
//
// coded by ChucK : Strongly-timed, Concurrent, and On-the-fly Music Programming Language 
//

// basic frequency;
330.0 => float base;

// strings
Bowed s[4][2];
JCRev r[4];

// envelope
ADSR e[4][2];

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

// composition as executions
//
// stringNumber
[
[[0, 1], [1, 2], [2, 3]],
[[3, 2], [2, 1], [1, 0]],
[[0, 1], [3, 2]],
[[1, 2], [2, 1]],
[[2, 3], [1, 0]],
[[0, 1]],
[[3, 2]]
] @=> int sn[][][];
fun int snumber(int i, int n, int j) {
    return sn[i%sn.cap()][n%sn[i%sn.cap()].cap()][j];
}

// bowPressure
[
[0.9, 0.8, 0.7, 0.6, 0.5],
[0.5, 0.6, 0.7, 0.8, 0.9]
] @=> float pr[][];
fun float bpressure(int i, int n) {
    return pr[i%pr.cap()][n%pr[i%pr.cap()].cap()];
}

// bowPosition (sul ponticello)
[
[0.01, 0.99],
[0.1, 0.9],
[0.02, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.98],
[0.02, 0.04, 0.06, 0.08, 0.1, 0.9, 0.92, 0.94, 0.96, 0.98],
[0.05, 0.5, 0.95]
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
[0.02, 0.04, 0.06, 0.08, 0.1],
[0.1, 0.08, 0.06, 0.04, 0.02]
] @=> float vg[][];
fun float vgain(int i, int n) {
    return vg[i%vg.cap()][n%vg[i%vg.cap()].cap()];
}

// configurations
//
// channels
int ich;
[
[0, 1, 1, 0],
[0, 0, 1, 1],
[0, 1, 0, 1],
[1, 1, 0, 0],
[1, 0, 1, 0],
[1, 0, 0, 1]
] @=> int ch[][];
fun int channel(int i, int n) {
    return ch[i%ch.cap()][n%ch[i%ch.cap()].cap()];
}

// distance
[ 0.1, 0.2, 0.3 ] @=> float dis[];
fun float distance(int i) {
    return dis[i%dis.cap()];
}

// repeat
[2, 3, 5, 7, 11] @=> int nmax[];
fun int repetition(int i) {
    return nmax[i%nmax.cap()];
}

// duration
[
[2.0, 3.0, 5.0, 7.0, 11.0, 13.0, 17.0, 23.0],
[23.0, 17.0, 13.0, 11.0, 7.0, 5.0, 3.0, 2.0],
[20.0, 10.0, 30.0],
[3.0, 30.0, 2.0],
[10.0, 15.0, 20.0]
] @=> float dr[][];
fun float duration(int i, int n) {
    return dr[i%dr.cap()][n%dr[i%dr.cap()].cap()];
}

// play or not (stochastic)
0.2 => float onoff0;
0.2 => float onoff1;

// gain of strings
for( 0 => int i; i < 4 ; i++ ) {
    for( 0 => int j; j < 2 ; j++ ) 0.5 => s[i][j].gain;
}

// gain of reverberation
for( 0 => int i; i < 4 ; i++ ) 0.5 => r[i].gain;


// play a string
fun void play(Bowed s, ADSR e, float f, float d, float pr, float po, float vf, float vg, float vol, int onoff) {
    float at; float rl;
    
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    vol => s.volume;
    
    Std.rand2f(0.1, 0.2) => at;
    Std.rand2f(1.0, 2.5) => rl;
    
    e.set(at, 0.1, Std.rand2f(0.8, 1.0), rl);   
    if (onoff == 1)
    {
        1.0 => s.noteOn;
        e.keyOn();
    }
    else
    {
        e.keyOff(); 
        3.0::second => now;
        0.0 => s.noteOff;
    }

    // print parameters
    if (onoff == 1) {
        <<< "---", me.id() >>>;
        <<< "pitch:", pitch, "ratio:", ratio >>>;
        <<< "frequency:", s.freq() >>>;
        <<< "attack:", at >>>;
        <<< "duration:", d >>>;
        <<< "release:", rl >>>;
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
    s[k][0] => e[k][0] => r[k] => dac.chan(channel(ich, k));
    s[k][1] => e[k][1] => r[k];
    
    // select patterns
    Std.rand2(0, sn.cap()-1) => int isn;
    Std.rand2(0, pr.cap()-1) => int ipr;
    Std.rand2(0, po.cap()-1) => int ipo;
    Std.rand2(0, vf.cap()-1) => int ivf;
    Std.rand2(0, vg.cap()-1) => int ivg;
    Std.rand2(0, dr.cap()-1) => int idur;
    repetition(Std.rand2(0, nmax.cap()-1)) => int nm;

    // distance (reverbration)
    1.0 - distance(Std.rand2(0, dis.cap()-1)) => vol0;
    1.0 - vol0 => r[k].mix;
    <<< "distance:", 1.0 - vol0 >>>;
    
    
    for( 0 => n; n < nm; n++ ) {
        snumber(isn, n, 0) => i0;
        snumber(isn, n, 1) => i1;
        bpressure(ipr, n) => pr0;
        bposition(ipo, n) => po0;
        vfrequency(ivf, n) => vf0;
        vgain(ivg, n) => vg0;

        // duration
        duration(idur, n) => d;
        
        // listening
        listening();
        
        // first string
        if (Std.randf() > onoff0) {
            play(s[k][0], e[k][0], f[k][i0]*ratio, d, pr0, po0, vf0, vg0, vol0, 1);
            // second string (double-stop)
            Std.rand2f(0.0, 3.0)::second => now;
            if (Std.randf() > onoff1) {
                play(s[k][1], e[k][1], f[k][i1]*ratio, d, pr0, po0, vf0, vg0, vol0, 1);
            }
        }
        
        // advance time
        d::second => now;
        
        // stop playing
        e[k][0].keyOff();
        e[k][1].keyOff();
        3.0::second => now;
        0.0 => s[k][0].noteOff;
        0.0 => s[k][1].noteOff;
        
    }
}

// main
120.0 => float tdur;
while(true){
    Std.rand2(0, ch.cap()-1) => ich;
    for( 0 => int i; i < 4 ; i++ ) spork ~ instrument(i);
    tdur::second => now;
}
