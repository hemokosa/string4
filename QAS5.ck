//
// quartet for algorithmic strings op.5, 
// "Music for Library"
// akihiro kubota, 2017
//
// coded by ChucK : Strongly-timed, Concurrent, and On-the-fly Music Programming Language 
//

// basic frequency;
440.0 => float base;

// strings
Bowed s[4][2];
JCRev r[4];

// envelope
ADSR e[4][2];

// dynamic processor
Dyno dy;

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
[0.8, 0.7, 0.6, 0.5, 0.4],
[0.4, 0.5, 0.6, 0.8, 0.7],
[0.7, 0.3, 0.6, 0.5],
[0.5, 0.4, 0.7, 0.8]
] @=> float pr[][];
fun float bpressure(int i, int n) {
    return pr[i%pr.cap()][n%pr[i%pr.cap()].cap()];
}

// bowPosition (sul ponticello)
[
[0.1, 0.5, 0.9],
[0.1, 0.9],
[0.1, 0.2, 0.3, 0.9],
[0.1, 0.2, 0.8, 0.9],
[0.1, 0.2, 0.5]
] @=> float po[][];
fun float bposition(int i, int n) {
    return po[i%po.cap()][n%po[i%po.cap()].cap()];
}

// vibratoFreq
[
[0.01, 0.015, 0.02, 0.025, 0.03],
[0.03, 0.025, 0.02, 0.015, 0.01]
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

// distance
[ 0.2, 0.3, 0.4, 0.5] @=> float dis[];
fun float distance(int i) {
    return dis[i%dis.cap()];
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

// repeat
[1, 2, 3, 4, 5] @=> int nmax[];
fun int repetition(int i) {
    return nmax[i%nmax.cap()];
}

// play or not (stochastic)
0.5 => float onoff0;
0.5 => float onoff1;

// limiter
dy.limit();
0.5 => dy.gain;

// play a string
fun void play(Bowed s, ADSR e, float f, float d, float pr, float po, float vf, float vg, float vol, int onoff) {
    float at; float sl; float rl;
    
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    
    Math.random2f(0.1, 0.2) => at;
    Math.random2f(5.0, 10.0) => rl;
    Math.random2f(0.8, 1.0) => sl;
     
    e.set(at, 0.1, sl, rl);   
    if (onoff == 1)
    {
        vol => s.noteOn;
        e.keyOn();
    }
    else
    {
        e.keyOff(); 
        10.0::second => now;
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
        <<< "volume:", vol >>>;
    }
}

// instruments
fun void instrument(int k){
    int i0; int i1; int n; float d; float rt; float pr0; float po0; float vf0; float vg0; float vol0; int on0; int on1;
    float dist; int ichan;
    // ugen connections
    Math.random2(0, 3) => ichan;
    <<< "channel:", ichan >>>;
    s[k][0] => e[k][0] => r[k] => dy => dac.chan(ichan);
    s[k][1] => e[k][1] => r[k];
    
    0.1 => s[k][0].gain;
    0.1 => s[k][1].gain;
    0.2 => r[k].gain;
    0.5 => r[k].mix;
    
    // select patterns
    Math.random2(0, sn.cap()-1) => int isn;
    Math.random2(0, pr.cap()-1) => int ipr;
    Math.random2(0, po.cap()-1) => int ipo;
    Math.random2(0, vf.cap()-1) => int ivf;
    Math.random2(0, vg.cap()-1) => int ivg;
    Math.random2(0, dr.cap()-1) => int idur;
    repetition(Math.random2(0, nmax.cap()-1)) => int nm;

    // distance (volume)
    distance(Math.random2(0, dis.cap()-1)) => dist;  
    0.8 - dist => vol0;       
        
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
        if (Math.randomf() > onoff0) {
            Math.random2f(0.0, 3.0)::second => now;
            play(s[k][0], e[k][0], f[k][i0]*ratio, d, pr0, po0, vf0, vg0, vol0, 1);
            // second string (double-stop)           
            if (Math.randomf() > onoff1) {
                Math.random2f(0.0, 3.0)::second => now;
                play(s[k][1], e[k][1], f[k][i1]*ratio, d, pr0, po0, vf0, vg0, vol0, 1);
            }
        } else {
            play(s[k][0], e[k][0], f[k][i0]*ratio, d, pr0, po0, vf0, vg0, vol0, 0);
            play(s[k][1], e[k][1], f[k][i1]*ratio, d, pr0, po0, vf0, vg0, vol0, 0);
        }
        
        // advance time
        d::second => now;
        
        // stop playing
        e[k][0].keyOff();
        e[k][1].keyOff();
        18.0::second => now;
        0.0 => s[k][0].noteOff;
        0.0 => s[k][1].noteOff;    
    }
    me.exit(); 
}

// main
while(true){
    for( 0 => int i; i < 4 ; i++ ) spork ~ instrument(i);
    Math.random2f(130.0, 180.0)::second => now;
}
