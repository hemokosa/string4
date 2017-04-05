//
// The Art of Code - string quartet no.2 "reflective ambient" ver.1.0
//
// akihiro kubota (2008)
//

// baseic frequency;
440.0 => float base;

Bowed s[4][2]; // strings

JCRev r[4]; // reverberation

// first violin
s[0][0] => r[0] => dac;
s[0][1] => r[0];

// second violin
s[1][0] => r[1] => dac;
s[1][1] => r[1];

// viola
s[2][0] => r[2] => dac;
s[2][1] => r[2];

// cello
s[3][0] => r[3] => dac;
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
for( 0 => int i; i < 4 ; i++ ) { 1.0 => r[i].gain; 0.5 => r[i].mix; }

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
        0 => float tmp;
        0 => int imax;
        for (1 => int i; i < fft.size()/2; i++) {
            if (mag[i] > tmp) {
                mag[i] => tmp;
                i => imax;
            }
        }
        // calculate pitch
        (imax$float / fft.size()) * (srate / 2) => float pitch;
        if (pitch <= 0.0) base => pitch;
        (pitch + pitchold) * 0.5 => pitch;
        // volume
        rms.upchuck() @=> UAnaBlob blob;
        blob.fval(0) => volume;
        (volume + volumeold) * 0.5 => volume;
        // calculate ratio
        pitch => tmp;
        if (tmp >= base*2) { while (tmp >= base*2) tmp / 2 => tmp; }
        if (tmp < base) { while (tmp < base) tmp * 2 => tmp; }
        tmp/base => ratio;
        // print out
        <<< "pitch:", pitch, "volume:", volume, "ratio:", ratio >>>;
        // advance time
        100::ms => now;
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

// scale
[1.0, 1.2, 1.25, 1.5] @=> float scale1[];
[1.0, 1.2, 1.25, 1.5] @=> float scale2[];
[1.0, 1.2, 1.25, 1.5, 1.75] @=> float scale3[];
[1.0, 1.2, 1.25, 1.5, 1.75] @=> float scale4[];
scale1.cap() - 1 => int nscale1;
scale2.cap() - 1 => int nscale2;
scale3.cap() - 1 => int nscale3;
scale4.cap() - 1 => int nscale4;


