// Derived from srepmub's OpenSCAD train track library http://www.thingiverse.com/thing:43278 
// by MobyDisk (http://www.mobydisk.com)
//
// Copyright (C) 2013 - Licensed under the Creative Commons - Attribution - Share Alike license. 
// http://creativecommons.org/licenses/by-sa/3.0/

//
// These pieces are all f-f, which is most versatile.  Use http://www.thingiverse.com/thing:15165 for m-m connectors.
//

// Connector style 1 has a flattened round hole
// Connector style 2 has a perfectly round hole
CONNECTOR_STYLE=2;

// This is the radius of a circle of train track.
// - 189 mm is the common large size.
// - 189/2 mm is the common small size.
LARGE_RADIUS=189;
SMALL_RADIUS=189/2;

// A curve track is normally 1/8th of a circle.
// In one special case, it has to be a bit bigger so we use 1/7.8th of a circle.
NORMAL_CURVE_FRACTION = 8;
SPECIAL_CURVE_FRACTION = 7.8;

// The length of a "long" piece of track
LENGTH=205;

// Other constants you probably don't need to know or change
HIGH_DETAIL=200; // Number of sides used for $fn on curved track, tunnels

WIDTH=40.7;
HEIGHT=12.4;
BEVEL=1;
TRACK_WIDTH=6.2;
TRACK_HEIGHT=3;
TRACK_DIST=20;

BRIDGE_HEIGHT=64;
BRIDGE_R1=214;
BRIDGE_R2=220;

CONN_WIDTH=7.3;
CONN_R=6.5;
CONN_BEVEL=1.7;
CONN_DEPTH=17.5;

CONN_M_R=5.75;
CONN_M_WIDTH=6.5;
CONN_M_DEPTH=17;

SUPPORT_SIDE=7.2;
SUPPORT_THICK=33;
SUPPORT_WIDTH=WIDTH+1+2*SUPPORT_SIDE;

TUNNEL_R=28.5;
TUNNEL_H=65;
TUNNEL_LEN=135;
TUNNEL_THICK=2.1;
TUNNEL_SIDE_W=4.3;

module track_single() {
    square([TRACK_WIDTH,TRACK_HEIGHT]);
}

module track() {
    translate([WIDTH/2-TRACK_WIDTH-TRACK_DIST/2,HEIGHT-TRACK_HEIGHT,0])
        track_single();
    translate([WIDTH/2+TRACK_DIST/2,HEIGHT-TRACK_HEIGHT,0])
        track_single();
}

module body() {
    difference() {
        polygon(points=[[BEVEL,0],[WIDTH-BEVEL,0],[WIDTH,BEVEL],[WIDTH,HEIGHT-BEVEL],[WIDTH-BEVEL,HEIGHT],[BEVEL,HEIGHT],[0,HEIGHT-BEVEL],[0,BEVEL]]);
        track();
    }
}

////////////////////////////////////////////////////////////////////////////////
// A single curved section of track
// - radius, should be either LARGE_RADIUS or LARGE_RADIUS/2
// - fraction, normally 8.  This creates a curve that is 1/8th of a circle.
////////////////////////////////////////////////////////////////////////////////

//The curved track starts along the positive x axis
//and curves along the XY plane toward the positive Y axis
module curved_track_mf(radius=LARGE_RADIUS, fraction=NORMAL_CURVE_FRACTION) {
    difference() {
            rotate_extrude(convexity = 10, $fn=HIGH_DETAIL, angle=360/fraction)
            translate([radius, 0, 0])
            
            //the cross-section of the track includes rails on the top and bottom
            difference() {
                //the default body() only has track cut out of the front.
            //This part adds track to the bottom
                body();
                translate([0,-HEIGHT+TRACK_HEIGHT,0])
                track();
            }
            //This first connector is at the positive x axis
            translate([radius+WIDTH/2,0,5*HEIGHT])
       
            rotate([90,0,90])
            connector_f();
        
    }
        
    //male connector at the other end of the track
        rotate([0,0,360/fraction]){
            translate([radius+WIDTH/2,0,0])
            //rotate([0,90,0])
            connector_m();
        }
        
    
}


