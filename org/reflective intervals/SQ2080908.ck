//
// reflective ambient - string quartet no. 2 "The Art of Code"
//
// akihiro kubota (2008)
//

// initialize

<<< "setting" >>>;

// first violin
Bowed s1 => JCRev r1 => dac;

// second violin
Bowed s2 => JCRev r2 => dac;

// viola
Bowed s3 => JCRev r3 => dac;

// cello
Bowed s4 => JCRev r4 => dac;

// fft
adc => FFT fft =^ Centroid c => blackhole;

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
0.1 => r1.mix;
0.1 => r2.mix;
0.1 => r3.mix;
0.1 => r4.mix;

// fft parameters
1024 => fft.size;

// fft window
Windowing.hann(1024) => fft.window;

// compute srate
second / samp => float srate;


// reflective tuning
fun float tuning() {
    float base;
    float cent;
    c.upchuck();
    c.fval(0) * srate / 2 => cent;
    cent => base;
    if ( base >= 880.0) {
        while (base >= 880.0) { base / 2 => base; }
    }
    else if ( base < 440.0) {
        while (base < 440.0) { base * 2 => base; }
    }
    <<< "centroid:", cent, " base:", base >>>;
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


// scale
[1.0, Math.sqrt(2.0), 2.0] @=> float fc[];


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
}

// first violin
fun void violin1(){
	while (true) {
        tuning1(tuning());
		Std.rand2(0, 3) => int i;
		Std.rand2(0, 2) => int j;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s1, f1[i]*fc[j], pr, po, vf, vg, v, on);
 		// advance time
		Std.rand2f(4.0, 6.0)::second => now;
	}
}

// second violin
fun void violin2(){
	while (true) {
        tuning2(tuning());
		Std.rand2(0, 3) => int i;
		Std.rand2(0, 2) => int j;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s2, f2[i]*fc[j], pr, po, vf, vg, v, on);
		// advance time
		Std.rand2f(6.0, 8.0)::second => now;
	}
}

// viola
fun void viola(){
	while (true) {
        tuning3(tuning());
		Std.rand2(0, 3) => int i;
		Std.rand2(0, 2) => int j;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.1) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.1) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s3, f3[i]*fc[j], pr, po, vf, vg, v, on);
		// advance time
		Std.rand2f(8.0, 10.0)::second => now;
	}
}

// cello
fun void cello(){
	while (true) {
        tuning4(tuning());
		Std.rand2(0, 3) => int i;
		Std.rand2(0, 2) => int j;
		Std.rand2f(0.01, 0.5) => float pr;
		Std.rand2f(0.01, 0.02) => float po;
		Std.rand2f(0.01, 0.1) => float vf;
		Std.rand2f(0.01, 0.05) => float vg;
		Std.rand2f(0.01, 0.2) => float v;
        float on;
		if (Std.randf() > 0.5) { 0.0 => on; } else { 1.0 => on; }
		playString(s4, f4[i]*fc[j], pr, po, vf, vg, v, on);
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
