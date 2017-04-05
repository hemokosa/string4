//
// string quartet op.1 :: monaural ambient version
//
// akihiro kubota (2006)
//

// define instruments

// violin1
Bowed s1 => JCRev r => Gain g => dac;
Bowed s1d => r;

// violin2
Bowed s2 => r;
Bowed s2d => r;

// viola
Bowed s3 => r;
Bowed s3d => r;

// cello
Bowed s4 => r;
Bowed s4d => r;

// gain settings
1.5 => g.gain;

1.0 => s1.gain;
1.0 => s2.gain;
1.0 => s3.gain;
1.0 => s4.gain;

1.0 => s1d.gain;
1.0 => s2d.gain;
1.0 => s3d.gain;
1.0 => s4d.gain;

// reverb settings
1.0 => r.gain;
0.5 => r.mix;

// open string frequency
440.0 => float base;

base / 2 / 1.5 / 1.5 => float f11;
base / 2 / 1.5 => float f12;
base / 2 => float f13;
base / 2 * 1.5 => float f14;

base / 2 / 1.5 / 1.5 => float f21;
base / 2 / 1.5 => float f22;
base / 2 => float f23;
base / 2 * 1.5 => float f24;

base / 2 / 1.5 / 1.5 / 1.5 => float f31;
base / 2 / 1.5 / 1.5 => float f32;
base / 2 / 1.5 => float f33;
base / 2 => float f34;

base / 2 / 2 / 1.5 / 1.5 / 1.5 => float f41;
base / 2 / 2 / 1.5 / 1.5 => float f42;
base / 2 / 2 / 1.5 => float f43;
base / 2 / 2 => float f44;

[f11, f12, f13, f14] @=> float f1[];
[f21, f22, f23, f24] @=> float f2[];
[f31, f32, f33, f34] @=> float f3[];
[f41, f42, f43, f44] @=> float f4[];

// position (scale)
[1.0, Math.sqrt(2.0), 2.0] @=> float fc[];


// bow parameters
0.1 => float pr1; 0.9 => float pr2;
0.01 => float po1; 0.1 => float po2;
0.01 => float vf1; 0.1 => float vf2;
0.01 => float vg1; 0.1 => float vg2;

0.0 => float onoff;
0.0 => float onoffd;

// play a string
fun void playString(Bowed s, float f, float pr, float po, float vf, float vg, float v, float on) {
	if (f < 0.0) 0.0 => on;
	if (f < 45) f * 2 => f;
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

// violin1
fun void violin1(){
	int i; int j; int id; int jd; float pr; float po; float vf; float vg; float on; float ond;
	for( 0 => int n; n < 4 ; n++ ) {
		Std.rand2(0, 3) => i;
		Std.rand2(0, 2) => j;
		Std.rand2f(pr1, pr2) => pr;
		Std.rand2f(po1, po2) => po;
		Std.rand2f(vf1, vf2) => vf;
		Std.rand2f(vg1, vg2) => vg;
		if (Std.randf() > onoff) { 0.0 => on; 0.0 => ond; } 
			else { 1.0 => on; if (Std.randf() > onoffd) { 0.0 => ond; } else { 1.0 => ond; } }
		playString(s1, f1[i]*fc[j], pr, po, vf, vg, on, on);
		if (i == 0) { i+1 => id; }
			else {	if (i == 3) { i-1 => id; }
				else { if (Std.randf() > 0.0) { i+1 => id; }
					else { i-1 => id; } } }
		Std.rand2(0, 2) => jd;
		playString(s1d, f1[id]*fc[jd], pr, po, vf, vg, ond, ond);
		// advance time
		Std.rand2f(28.0, 32.0)::second => now;
	}
	playString(s1, f1[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s1d, f1[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// violin2
fun void violin2(){
	int i; int j; int id; int jd; float pr; float po; float vf; float vg; float on; float ond;
	for( 0 => int n; n < 10 ; n++ ) {
		Std.rand2(0, 3) => i;
		Std.rand2(0, 2) => j;
		Std.rand2f(pr1, pr2) => pr;
		Std.rand2f(po1, po2) => po;
		Std.rand2f(vf1, vf2) => vf;
		Std.rand2f(vg1, vg2) => vg;
		if (Std.randf() > onoff) { 0.0 => on; 0.0 => ond; } 
			else { 1.0 => on; if (Std.randf() > onoffd) { 0.0 => ond; } else { 1.0 => ond; } }
		playString(s2, f2[i]*fc[j], pr, po, vf, vg, on, on);
		if (i == 0) { i+1 => id; }
			else {	if (i == 3) { i-1 => id; }
				else { if (Std.randf() > 0.0) { i+1 => id; }
					else { i-1 => id; } } }
		Std.rand2(0, 2) => jd;
		playString(s2d, f2[id]*fc[jd], pr, po, vf, vg, ond, ond);
		// advance time
		Std.rand2f(10.0, 12.0)::second => now;
	}
	playString(s2, f2[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s2d, f2[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// viola
fun void viola(){
	int i; int j; int id; int jd; float pr; float po; float vf; float vg; float on; float ond;
	for( 0 => int n; n < 8 ; n++ ) {
		Std.rand2(0, 3) => i;
		Std.rand2(0, 2) => j;
		Std.rand2f(pr1, pr2) => pr;
		Std.rand2f(po1, po2) => po;
		Std.rand2f(vf1, vf2) => vf;
		Std.rand2f(vg1, vg2) => vg;
		if (Std.randf() > onoff) { 0.0 => on; 0.0 => ond; } 
			else { 1.0 => on; if (Std.randf() > onoffd) { 0.0 => ond; } else { 1.0 => ond; } }
		playString(s3, f3[i]*fc[j], pr, po, vf, vg, on, on);
		if (i == 0) { i+1 => id; }
			else {	if (i == 3) { i-1 => id; }
				else { if (Std.randf() > 0.0) { i+1 => id; }
					else { i-1 => id; } } }
		Std.rand2(0, 2) => jd;
		playString(s3d, f3[id]*fc[jd], pr, po, vf, vg, ond, ond);
		// advance time
		Std.rand2f(13.0, 17.0)::second => now;
	}
	playString(s3, f3[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s3d, f3[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// cello
fun void cello(){
	int i; int j; int id; int jd; float pr; float po; float vf; float vg; float on; float ond;
	for( 0 => int n; n < 6 ; n++ ) {
		Std.rand2(0, 3) => i;
		Std.rand2(0, 2) => j;
		Std.rand2f(pr1, pr2) => pr;
		Std.rand2f(po1, po2) => po;
		Std.rand2f(vf1, vf2) => vf;
		Std.rand2f(vg1, vg2) => vg;
		if (Std.randf() > onoff) { 0.0 => on; 0.0 => ond; } 
			else { 1.0 => on; if (Std.randf() > onoffd) { 0.0 => ond; } else { 1.0 => ond; } }
		playString(s4, f4[i]*fc[j], pr, po, vf, vg, on, on);
		if (i == 0) { i+1 => id; }
			else {	if (i == 3) { i-1 => id; }
				else { if (Std.randf() > 0.0) { i+1 => id; }
					else { i-1 => id; } } }
		Std.rand2(0, 2) => jd;
		playString(s4d, f4[id]*fc[jd], pr, po, vf, vg, ond, ond);
		// advance time
		Std.rand2f(18.0, 22.0)::second => now;
	}
	playString(s4, f4[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s4d, f4[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// sound generation
while(true){
	spork ~ violin1();
	spork ~ violin2();
	spork ~ viola();
	spork ~ cello();
	Std.rand2f(175.0, 185.0)::second => now;
}