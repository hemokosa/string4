// name: CP.ck
// desc: configurable "clapping music" (Steve Reich)
// author: Jesus Gollonet (original)
//         Ge Wang (shreds and glottal pops)
//         Akihiro Kubota (modified)
// date: Winter 2016

// our patch
SndBuf clapper1 => JCRev r1  => dac.left;
SndBuf clapper2 => JCRev r2  => dac.right;
0.1 => r1.mix;
0.1 => r2.mix;

// load built-in sounds
"special:glot_ahh" => clapper1.read; 3.0 => clapper1.gain;
"special:glot_ahh" => clapper2.read; 3.0 => clapper2.gain;

// the full "clapping music" figure
[.5, .5, 1, .5, 1, 1, .5, 1 ] @=> float seq[];
//[.5, .5, 2, .5, 1, 1, .5, .1 ] @=> float seq[];
//[.5, 1, 2 ] @=> float seq[];

// length of quarter note
.4::second => dur quarter;
// how many measures per shift
3 => int shift_period;
// how much to shift by (in quarter notes)
.5 => float shift_factor;

// one clapper
fun void clap( SndBuf buffy, int max, float factor )
{
    1 => int shifts;
    
    // infinite time loop
    for( ; true; shifts++ )
    {
        // one measure
        for( 0 => int count; count < seq.cap(); count++ )
        {
            // set gain
            seq[count] * 3 => buffy.gain;
            // clap!
            0 => buffy.pos;
            // let time go by
            if( !max || shifts < max || count != (seq.cap() - 1) )
                seq[count]::quarter => now;
            else
            {
                <<< "shift!!!", "" >>>;
                seq[count]*factor*quarter => now;
                0 => shifts;
            }
        }
    }
}

// spork one clapper, shift every shift_period measures
spork ~ clap( clapper1, shift_period, shift_factor );
// spork, no shift
spork ~ clap( clapper2, 0, 0 );

// infinite time loop
while( true ) 1::day => now;
