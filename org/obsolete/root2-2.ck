//
// string quartet op.1
//
// akihiro kubota (2006)
//

// define instruments

// violin1
Bowed s1 => pan2 p1 => NRev r => dac;
Bowed s1d => p1;

// violin2
Bowed s2 => pan2 p2 => r;
Bowed s2d => p2;

// viola
Bowed s3 => pan2 p3 => r;
Bowed s3d => p3;

// cello
Bowed s4 => pan2 p4 => r;
Bowed s4d => p4;

// gain settings
1.0 => s1.gain;
1.0 => s2.gain;
1.0 => s3.gain;
1.0 => s4.gain;

1.0 => s1d.gain;
1.0 => s2d.gain;
1.0 => s3d.gain;
1.0 => s4d.gain;

// pan settings
std.rand2f( 0, 1 ) => p1.pan;
std.rand2f( 0, 1 ) => p2.pan;
std.rand2f( 0, 1 ) => p3.pan;
std.rand2f( 0, 1 ) => p4.pan;
<<< "---", "" >>>;
<<< "pan1:", p1.pan() >>>;
<<< "pan2:", p2.pan() >>>;
<<< "pan3:", p3.pan() >>>;
<<< "pan4:", p4.pan() >>>;

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
[1.0, math.sqrt(2.0), 2.0] @=> float fc[];


// bow parameters
0.5 => float pr1; 0.9 => float pr2;
0.01 => float po1; 0.02 => float po2;
0.01 => float vf1; 0.1 => float vf2;
0.01 => float vg1; 0.1 => float vg2;
0.1 => float v1; 0.2 => float v2;

0.5 => float onoff;


// play a string
fun void playString(Bowed s, float f, float pr, float po, float vf, float vg, float v, float on) {
	if (f < 50.0) f * 2 => f;
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
	int i; int j; float pr; float po; float vf; float vg; float v; float on;
	for( 0 => int n; n < 6 ; n++ ) {
		std.rand2(0, 3) => i;
		std.rand2(0, 2) => j;
		std.rand2f(pr1, pr2) => pr;
		std.rand2f(po1, po2) => po;
		std.rand2f(vf1, vf2) => vf;
		std.rand2f(vg1, vg2) => vg;
		std.rand2f(v1, v2) => v;
		if (std.randf() > onoff) { 0.0 => on; } else { 1.0 => on; }
		playString(s1, f1[i]*fc[j], pr, po, vf, vg, v, on);
		if (i != 3 && j == 0) { playString(s1d, f1[i+1]*std.rand2(0, 2), pr, po, vf, vg, v, on); } 
		// advance time
		std.rand2f(4.0, 6.0)::second => now;
	}
	playString(s1, f1[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s1d, f1[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// violin2
fun void violin2(){
	int i; int j; float pr; float po; float vf; float vg; float v; float on;
	for( 0 => int n; n < 5 ; n++ ) {
		std.rand2(0, 3) => i;
		std.rand2(0, 2) => j;
		std.rand2f(pr1, pr2) => pr;
		std.rand2f(po1, po2) => po;
		std.rand2f(vf1, vf2) => vf;
		std.rand2f(vg1, vg2) => vg;
		std.rand2f(v1, v2) => v;
		if (std.randf() > onoff) { 0.0 => on; } else { 1.0 => on; }
		playString(s2, f2[i]*fc[j], pr, po, vf, vg, v, on);
		if (i != 3 && j == 0) { playString(s2d, f2[i+1]*std.rand2(0, 2), pr, po, vf, vg, v, on); } 
		// advance time
		std.rand2f(5.0, 7.0)::second => now;
	}
	playString(s2, f2[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s2d, f2[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// viola
fun void viola(){
	int i; int j; float pr; float po; float vf; float vg; float v; float on;
	for( 0 => int n; n < 4 ; n++ ) {
		std.rand2(0, 3) => i;
		std.rand2(0, 2) => j;
		std.rand2f(pr1, pr2) => pr;
		std.rand2f(po1, po2) => po;
		std.rand2f(vf1, vf2) => vf;
		std.rand2f(vg1, vg2) => vg;
		std.rand2f(v1, v2) => v;
		if (std.randf() > onoff) { 0.0 => on; } else { 1.0 => on; }
		playString(s3, f3[i]*fc[j], pr, po, vf, vg, v, on);
		if (i != 3 && j == 0) { playString(s3d, f3[i+1]*std.rand2(0, 2), pr, po, vf, vg, v, on); } 
		// advance time
		std.rand2f(6.5, 8.5)::second => now;
	}
	playString(s3, f3[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
	playString(s3d, f3[0]*fc[0], 0.01, 0.01, 0.01, 0.01, 0.0, 0.0);
}

// cello
fun void cello(){
	int i; int j; float pr; float po; float vf; float vg; float v; float on;
	for( 0 => int n; n < 3 ; n++ ) {
		std.rand2(0, 3) => i;
		std.rand2(0, 2) => j;
		std.rand2f(pr1, pr2) => pr;
		std.rand2f(po1, po2) => po;
		std.rand2f(vf1, vf2) => vf;
		std.rand2f(vg1, vg2) => vg;
		std.rand2f(v1, v2) => v;
		if (std.randf() > onoff) { 0.0 => on; } else { 1.0 => on; }
		playString(s4, f4[i]*fc[j], pr, po, vf, vg, v, on);
		if (i != 3 && j == 0) { playString(s4d, f4[i+1]*std.rand2(0, 2), pr, po, vf, vg, v, on); } 
		// advance time
		std.rand2f(9.0, 11.0)::second => now;
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
	std.rand2f(36.0, 40.0)::second => now;
}