//
// quartet for algorithmic strings op.6.0
// akihiro kubota, 2017
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
0.5 => r.mix;


// play a fragment
fun void playString(Bowed s, float f1, float f2, float pr1, float pr2, float po1, float po2, float vf1, float vf2, float vg1, float vg2, float v1, float v2, float d1, float d2) {
    while(true) {
        std.rand2f( f1, f2 ) => s.freq;
        std.rand2f( pr1, pr2 ) => s.bowPressure;
        std.rand2f( po1, po2 ) => s.bowPosition;
        std.rand2f( vf1, vf2 ) => s.vibratoFreq;
        std.rand2f( vg1, vg2 ) => s.vibratoGain;
        std.rand2f( v1, v2 ) => s.volume;
        1.0 => s.noteOn;
        std.rand2f( d1, d2 )::second => dur d;
        // print
        <<< "---", s >>>;
        <<< "frequency:", s.freq() >>>;
        <<< "bow pressure:", s.bowPressure() >>>;
        <<< "bow position:", s.bowPosition() >>>;
        <<< "vibrato freq:", s.vibratoFreq() >>>;
        <<< "vibrato gain:", s.vibratoGain() >>>;
        <<< "volume:", s.volume() >>>;
        <<< "duration:", d >>>;
        // proceed time
        d => now;
    }
}

// event generation
Event e;
spork ~ playString(s1, 440, 450, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 20.0, 21.0);
spork ~ playString(s2, 430, 440, 0.01, 0.1, 0.9, 0.99, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 20.0, 21.0);
spork ~ playString(s3, 210, 220, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 15.0, 16.0);
spork ~ playString(s4, 220, 230, 0.01, 0.1, 0.9, 0.99, 0.01, 0.1, 0.01, 0.1, 0.01, 0.1, 15.0, 16.0);
e => now;
