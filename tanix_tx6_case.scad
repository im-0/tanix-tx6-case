/*
 *  Parametric 3D printed case for Tanix TX6 SBC, with fan.
 *  Copyright (C) 2022  Ivan Mironov <mironov.ivan@gmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// Hight of the fan (flatwise)
FAN_HEIGHT = 27.0;  // mm
// Diameter of the fan
FAN_DIAM = 77.0;  // mm
// Additional height space for fan
FAN_SPACING = 8.0;  // mm
// Distance between fan screw holes
FAN_SCREW_HOLE_DIST = 71.5;  // mm
// Diameter for fan screw holes (without fastening)
FAN_SCREW_HOLE_DIAM = 5.5;  // mm

// Airflow grill (bottom)
BOTTOM_GRILL_HEIGHT = 0.6;  // mm
BOTTOM_GRILL_HOLE_WIDTH = 3.0;  // mm
BOTTOM_GRILL_HOLE_SPACING = 0.6;  // mm

// Airflow grill (top)
TOP_GRILL_HOLE_WIDTH = 3.0;  // mm
TOP_GRILL_HOLE_HEIGHT = 10.0;  // mm

// Width/depth of case exterior
CASE_WIDTH = 103.0;  // mm
// Width/depth of straight part of case exterior
CASE_STRAIGHT_WIDTH = 75.0;  // mm
// Height of the top part of case (original + fan)
CASE_TOP_HEIGHT = 23.0 + FAN_HEIGHT + FAN_SPACING;  // mm
// Hight of the bottom part of case (without legs)
CASE_BOTTOM_HEIGHT = 4.0;  // mm
// Height of legs on bottom part
CASE_LEGS_HEIGHT = 15.0;  // mm
// Radius of legs on bottom part
CASE_LEGS_RADIUS = 11.0;  // mm
// Distance between case screws
CASE_SCREW_DIST = 87.5;  // mm
// Diameter of case screws with fastening (seems to be 2mm, but printer's 2mm is too tight)
CASE_SCREW_DIAM = 2.8;  // mm
// Diameter for case screws holes without fastening
CASE_SCREW_HOLE_DIAM = 4.0;  // mm
// Diameter of heads of case screws
CASE_SCREW_HEAD_HOLE_DIAM = 6.0;  // mm
// Adjustment of unused length of case screws, if your screws are too long
CASE_SCREW_UNUSED_LENGTH_ADJ = 4.0;  // mm
// Case wall thickness
WALL_THICKNESS = 2.5;  // mm

// Size of supports inside the top part
BOTTOM_SUPPORT_RADIUS = 7.0;  // mm
// Width of bottom supports on the walls
BOTTOM_SUPPORT_WALL_WIDTH = 2.0;  // mm
// Size of thick supports inside the top part
BOTTOM_SUPPORT_THICK_RADIUS = 8.5;  // mm
BOTTOM_SUPPORT_THICKENING_HEIGHT = 5.0;  // mm

// Height of PCB supports
PCB_SUPPORT_HEIGHT = 3.5;  // mm
// Diameter of PCB supports
PCB_SUPPORT_DIAM = 5.0;  // mm
// Distance between PCB supports
PCB_SUPPORT_DIST = 67.0;  // mm
// Diameter of PCB screws with fastening (seems to be 1.5mm, but printers 1.5mm is too tight)
PCB_SCREW_DIAM = 2.0;  // mm
// Maximum PCB height, including PCB supports.
MAX_PCB_HEIGHT = 18.0;  // mm

TOLERANCE = 0.1;  // mm

// Overlap, used for geometry subtraction.
OS = 1.0;  // mm
// Overlap, used for geometry addition.
OA = 0.01;  // mm

module case_2d_projection(wall_adj)
{
    diam = CASE_WIDTH - CASE_STRAIGHT_WIDTH + wall_adj * 2;
    off = CASE_STRAIGHT_WIDTH / 2;
    hull() {
        for (x_off = [-1.0, 1.0], y_off = [-1.0, 1.0]) {
            translate([x_off, y_off] * off)
                circle(d=diam, $fn=128);
        }
    }
}

module bottom_supports(h, r1, r2, wall_adj)
{
    case_diam = CASE_WIDTH - CASE_STRAIGHT_WIDTH;
    off = CASE_STRAIGHT_WIDTH / 2 + sqrt(2) * case_diam / 4;  // sin(45??) == sqrt(2)/2
    intersection() {
        for (x_off = [- 1.0, 1.0], y_off = [- 1.0, 1.0]) {
            translate([x_off, y_off] * off)
                cylinder(h = h, r1 = r1, r2 = r2, $fn=128);
        }

        translate([0.0, 0.0, -OS]) {
            linear_extrude(h + OS * 2)
                case_2d_projection(wall_adj);
        }
    }
}

function pcb_support_coords() = let(half_off = PCB_SUPPORT_DIST / 2) [
	for (x_off = [-1.0, 1.0], y_off = [-1.0, 1.0])
		[x_off * half_off, y_off * half_off, 0.0]
];

module top_part_no_holes()
{
    // Box.
    difference() {
        linear_extrude(height=CASE_TOP_HEIGHT + CASE_BOTTOM_HEIGHT)
            case_2d_projection(0.0);

        straight_h = (CASE_TOP_HEIGHT - WALL_THICKNESS) / 2;
        translate([0.0, 0.0, WALL_THICKNESS])
            linear_extrude(straight_h + OA)
                case_2d_projection(- WALL_THICKNESS);

        // More supports for bottom.
        hull() {
            translate([0.0, 0.0, WALL_THICKNESS + straight_h])
                linear_extrude(OA)
                    case_2d_projection(- WALL_THICKNESS);
            // Not that accurate because of (+ OS), but good enough.
            translate([0.0, 0.0, CASE_TOP_HEIGHT + OS])
                linear_extrude(OA)
                    case_2d_projection(- WALL_THICKNESS - BOTTOM_SUPPORT_WALL_WIDTH);
        }

        // Some space for bottom part.
        translate([0.0, 0.0, CASE_TOP_HEIGHT])
            linear_extrude(CASE_BOTTOM_HEIGHT + OS)
                case_2d_projection(- WALL_THICKNESS);
    }

    // Bottom supports.
    translate([0.0, 0.0, WALL_THICKNESS - OA])
        bottom_supports(
            MAX_PCB_HEIGHT + OA,
            BOTTOM_SUPPORT_RADIUS,
            BOTTOM_SUPPORT_RADIUS,
            -OA);
    translate([0.0, 0.0, WALL_THICKNESS + MAX_PCB_HEIGHT - OA])
        bottom_supports(
            BOTTOM_SUPPORT_THICKENING_HEIGHT + OA * 2,
            BOTTOM_SUPPORT_RADIUS,
            BOTTOM_SUPPORT_THICK_RADIUS,
            -OA);
    translate([0.0, 0.0, WALL_THICKNESS + MAX_PCB_HEIGHT + BOTTOM_SUPPORT_THICKENING_HEIGHT])
        bottom_supports(
            CASE_TOP_HEIGHT - WALL_THICKNESS - MAX_PCB_HEIGHT - BOTTOM_SUPPORT_THICKENING_HEIGHT - OA,
            BOTTOM_SUPPORT_THICK_RADIUS,
            BOTTOM_SUPPORT_THICK_RADIUS,
            -OA);

    // PCB supports.
    translate([0.0, 0.0, WALL_THICKNESS - OA]) {
        linear_extrude(height=PCB_SUPPORT_HEIGHT + OA) {
            for (xy = pcb_support_coords()) {
                translate(xy)
                    circle(d=PCB_SUPPORT_DIAM, $fn=64);
            }
        }
    }
}

module front_ports_2d(through_hole) {
    adj = through_hole? 0.0 : 3.0;
    adj2 = adj * 2;
    // Smaller adjustment to not cut through horizontal wall.
    adj_small = through_hole? 0.0 : 1.0;
    adj_small2 = adj + adj_small;

    // Power connector.
    if (through_hole) {
        translate([15.0, 13.5])
            circle(d = 6.5, $fn = 64);
    } else {
        translate([15.0, 13.5])
            square([7.5, 18.0], true);
    }
    // HDMI connector.
    translate([22.0 - adj, 7.0 - adj])
        square([17.0 + adj2, 7.0 + adj2]);
    // Ethernet connector.
    translate([43.0 - adj, 4.5 - adj_small])
        square([16.0 + adj2, 11.0 + adj_small2]);
    // Two USB 2.0 connectors.
    translate([64.0 - adj, 3.5 - adj_small])
        square([15.0 + adj2, 7.0 + adj_small2]);
    translate([64.0 - adj, 12.5 - adj])
        square([15.0 + adj2, 7.0 + adj2]);
    // Button.
    if (through_hole) {
        translate([81.0, 9.8])
            circle(d = 1.5, $fn = 32);
    }
    // SPDIF connector.
    if (through_hole) {
        translate([87.0, 9.5])
            circle(d = 5.5, $fn = 64);
    } else {
        translate([87.0, 9.5])
            square(8.0, true);
    }
}

module left_ports_2d(through_hole)
{
    adj = through_hole? 0.0 : 3.0;
    adj2 = adj * 2;

    // USB 3.0 connector.
    translate([58.5 - adj, 7.5 - adj])
        square([15.5 + adj2, 7.5 + adj2]);
    // WiFi connector.
    if (through_hole) {
        translate([83.5, 13.0]) {
            intersection() {
                translate([0.0, - 1.2])
                    square(8.0, true);
                circle(d = 6.5, $fn = 64);
            }
        }
    } else {
        translate([83.5, 13.0])
            circle(d = 11.5, $fn = 64);
    }
}

module right_ports_2d(through_hole)
{
    adj = through_hole? 0.0 : 3.0;
    adj2 = adj * 2;

    // Button.
    if (through_hole) {
        translate([26.5, 9.8])
            circle(d = 1.5, $fn = 32);
    }
    // MicroSD card slot.
    translate([30.0 - adj, 7.0 - adj])
        square([16.0 + adj2, 5.0 + adj2]);
}

function case_screw_hole_coords() = let(half_off = CASE_SCREW_DIST / 2) [
	for (x_off = [-1.0, 1.0], y_off = [-1.0, 1.0])
		[x_off * half_off, y_off * half_off, 0.0]
];

module top_grill(h, n_vert)
{
    hole_height = (h - (n_vert - 1) * TOP_GRILL_HOLE_WIDTH) / n_vert;
    for (iv = [0 : n_vert - 1]) {
        translate([0.0, 0.0, iv * (hole_height + TOP_GRILL_HOLE_WIDTH)]) {
            linear_extrude(height=hole_height) {
                n_horiz = floor((floor(CASE_STRAIGHT_WIDTH / TOP_GRILL_HOLE_WIDTH) + 1) / 2);
                grill_width = (n_horiz * 2 - 1) * TOP_GRILL_HOLE_WIDTH;
                for (ih = [0 : n_horiz - 1]) {
                    translate([
                            ih * TOP_GRILL_HOLE_WIDTH * 2 - grill_width / 2,
                            -CASE_WIDTH / 2 - OS])
                        square([TOP_GRILL_HOLE_WIDTH, WALL_THICKNESS + BOTTOM_SUPPORT_WALL_WIDTH + OS * 2]);
                }
            }
        }
    }
}

module top_part()
{
    difference() {
        top_part_no_holes();

        for (through_hole = [false, true]) {
            eh = through_hole? WALL_THICKNESS + OS * 2 : WALL_THICKNESS / 2 + OS;
            dz = through_hole? CASE_WIDTH / 2 - WALL_THICKNESS - OS : CASE_WIDTH / 2 - WALL_THICKNESS - OS;

            // Front side ports.
            rotate([90.0]) {
                translate([- CASE_WIDTH / 2, 0.0, dz]) {
                    linear_extrude(height = eh)
                        front_ports_2d(through_hole);
                }
            }

            // Left side ports.
            rotate([90.0, 0.0, - 90.0]) {
                translate([- CASE_WIDTH / 2, 0.0, dz]) {
                    linear_extrude(height = eh)
                        left_ports_2d(through_hole);
                }
            }

            // Right side ports.
            rotate([90.0, 0.0, 90.0]) {
                translate([- CASE_WIDTH / 2, 0.0, dz]) {
                    linear_extrude(height = eh)
                        right_ports_2d(through_hole);
                }
            }
        }

        // Holes for PCB screws.
        translate([0.0, 0.0, WALL_THICKNESS / 2]) {
            linear_extrude(height=PCB_SUPPORT_HEIGHT + WALL_THICKNESS / 2 + OA) {
                for (xy = pcb_support_coords()) {
                    translate(xy)
                        circle(d=PCB_SCREW_DIAM, $fn=64);
                }
            }
        }

        // Holes for case screws.
        case_screw_dz = WALL_THICKNESS + MAX_PCB_HEIGHT + BOTTOM_SUPPORT_THICKENING_HEIGHT;
        case_screw_h = CASE_TOP_HEIGHT - WALL_THICKNESS - MAX_PCB_HEIGHT - BOTTOM_SUPPORT_THICKENING_HEIGHT + OS;
        translate([0.0, 0.0, case_screw_dz]) {
            linear_extrude(case_screw_h) {
                for (xy = case_screw_hole_coords()) {
                    translate(xy)
                        circle(d=CASE_SCREW_DIAM, $fn=64);
                }
            }
        }

        // Airflow grill - left, front and right.
        grill_h = CASE_TOP_HEIGHT * 0.60;
        for (a = [-90.0, 0.0, 90.0]) {
            translate([0.0, 0.0, WALL_THICKNESS + CASE_TOP_HEIGHT - grill_h]) {
                rotate([0.0, 0.0, a])
                    top_grill(grill_h - WALL_THICKNESS + OA, 2);
            }
        }
        // Airflow grill - back.
        translate([0.0, 0.0, WALL_THICKNESS]) {
            rotate([0.0, 0.0, 180.0])
                top_grill(CASE_TOP_HEIGHT - WALL_THICKNESS + OA, 3);
        }
    }
}

// Width is over the "x" axis.
module hex(width)
{
	circle(d=width, $fn=6);
}

// Depth is over the "y" axis.
function hex_depth(width) = sqrt(3) / 2 * width;

// Sum of 2D cubic coordinates.
function hex_cc_sum(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

// All possible directions from "zero" hexagon in cubic 2D coordinates.
function hex_cc_direction(direction) = [
	[+1, -1,  0],
	[+1,  0, -1],
	[ 0, +1, -1],
	[-1, +1,  0],
	[-1,  0, +1],
	[ 0, -1, +1],
][direction];

// Neighbor of given hexagon in cubic 2D coordinates.
function hex_cc_neighbor(cc, direction) = hex_cc_sum(cc, hex_cc_direction(direction));

// Convert cubic 2D coordinates to [col, row] (even-col is without offset over "y" axis).
function hex_cc_to_off(cc) = [cc[0], cc[2] + (cc[0] - cc[0] % 2) / 2];

// Convert [col, row] (even-col) to normal [x, y] 2D coordinates.
function hex_off_to_xy(off, width) = [
	off[0] * width * 3 / 4,
	off[1] * hex_depth(width) + off[0] % 2 * hex_depth(width) / 2,
];

// Convert cubic 2D coordinates to normal [x, y] 2D coordinates.
function hex_cc_to_xy(cc, width) = hex_off_to_xy(hex_cc_to_off(cc), width);

function hex_cc_ring_tail(cur_ring, cur_direction_mul_radius, radius) =
	cur_direction_mul_radius < 6 * radius - 1 ?
		hex_cc_ring_tail(
			concat(
				[hex_cc_neighbor(
					cur_ring[0],
					floor(cur_direction_mul_radius / radius))],
				cur_ring),
			cur_direction_mul_radius + 1,
			radius) :
		cur_ring;

function hex_cc_ring(center_cc, radius) = hex_cc_ring_tail(
	[hex_cc_direction(4) * radius],
	0,
	radius);

function hex_cc_spiral_tail(cur_spiral, radius) =
	radius > 0 ?
		hex_cc_spiral_tail(
			concat(
				cur_spiral,
				hex_cc_ring(cur_spiral[0], radius)),
			radius - 1) :
		cur_spiral;

function hex_cc_spiral(center_cc, radius) = hex_cc_spiral_tail([center_cc], radius);

// TODO: Verify. Not sure about radius calculation.
function hex_circle(width, radius) = [
	for (i = hex_cc_spiral([0, 0, 0], ceil(radius / (width * 1.5) * 2)))
		let (xy = hex_cc_to_xy(i, width))
			if (norm(xy) < radius - width / 2) xy
];

function fan_screw_hole_coords() = let(half_off = FAN_SCREW_HOLE_DIST / 2) [
	for (x_off = [-1.0, 1.0], y_off = [-1.0, 1.0])
		[x_off * half_off, y_off * half_off, 0.0]
];

// Not really "no holes" as 2D holes already included.
module bottom_part_no_holes()
{
    // Plate.
    linear_extrude(height=CASE_BOTTOM_HEIGHT) {
        difference() {
            case_2d_projection(-WALL_THICKNESS - TOLERANCE);

            // Holes for airflow.
            full_hex_width = BOTTOM_GRILL_HOLE_WIDTH + BOTTOM_GRILL_HOLE_SPACING;
            for (xy = hex_circle(full_hex_width, FAN_DIAM / 2)) {
                translate(xy)
                    hex(BOTTOM_GRILL_HOLE_WIDTH);
            }

            // Holes for fan mounting screws
            for (xy = fan_screw_hole_coords()) {
                translate(xy)
                    circle(d=FAN_SCREW_HOLE_DIAM, $fn=64);
            }
        }
    }

    // Legs.
    translate([0.0, 0.0, CASE_BOTTOM_HEIGHT - OA])
        bottom_supports(CASE_LEGS_HEIGHT + OA, CASE_LEGS_RADIUS, CASE_LEGS_RADIUS, -WALL_THICKNESS - TOLERANCE);
}

module bottom_part()
{
    difference() {
        bottom_part_no_holes();

        // Make grill thinner.
        translate([0.0, 0.0, BOTTOM_GRILL_HEIGHT]) {
            linear_extrude(height=CASE_BOTTOM_HEIGHT - BOTTOM_GRILL_HEIGHT + OS)
                circle(d=FAN_DIAM, $fn=256);
        }

        // Make space for heads of fan mounting screws
        translate([0.0, 0.0, CASE_BOTTOM_HEIGHT / 2]) {
            linear_extrude(height=CASE_BOTTOM_HEIGHT / 2 + OS) {
                for (xy = fan_screw_hole_coords()) {
                    translate(xy)
                        circle(d=FAN_SCREW_HOLE_DIAM * 2, $fn=64);
                }
            }
        }

        // Holes for case screws.
        translate([0.0, 0.0, -OS]) {
            linear_extrude(height=CASE_BOTTOM_HEIGHT + CASE_LEGS_HEIGHT + OS * 2) {
                for (xy = case_screw_hole_coords()) {
                    translate(xy)
                        circle(d=CASE_SCREW_HOLE_DIAM, $fn=64);
                }
            }
        }

        // Holes for heads of case screws.
        translate([0.0, 0.0, CASE_BOTTOM_HEIGHT + CASE_SCREW_UNUSED_LENGTH_ADJ]) {
            linear_extrude(height=CASE_LEGS_HEIGHT - CASE_SCREW_UNUSED_LENGTH_ADJ + OS) {
                for (xy = case_screw_hole_coords()) {
                    hull() {
                        translate(xy)
                            circle(d=CASE_SCREW_HEAD_HOLE_DIAM, $fn=64);
                        // Extend to outside
                        translate(xy * 2)
                            circle(d=CASE_SCREW_HEAD_HOLE_DIAM * 10, $fn=64);
                    }
                }
            }
        }
    }
}

module screw_hole_calibration()
{
    linear_extrude(height=5.0) {
        difference() {
            square([50.0, 10.0], true);

            // Fan screws should NOT screw into plastic here:
            translate([-18.0, 0.0])
                circle(d=FAN_SCREW_HOLE_DIAM, $fn=64);
            // Case screws should screw into plastic here:
            translate([-10.0, 0.0])
                circle(d=CASE_SCREW_DIAM, $fn=64);
            // Case screws should NOT screw into plastic here:
            translate([0.0, 0.0])
                circle(d=CASE_SCREW_HOLE_DIAM, $fn=64);
            // Case screws should fall through this hole:
            translate([10.0, 0.0])
                circle(d=CASE_SCREW_HEAD_HOLE_DIAM, $fn=64);
            // PCB screws should screw into plastic here:
            translate([20.0, 0.0])
                circle(d=PCB_SCREW_DIAM, $fn=64);
        }
    }
}

translate([-CASE_WIDTH / 2 - 10.0, 0.0, 0.0])
    top_part();
translate([CASE_WIDTH / 2 + 10.0, 0.0, 0.0])
    bottom_part();
translate([0.0, -CASE_WIDTH / 2 - 20.0, 0.0])
    screw_hole_calibration();
