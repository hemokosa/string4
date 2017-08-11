//
// string quartet op.1
//
// akihiro kubota
//
// coded by ChucK program
//

// 4 strings patch
Bowed s1 => pan2 p1 => JCRev r => dac;
Bowed s2 => pan2 p2 => r;
Bowed s3 => pan2 p3 => r;
Bowed s4 => pan2 p4 => r;

// initial settings
1.0 => s1.gain;
1.0 => s2.gain;
1.0 => s3.gain;
1.0 => s4.gain;

std.rand2f( 0, 1 ) => p1.pan;
std.rand2f( 0, 1 ) => p2.pan;
std.rand2f( 0, 1 ) => p3.pan;
std.rand2f( 0, 1 ) => p4.pan;
// print
<<< "---", "" >>>;
<<< "pan1:", p1.pan() >>>;
<<< "pan2:", p2.pan() >>>;
<<< "pan3:", p3.pan() >>>;
<<< "pan4:", p4.pan() >>>;

1.0 => r.gain;
.5 => r.mix;


// play a fragment
fun void playString(Bowed s) {
	while(true) {
		std.rand2f( 800, 810 ) => s.freq;
		std.rand2f( 0.0, 0.01 ) => s.bowPressure;
		std.rand2f( 0.0, 0.01 ) => s.bowPosition;
		std.rand2f( 0.0, 0.01 ) => s.vibratoFreq;
		std.rand2f( 0.0, 0.01 ) => s.vibratoGain;
		std.rand2f( 0.1, 0.25 ) => s.volume;
		1.0 => s.noteOn;
		// print
		<<< "---", s >>>;
		<<< "frequency:", s.freq() >>>;
		<<< "bow pressure:", s.bowPressure() >>>;
		<<< "bow position:", s.bowPosition() >>>;
		<<< "vibrato freq:", s.vibratoFreq() >>>;
		<<< "vibrato gain:", s.vibratoGain() >>>;
		<<< "volume:", s.volume() >>>;
		// proceed time
		std.rand2f( 20, 21 )::second => now;
	}
}

// event generation
Event e;
spork ~ playString(s1);
spork ~ playString(s2);
spork ~ playString(s3);
spork ~ playString(s4);
e => now;
