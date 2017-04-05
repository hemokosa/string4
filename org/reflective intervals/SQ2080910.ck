//
// The Art of Code - string quartet no. 2 "reflective ambient"
//
// akihiro kubota (2008)
//

// initialize

// first violin
Bowed s1 => NRev r1 => dac;

// second violin
Bowed s2 => NRev r2 => dac;

// viola
Bowed s3 => NRev r3 => dac;

// cello
Bowed s4 => NRev r4 => dac;

// fft
adc => FFT fft =^ RMS rms => blackhole;

// gain of strings
1.0 => s1.gain;
1.0 => s2.gain;
1.0 => s3.gain;
1.0 => s4.gain;

// parameters of reverberation
1.0 => r1.gain;
1.0 => r2.gain;
1.0 => r3.gain;
1.0 => r4.gain;
0.5 => r1.mix;
0.5 => r2.mix;
0.5 => r3.mix;
0.5 => r4.mix;

// fft setting
1024 => fft.size;
Windowing.hann(fft.size()) => fft.window;
second / samp => float srate;

// reflective tuning
fun float tuning() {
    complex spec[fft.size()/2];
    // pitch detection
    fft.upchuck();
    fft.spectrum(spec);
    // calculate spectrum magnitude
    float mag[fft.size()/2];
    for (1 => int i; i < fft.size()/2; i++) {
        (spec[i]$polar).mag => mag[i];
    }
    // find the largest magnitude
    0 => float temp;
    0 => int imax;
    for (1 => int i; i < fft.size()/2; i++) {
        if (mag[i] > temp) {
            mag[i] => temp;
            i => imax;
        }
    }
    (imax$float / fft.size()) * (srate / 2) => float peak;
    if (peak <= 0) { 440.0 => peak; };
    //
    peak => float base;
    if (base >= 880.0) {
        while (base >= 880.0) { base / 2 => base; }
    }
    else if (base < 440.0) {
        while (base < 440.0) { base * 2 => base; }
    }
    <<< "peak:", peak, " base:", base >>>;
    return base;
}

float f1[4]; // first violin
fun void tuning1(float base1) {
    base1 / 2 / 1.5 / 1.5 => f1[0];
    base1 / 2 / 1.5 => f1[1];
    base1 / 2 => f1[2];
    base1 / 2 * 1.5 => f1[3];
}

float f2[4]; // second violin
fun void tuning2(float base2) {
    base2 / 2 / 1.5 / 1.5 => f2[0];
    base2 / 2 / 1.5 => f2[1];
    base2 / 2 => f2[2];
    base2 / 2 * 1.5 => f2[3];
}

float f3[4]; // viola
fun void tuning3(float base3) {
    base3 / 2 / 1.5 / 1.5 / 1.5 => f3[0];
    base3 / 2 / 1.5 / 1.5 => f3[1];
    base3 / 2 / 1.5 => f3[2];
    base3 / 2 => f3[3];
}

float f4[4]; // cello
fun void tuning4(float base4) {
    base4 / 2 / 2 / 1.5 / 1.5 / 1.5 => f4[0];
    base4 / 2 / 2 / 1.5 / 1.5 => f4[1];
    base4 / 2 / 2 / 1.5 => f4[2];
    base4 / 2 / 2 => f4[3];
}

// volume
fun float volume() {
    rms.upchuck() @=> UAnaBlob blob;
    // print out RMS
    <<< "rms:", blob.fval(0) >>>;
    return blob.fval(0);
}

// scale
//[1.0, Math.sqrt(2.0), 2.0] @=> float fc[];
[1.0, 1.2, 1.25, 1.5] @=> float fc[];


// play a string
fun void playString(Bowed s, float f, float pr, float po, float vf, float vg, float v, float on) {
	f => s.freq;
	pr => s.bowPressure;
	po => s.bowPosition;
	vf => s.vibratoFreq;
	vg => s.vibratoGain;
	v => s.volume;
	on => s.noteOn;
	// print parameters
	<<< "---", me.id() >>>;
	<<< "frequency:", s.freq() >>>;
	<<< "bow pressure:", s.bowPressure() >>>;
	<<< "bow position:", s.bowPosition() >>>;
	<<< "vibrato freq:", s.vibratoFreq() >>>;
	<<< "vibrato gain:", s.vibratoGain() >>>;
	<<< "volume:", s.volume() >>>;
	<<< "noteon:", on >>>;
	<<< "---", me.id() >>>;
}

// first violin
fun void violin1(){
 	while (true) {
        tuning1(tuning());
        volume() => float vol;
		Std.rand2(0, 2) => int i;
		Std.rand2(0, 3) => int j1;
		Std.rand2(0, 3) => int j2;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s1, f1[i]*fc[j1], pr, po, vf, vg, v, on);
        if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s1, f1[i+1]*fc[j2], pr, po, vf, vg, v, on);
 		// advance time
		Std.rand2f(4.0, 6.0)::second => now;
	}
}

// second violin
fun void violin2(){
	while (true) {
        tuning2(tuning());
        volume() => float vol;
		Std.rand2(0, 2) => int i;
		Std.rand2(0, 3) => int j1;
		Std.rand2(0, 3) => int j2;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s2, f2[i]*fc[j1], pr, po, vf, vg, v, on);
        if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s2, f2[i+1]*fc[j2], pr, po, vf, vg, v, on);
		// advance time
		Std.rand2f(6.0, 8.0)::second => now;
	}
}

// viola
fun void viola(){
	while (true) {
        tuning3(tuning());
        volume() => float vol;
		Std.rand2(0, 2) => int i;
		Std.rand2(0, 3) => int j1;
		Std.rand2(0, 3) => int j2;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s3, f3[i]*fc[j1], pr, po, vf, vg, v, on);
        if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s3, f3[i+1]*fc[j2], pr, po, vf, vg, v, on);
		// advance time
		Std.rand2f(8.0, 10.0)::second => now;
	}
}

// cello
fun void cello(){
	while (true) {
        tuning4(tuning());
        volume() => float vol;
		Std.rand2(0, 2) => int i;
		Std.rand2(0, 3) => int j1;
		Std.rand2(0, 3) => int j2;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.02) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.05) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s4, f4[i]*fc[j1], pr, po, vf, vg, v, on);
        if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s4, f4[i+1]*fc[j2], pr, po, vf, vg, v, on);
		// advance time
		Std.rand2f(10.0, 12.0)::second => now;
	}
}

// sound generation
<<< "start" >>>;
spork ~ violin1();
spork ~ violin2();
spork ~ viola();
spork ~ cello();
while( true ) 1::second => now;