// play a string
fun void playString(Bowed s, float f, float pr, float po, float vf, float vg, float v, int onoff) {
    if (f < 0.0) 0 => onoff;
    f => s.freq;
    pr => s.bowPressure;
    po => s.bowPosition;
    vf => s.vibratoFreq;
    vg => s.vibratoGain;
    v => s.volume;
    0.1 => s.startBowing;
    0.1 => s.stopBowing;
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

// bow parameters
0.1 => float pr1; 1.0 => float pr2;
0.1 => float po1; 0.7 => float po2;
0.01 => float vf1; 0.1 => float vf2;
0.01 => float vg1; 0.1 => float vg2;

0.0 => float onoff1;
0.0 => float onoff2;

// violin1
fun void violin1(){
    int i1; int i2; int j; int n; float pr; float po; float vf; float vg; float vol; int on1; int on2;
    for( 0 => n; n < 4 ; n++ ) {
        Std.rand2(0, 3) => i1;
        Std.rand2(0, nscale1) => j;
        Std.rand2f(pr1, pr2) * Std.rand2f(pr1, pr2) => pr;
        Std.rand2f(po1, po2) * Std.rand2f(po1, po2) => po;
        Std.rand2f(vf1, vf2) => vf;
        Std.rand2f(vg1, vg2) => vg;
        1.0 => vol;
        if (Std.randf() > onoff1) { 0 => on1; 0 => on2; } 
        else { 1 => on1; if (Std.randf() > onoff2) { 0 => on2; } else { 1 => on2; } }
        playString(s[0][0], f[0][i1]*scale1[j], pr, po, vf, vg, vol, on1);
        if (Std.randf() > 0.0) Std.rand2f(0.1, 3.0)::second => now;
        if (i1 == 0) 1 => i2;
        if (i1 == 1) { if (Std.randf() > 0.0) 0 => i2; else 2 => i2; }
        if (i1 == 2) { if (Std.randf() > 0.0) 1 => i2; else 3 => i2; }
        if (i1 == 3) 2 => i2;
        playString(s[0][1], f[0][i2]*ratio, pr, po, vf, vg, vol, on2);
        // advance time
        Std.rand2f(28.0, 32.0)::second => now;
    }
    playString(s[0][0], f[0][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
    playString(s[0][1], f[0][i2], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
}

// violin2
fun void violin2(){
    int i1; int i2; int j; int n; float pr; float po; float vf; float vg; float vol; int on1; int on2;
    for( 0 => n; n < 10 ; n++ ) {
        Std.rand2(0, 3) => i1;
        Std.rand2(0, nscale2) => j;
        Std.rand2f(pr1, pr2) * Std.rand2f(pr1, pr2) => pr;
        Std.rand2f(po1, po2) * Std.rand2f(po1, po2) => po;
        Std.rand2f(vf1, vf2) => vf;
        Std.rand2f(vg1, vg2) => vg;
        1.0 => vol;
        if (Std.randf() > onoff1) { 0 => on1; 0 => on2; } 
        else { 1 => on1; if (Std.randf() > onoff2) { 0 => on2; } else { 1 => on2; } }
        playString(s[1][0], f[1][i1]*scale2[j], pr, po, vf, vg, vol, on1);
        if (Std.randf() > 0.0) Std.rand2f(0.1, 3.0)::second => now;
        if (i1 == 0) 1 => i2;
        if (i1 == 1) { if (Std.randf() > 0.0) 0 => i2; else 2 => i2; }
        if (i1 == 2) { if (Std.randf() > 0.0) 1 => i2; else 3 => i2; }
        if (i1 == 3) 2 => i2;
        playString(s[1][1], f[1][i2]*ratio, pr, po, vf, vg, vol, on2);
        // advance time
        Std.rand2f(10.0, 12.0)::second => now;
    }
    playString(s[1][0], f[1][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
    playString(s[1][1], f[1][i2], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
}

// viola
fun void viola(){
    int i1; int i2; int j; int n; float pr; float po; float vf; float vg; float vol; int on1; int on2;
    for( 0 => n; n < 8 ; n++ ) {
        Std.rand2(0, 3) => i1;
        Std.rand2(0, nscale3) => j;
        Std.rand2f(pr1, pr2) * Std.rand2f(pr1, pr2) => pr;
        Std.rand2f(po1, po2) * Std.rand2f(po1, po2) => po;
        Std.rand2f(vf1, vf2) => vf;
        Std.rand2f(vg1, vg2) => vg;
        1.0 => vol;
        if (Std.randf() > onoff1) { 0 => on1; 0 => on2; } 
        else { 1 => on1; if (Std.randf() > onoff2) { 0 => on2; } else { 1 => on2; } }
        playString(s[2][0], f[2][i1]*scale3[j], pr, po, vf, vg, vol, on1);
        if (Std.randf() > 0.0) Std.rand2f(0.1, 3.0)::second => now;
        if (i1 == 0) 1 => i2;
        if (i1 == 1) { if (Std.randf() > 0.0) 0 => i2; else 2 => i2; }
        if (i1 == 2) { if (Std.randf() > 0.0) 1 => i2; else 3 => i2; }
        if (i1 == 3) 2 => i2;
        playString(s[2][1], f[2][i2]*ratio, pr, po, vf, vg, vol, on2);
        // advance time
        Std.rand2f(13.0, 17.0)::second => now;
    }
    playString(s[2][0], f[2][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
    playString(s[2][1], f[2][i2], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
}

// cello
fun void cello(){
    int i1; int i2; int j; int n; float pr; float po; float vf; float vg; float vol; int on1; int on2;
    for( 0 => n; n < 6 ; n++ ) {
        Std.rand2(0, 3) => i1;
        Std.rand2(0, nscale4) => j;
        Std.rand2f(pr1, pr2) * Std.rand2f(pr1, pr2) => pr;
        Std.rand2f(po1, po2) * Std.rand2f(po1, po2) => po;
        Std.rand2f(vf1, vf2) => vf;
        Std.rand2f(vg1, vg2) => vg;
        1.0 => vol;
        if (Std.randf() > onoff1) { 0 => on1; 0 => on2; } 
        else { 1 => on1; if (Std.randf() > onoff2) { 0 => on2; } else { 1 => on2; } }
        playString(s[3][0], f[3][i1]*scale4[j], pr, po, vf, vg, vol, on1);
        if (Std.randf() > 0.0) Std.rand2f(0.1, 3.0)::second => now;
        if (i1 == 0) 1 => i2;
        if (i1 == 1) { if (Std.randf() > 0.0) 0 => i2; else 2 => i2; }
        if (i1 == 2) { if (Std.randf() > 0.0) 1 => i2; else 3 => i2; }
        if (i1 == 3) 2 => i2;
        playString(s[3][0], f[3][i2]*ratio, pr, po, vf, vg, vol, on2);
        // advance time
        Std.rand2f(18.0, 22.0)::second => now;
    }
    playString(s[3][0], f[3][i1], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
    playString(s[3][1], f[3][i2], 0.01, 0.01, 0.01, 0.01, 0.0, 0);
}

// sound generation
while(true){
    spork ~ listening();
    spork ~ violin1();
    spork ~ violin2();
    spork ~ viola();
    spork ~ cello();
	Std.rand2f(175.0, 185.0)::second => now;
}