module curved_track(radius=LARGE_RADIUS, fraction=NORMAL_CURVE_FRACTION) {
    translate([0,-radius,0])
    difference() {
        rotate([0,0,-360/fraction])
        difference() {
            rotate_extrude(convexity = 10, $fn=HIGH_DETAIL)
            translate([radius, 0, 0])
            difference() {
                body();
                translate([0,-HEIGHT+TRACK_HEIGHT,0])
                track();
            }
            translate([0,-500,-500])
            cube([1000,1000,1000]);
            translate([0,radius+WIDTH/2,5*HEIGHT])
            mirror([1,0,0])
            rotate([90,0,0])
            connector_f();
        }

        translate([0,radius+WIDTH/2,5*HEIGHT])
        rotate([90,0,0])
        connector_f();
        translate([-1000,-500,-500])
        cube([1000,1000,1000]);
    }
}

// One of the two key components of the rising_track
module round_quart() {
    intersection() {
        translate([0,0,WIDTH])
        rotate_extrude(convexity = 10, $fn = 200)
            translate([BRIDGE_R1, 0, 0])
            rotate([0,0,-90])
            translate([0,-HEIGHT,0])
                body();

        cube([1000,1000,1000]);
    }
}

// The second of the two key components of the rising_track
module round_quart_2() {
    intersection() {
        translate([0,0,WIDTH])
        rotate_extrude(convexity = 10, $fn = 200)
            translate([BRIDGE_R2, 0, 0])
            rotate([0,0,-90])
                mirror([0,1,0])
                translate([0,-HEIGHT,0])
                body();

            cube([1000,1000,1000]);
    }
}


////////////////////////////////////////////////////////////////////////////////
// This is the rising part of the bridge, turned sideways so it can be printed.
// It is also a component in the full bridge.
////////////////////////////////////////////////////////////////////////////////
module rising_track() {
    intersection() {
        translate([0,-BRIDGE_R1+BRIDGE_HEIGHT,0])
        round_quart();
        cube([LENGTH/2,BRIDGE_HEIGHT,WIDTH]);
    }

    intersection() {
        translate([LENGTH,BRIDGE_R2+HEIGHT,0])
        mirror([1,1,0])
        round_quart_2();
        translate([LENGTH/2,0,0])
        cube([LENGTH/2,BRIDGE_HEIGHT,WIDTH]);
    } 
}

module bridge_hole_part(t, w,h,w2,h2) {
    hull() {
        cylinder(0.01,r=w/2);
        translate([0,0,t])
            cylinder(0.01,r=w2/2);
    }  
    hull() {
        translate([-w/2,0,0])
            cube([w,h-w/2,0.01]);
        translate([-w2/2,0,t])
            cube([w2,h2-w2/2,0.01]);
    } 
}

module bridge_hole(w,h) {
    mirror([0,1,0])
    translate([0,-h+w/2+0.01,BEVEL]) {
        bridge_hole_part(WIDTH-2*BEVEL,w,h,w,h);
        translate([0,0,-BEVEL])
            bridge_hole_part(BEVEL,w+BEVEL,h+BEVEL,w,h);
        translate([0,0,WIDTH-2*BEVEL])
            bridge_hole_part(BEVEL,w,h,w+BEVEL,h+BEVEL); 
    }
}

////////////////////////////////////////////////////////////////////////////////
// This track that goes up or down a level, with no tunnels
////////////////////////////////////////////////////////////////////////////////
module bridge_body() {
    rising_track();
    intersection() {
        translate([0,-BRIDGE_R2+BRIDGE_HEIGHT-HEIGHT/2,0])
        cylinder(WIDTH,r=BRIDGE_R2, $fn=HIGH_DETAIL);
        translate([0,BEVEL,0])
        cube([LENGTH,BRIDGE_HEIGHT,WIDTH]);
    }
    translate([0,BEVEL,0])
    cube([LENGTH,HEIGHT-TRACK_HEIGHT-BEVEL,WIDTH]);
    translate([130,BEVEL,0])
    cube([25,HEIGHT,WIDTH]);
    hull() {
        translate([0,0,BEVEL])
        cube([LENGTH,0.01,WIDTH-2*BEVEL]);
        translate([0,BEVEL,0])
        cube([LENGTH,0.01,WIDTH]);
    }
}

////////////////////////////////////////////////////////////////////////////////
// This track that goes up or down a level and has tunnels under it
////////////////////////////////////////////////////////////////////////////////
module bridge_track() {
    rotate([90,0,-90])
    difference() {
        bridge_body();
        translate([84,0,0])
        bridge_hole(44.5,30);
        bridge_hole(68,BRIDGE_HEIGHT-HEIGHT);
        translate([-0.01,9*HEIGHT,WIDTH/2])
        connector_f();
        translate([LENGTH+0.01,9*HEIGHT,WIDTH/2])
        mirror([1,0,0])
        connector_f();
    }
}

module conn_bevel() {
    translate([WIDTH/2-BEVEL,0,0])
    linear_extrude(height=10*HEIGHT)
        polygon(points=[[0,-0.01],[BEVEL+0.01,BEVEL],[BEVEL+0.01,-0.01]]);
}


module connector_m() {
    //the shaft
    translate([-CONN_M_WIDTH/2,0,0])
        cube([CONN_M_WIDTH, CONN_M_DEPTH-CONN_M_R, HEIGHT]);
    
    //the circular hole
    translate([0,CONN_M_DEPTH-CONN_M_R,0])
        cylinder(HEIGHT,r=CONN_M_R);
}

module connector_f() {
    rotate([90,90,0])
    {
    
    //the trapezoid bevel shape at the end of the hole 
    hull() {
        translate([-(CONN_WIDTH+2*CONN_BEVEL)/2,-0.01,0])
            cube([CONN_WIDTH+2*CONN_BEVEL, 0.01, 10*HEIGHT]);
        translate([-CONN_WIDTH/2,CONN_BEVEL,0])
            cube([CONN_WIDTH, 0.01, 10*HEIGHT]);
    }

    //the shaft
    translate([-CONN_WIDTH/2,0,0])
        cube([CONN_WIDTH, CONN_DEPTH-CONN_R, 10*HEIGHT]);
    
    //the circular hole
    translate([0,CONN_DEPTH-CONN_R,0])
    //translate([0,CONN_DEPTH-CONN_R+1.1,0])
        cylinder(10*HEIGHT,r=CONN_R);


    
    //the outer corner edges of the track 
    conn_bevel();
    mirror([1,0,0])
        conn_bevel();
    } 
}

////////////////////////////////////////////////////////////////////////////////
// Normal straight piece
////////////////////////////////////////////////////////////////////////////////




module straight_track(len=LENGTH) {
    rotate([90,0,0])
    difference() {
        linear_extrude(height=len)
            body();
        translate([WIDTH/2,5*HEIGHT,len])
        rotate([0,90,0])
            connector_f();
        mirror([0,0,1])
        translate([WIDTH/2,5*HEIGHT,0])
        rotate([0,90,0])
            connector_f();
    }
}


module straight_track(len=LENGTH) {
    rotate([90,0,0])
    
    difference() {
        linear_extrude(height=len)
        difference(){
            //the default body() only has track cut out of the front.
            //This part adds track to the bottom
            body();
            translate([0,-HEIGHT+TRACK_HEIGHT,0])
            track();
        }
        translate([WIDTH/2,5*HEIGHT,len])
        rotate([0,90,0])
            connector_f();
        
    }

        translate([WIDTH/2,0,0])

            connector_m();

}


////////////////////////////////////////////////////////////////////////////////
// This creates two tracks that cross over each other at 90 degrees like a
// plus sign.
////////////////////////////////////////////////////////////////////////////////
module crossing_track(len) {
    difference() {
        union() {
            translate([-WIDTH/2,len/2,0])
                straight_track(len);
            rotate([0,0,90])
                translate([-WIDTH/2,len/2,0])
                    straight_track(len);
        }
        translate([-len,-WIDTH/2,0.01])
            rotate([90,0,90])
                linear_extrude(height=len*2)
                    track();
        translate([-WIDTH/2,len,0.01]) 
            rotate([90,0,0])
                linear_extrude(height=len*2)
                    track();
    }
}

// This is the negative space part of the track.  It is called from curved_and_straight_track()
module curved_and_straight_part(radius,length) {
    translate([0,-0.01,0])
    rotate([90,0,0])
    linear_extrude(height=length+0.02)
        track();
    translate([-radius,0,0])
    rotate_extrude(convexity = 10, $fn = 200)
    translate([radius, 0, 0])
        track();
}

////////////////////////////////////////////////////////////////////////////////
// A junction that goes straight and splits at a curve
// NOTE: When making a piece with r=LARGE_RADIUS/2, set the angle to 7.8 instead of 8
//       Don't worry: there is enough play that they still hook together.
////////////////////////////////////////////////////////////////////////////////
module curved_and_straight_track(r=LARGE_RADIUS,l=LENGTH,a=NORMAL_CURVE_FRACTION) {
    difference() {
        union() {
            straight_track(l);
            rotate([0,0,-90])
            curved_track(r, a);
        }
        translate([0,0,0.01])
        curved_and_straight_part(r,l);
        translate([0,0,-HEIGHT+TRACK_HEIGHT-0.01])
        curved_and_straight_part(r,l);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Curved and straight junction with 1/2 radius
////////////////////////////////////////////////////////////////////////////////
module curved_and_straight_track_small()
{
	curved_and_straight_track(LARGE_RADIUS/2,LENGTH/2, SPECIAL_CURVE_FRACTION);
}

// This is the negative space part of the track.  It is called from triple_track()
module triple_part(radius,length) {
    translate([0,-0.01,0])
    rotate([90,0,0])
    linear_extrude(height=length+0.02)
        track();

    translate([-radius,0,0])
    rotate_extrude(convexity = 10, $fn = 200)
    translate([radius, 0, 0])
        track();

	mirror([1,0,0])
    translate([-radius-WIDTH,0,0])
    rotate_extrude(convexity = 10, $fn = 200)
    translate([radius, 0, 0])
        track();
}

////////////////////////////////////////////////////////////////////////////////
// A junction that goes straight and splits into curves in both directions
// NOTE: When making a piece with r=LARGE_RADIUS/2, set the angle to 7.8 instead of 8
//       Don't worry: there is enough play that they still hook together.
////////////////////////////////////////////////////////////////////////////////
module triple_track(r=LARGE_RADIUS,l=LENGTH,a=NORMAL_CURVE_FRACTION) {
    difference() {
        union() {
            straight_track(l);
            rotate([0,0,-90])
            curved_track(r, a);
            rotate([0,0,-90])
		   mirror([0,1,0])
		   translate([0,-WIDTH,0])
            curved_track(r, a);
        }
        translate([0,0,0.01])
        triple_part(r,l);
        translate([0,0,-HEIGHT+TRACK_HEIGHT-0.01])
        triple_part(r,l);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Triple track with the 1/2 radius
////////////////////////////////////////////////////////////////////////////////
module triple_track_small()
{
	triple_track(LARGE_RADIUS/2,LENGTH/2,SPECIAL_CURVE_FRACTION);
}

// This is the negative space part of the track.  It is called from double_curve_track()
module double_curve_part(radius) {
    translate([-radius,0,0])
    rotate_extrude(convexity = 10, $fn = 200)
    translate([radius, 0, 0])
        track();

	mirror([1,0,0])
    translate([-radius-WIDTH,0,0])
    rotate_extrude(convexity = 10, $fn = 200)
    translate([radius, 0, 0])
        track();
}

////////////////////////////////////////////////////////////////////////////////
// A junction that splits into curves in both directions
// NOTE: When making a piece with r=LARGE_RADIUS/2, set the angle to 7.8 instead of 8
//       Don't worry: there is enough play that they still hook together.
////////////////////////////////////////////////////////////////////////////////
module double_curve_track(r=LARGE_RADIUS,a=NORMAL_CURVE_FRACTION) 
{
    difference() {
        union() {
            rotate([0,0,-90])
            curved_track(r, a);
            rotate([0,0,-90])
            mirror([0,1,0])
            translate([0,-WIDTH,0])
            curved_track(r, a);
        }
        translate([0,0,0.01])
        double_curve_part(r);
        translate([0,0,-HEIGHT+TRACK_HEIGHT-0.01])
        double_curve_part(r);
    }

}

////////////////////////////////////////////////////////////////////////////////
// Doubly curved track with the 1/2 radius
////////////////////////////////////////////////////////////////////////////////
module double_curve_track_small()
{
	double_curve_track(LARGE_RADIUS/2,SPECIAL_CURVE_FRACTION);
}

module support_halve() {
    linear_extrude(height=SUPPORT_THICK)
        polygon(points=[[0,HEIGHT-BEVEL],[WIDTH/2+0.5,HEIGHT-BEVEL],[WIDTH/2+0.5,BEVEL],[WIDTH/2+0.5+BEVEL,0],[SUPPORT_WIDTH/2-BEVEL,0],[SUPPORT_WIDTH/2,BEVEL],[SUPPORT_WIDTH/2,BRIDGE_HEIGHT-HEIGHT-BEVEL],[SUPPORT_WIDTH/2-BEVEL,BRIDGE_HEIGHT-HEIGHT],[WIDTH/2,BRIDGE_HEIGHT-HEIGHT],[WIDTH/2,BRIDGE_HEIGHT-2*BEVEL],[WIDTH/2-BEVEL,BRIDGE_HEIGHT-BEVEL],[0,BRIDGE_HEIGHT-BEVEL]]);
}

////////////////////////////////////////////////////////////////////////////////
// A support that can be used to raise a straight track up to make a bridge.
// Similar to http://www.thingiverse.com/thing:34194
////////////////////////////////////////////////////////////////////////////////
module support_girder() {
    translate([0,-BRIDGE_HEIGHT-BEVEL,0]) {
        support_halve();
        mirror([1,0,0])
            support_halve();
    }
}

module tunnel_shape(sub) {
    translate([TUNNEL_H-TUNNEL_R,0,0])
        circle(TUNNEL_R-sub, $fn=HIGH_DETAIL);
    translate([0,-TUNNEL_R+sub,0])
        square([TUNNEL_H-TUNNEL_R,TUNNEL_R*2-2*sub]);
}

module tunnel_halve_neg() {
    translate([0,0,0])
        linear_extrude(height=TUNNEL_THICK)
            tunnel_shape(2*TUNNEL_THICK);
    hull() {
        translate([0,0,TUNNEL_THICK])
            linear_extrude(height=0.01)
                tunnel_shape(2*TUNNEL_THICK);
        translate([0,0,2*TUNNEL_THICK])
            linear_extrude(height=0.01)
                tunnel_shape(TUNNEL_THICK);
    }
    translate([0,0,2*TUNNEL_THICK])
        linear_extrude(height=TUNNEL_LEN/2-2*TUNNEL_THICK+0.01)
            tunnel_shape(TUNNEL_THICK);
}

module tunnel_halve_pos() {
    linear_extrude(height=TUNNEL_LEN/2)
        tunnel_shape(0);
}

module tunnel_halve() {
    translate([0,0,-TUNNEL_LEN/2]) {
        difference() {
            tunnel_halve_pos();
            tunnel_halve_neg();
        }
        translate([0,TUNNEL_R-TUNNEL_THICK,0])
            linear_extrude(height=TUNNEL_LEN/2)
                square([TUNNEL_THICK, TUNNEL_SIDE_W]);
        translate([0,-TUNNEL_R+TUNNEL_THICK-TUNNEL_SIDE_W,0])
            linear_extrude(height=TUNNEL_LEN/2)
                square([TUNNEL_THICK, TUNNEL_SIDE_W]);
    }
}

module tunnel() {
    translate([0,-TUNNEL_LEN/2,0])
    mirror([0,0,1])
    rotate([90,90,0]) {
        tunnel_halve();
        mirror([0,0,1])
            tunnel_halve();
    }
}

////////////////////////////////////////////////////////////////////////////////
// Preview one of each track, but only in one size for each
////////////////////////////////////////////////////////////////////////////////
module all_bricks() 
{

    translate([-WIDTH*5.5,-LENGTH/2,0])
    support_girder();

    translate([-WIDTH*5.5,LENGTH/2,0])
    tunnel();

	// Large radius curved track
    translate([-WIDTH*1.5,-LENGTH*3/4,0])
    rotate([0,0,112])
    curved_track(LARGE_RADIUS, NORMAL_CURVE_FRACTION); // inner radius, Nth part

	// Small radius curved track
	translate([-WIDTH*3,-LENGTH*3/4,0])
    rotate([0,0,112])
    curved_track(SMALL_RADIUS, NORMAL_CURVE_FRACTION); // inner radius, Nth part

	// Could use rising_track() instead
    bridge_track();

	// Various standard sizes of track
    translate([WIDTH/2,0,0])
        straight_track(LENGTH/2);
    translate([WIDTH*2,0,0])
        straight_track(LENGTH*3/4);
    translate([WIDTH*3.5,0,0])
        straight_track(LENGTH);
		
	// This is almost the smallest possible reasonable track - very useful as a f-f adapter
	translate([WIDTH/2,-LENGTH*0.81,0])
        straight_track(LENGTH/5.5);

    translate([WIDTH*6,-LENGTH/4,0])
    crossing_track(LENGTH/2);
    translate([WIDTH*8,0,0])
    curved_and_straight_track();

    translate([WIDTH*8,LENGTH*2/3,0])
    curved_and_straight_track_small();

    translate([WIDTH*11,0,0])
		double_curve_track();
    translate([WIDTH*11,LENGTH*2/3,0])
		double_curve_track_small();

    translate([WIDTH*15,0,0])
		triple_track();
    translate([WIDTH*15,LENGTH*2/3,0])
		triple_track_small();
}

module curved_tracks(radius, fraction, n) {
    for( i = [0:n-1] )
        rotate([0,0,(360/fraction)*(i+1)])
            translate([0,radius,0])
                curved_track(radius, fraction);
}

////////////////////////////////////////////////////////////////////////////////
// Put it all together to make something interesting!
////////////////////////////////////////////////////////////////////////////////
module demo_track() {
    translate([-LARGE_RADIUS-WIDTH/2,-LARGE_RADIUS-WIDTH/2,0])
        curved_tracks(LARGE_RADIUS, 8, 6);
    translate([-WIDTH/2,-LENGTH/4-2,0])
        straight_track(LENGTH*3/4);
    crossing_track(LENGTH/2);
    translate([-LENGTH*3/4-LENGTH/4-2,-WIDTH/2,0])
        rotate([0,0,90])
            straight_track(LENGTH*3/4);

    translate([LENGTH*5/4,-WIDTH/2,0])
        rotate([0,0,-90])
            bridge_track();

    translate([LENGTH*5/4,-WIDTH/2,BRIDGE_HEIGHT-HEIGHT])
        rotate([0,0,90])
            straight_track(LENGTH);

    translate([LENGTH*5/4+SUPPORT_THICK/2,0,0])
        rotate([-90,0,90])
            support_girder();

    translate([LENGTH*9/4+SUPPORT_THICK/2,0,0])
        rotate([-90,0,90])
            support_girder();

    translate([LENGTH*9/4,-WIDTH/2,0])
        mirror([1,0,0])
        rotate([0,0,-90])
            bridge_track();

    translate([-WIDTH/2,LENGTH*5/4,0])
        straight_track(LENGTH);

    translate([0,TUNNEL_LEN+LENGTH/4+(LENGTH-TUNNEL_LEN)/2,0])
        tunnel();

    translate([-WIDTH/2,LENGTH*5/4,0])
        mirror([0,1,0])
            curved_and_straight_track();
}

//all_bricks();

//curved_track();
//curved_track(LARGE_RADIUS/2, 8);  // inner radius, Nth part
//curved_and_straight_track();
//curved_and_straight_track_small();
//double_curve_track();
//double_curve_track_small();
//triple_track();
//triple_track_small();
//bridge_body();
//rising_track();
//bridge_track();
//straight_track(LENGTH);
//straight_track_mf(LENGTH);
//straight_track(LENGTH/5.5);
//straight_track_mf(LENGTH/5.5);
//crossing_track(LENGTH/2);
//support_girder();
//tunnel();
//demo_track();

//straight_track_mf(20);
curved_track_mf(LARGE_RADIUS/2, 4);
