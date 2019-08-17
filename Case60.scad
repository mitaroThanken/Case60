include <Lib/BOSL/constants.scad>
use <Lib/BOSL/shapes.scad>
use <Lib/BOSL/masks.scad>
use <Lib/BOSL/transforms.scad>

$fa = $preview ? 6 : 1;
$fs = $preview ? 1 : 0.1;

pcb_size = [285.000, 94.600];
pcb_thickness = 1.600;
switch_bottom_h = 5.000; // Cherry MX

case_thickness = 6.000;

on_tube_h = pcb_thickness + switch_bottom_h;

mount_height = 20.000;

rot = 6;

points_cyls = [
    // from GH60
    [-1 * pcb_size[0] / 2 +  25.200, pcb_size[1] / 2 - 27.900, 0],
    [-1 * pcb_size[0] / 2 + 128.200, pcb_size[1] / 2 - 47.000, 0],
    [     pcb_size[0] / 2 -  24.950, pcb_size[1] / 2 - 27.900, 0],
    [-1 * pcb_size[0] / 2 + 190.500, pcb_size[1] / 2 - 85.200, 0],
    [-1 * pcb_size[0] / 2 +   2.000, pcb_size[1] / 2 - 56.500, 0],
    [     pcb_size[0] / 2 -   2.000, pcb_size[1] / 2 - 56.500, 0],
    // for Tofu?
    [-1 * pcb_size[0] / 2 +  25.200, pcb_size[1] / 2 - 85.200, 0],
    [-1 * pcb_size[0] / 2 + 142.500, pcb_size[1] / 2 - 37.235, 0],
    [     pcb_size[0] / 2 -  24.950, pcb_size[1] / 2 - 85.200, 0]
];

points_bars = [
    // from GH60
    [0, -1 * pcb_size[1] / 2 + 2.200, 0],
    [0, -1 * pcb_size[1] / 2 + 2.200 + 16.600, 0],
    [0, -1 * pcb_size[1] / 2 + 2.200 + 16.600 + 19.300 * 1, 0],
    [0, -1 * pcb_size[1] / 2 + 2.200 + 16.600 + 19.300 * 2, 0],
    [0, -1 * pcb_size[1] / 2 + 2.200 + 16.600 + 19.300 * 3, 0]
];

module mount_cylinder() {
    difference() {
        cylinder(h=mount_height, d1=7.150, d2=4.000, center=false);
        up(mount_height) #fillet_cylinder_mask(r=2.055, fillet=0.500);
    }
}

module mount_cyls() {
    place_copies(points_cyls)
        mount_cylinder();
}

module mount_bar() {
    difference() {
        prismoid(size1=[pcb_size[0] + case_thickness, 5.170],
                 size2=[pcb_size[0] + case_thickness, 2.000],
                 h=mount_height);
        place_copies([
            [0,  1.075, mount_height],
            [0, -1.075, mount_height]
        ])
            #fillet_mask_x(
                l=pcb_size[0] + case_thickness,
                r=0.650
            );
    }
}

module mount_bars() {
    place_copies(points_bars)
        mount_bar();
}

module mount() {
    difference() {
        union() {
            // 成形を安定させるという意味合いでなければ、バーは不要
            // mount_bars();
            mount_cyls();
        }
        place_copies(points_cyls)
            cylinder(h=mount_height + 1, r=0.800);
        place_copies(points_cyls)
            up(mount_height) #fillet_hole_mask(r=0.800, fillet=0.400);
    }
}

// 載せるものの高さの中心
rot_height = mount_height + on_tube_h / 2;

// 載せるものの対角
rot_diff = atan2(on_tube_h / 2, pcb_size[1]);
base_d = pcb_size[1] / cos(rot_diff);

// 最短高さ
min_height = 3.00;

module pillars(check=false) {
    difference() {
        zmove(rot_height - base_d / 2 * sin(rot + rot_diff) + min_height)
            xrot(-1 * rot)
                zmove(-1 * rot_height) {
                    mount();
                    if (check == true) {
                        // 上物チェック
                        %zmove(mount_height)
                            upcube([pcb_size[0], pcb_size[1], on_tube_h]);
                    }
                };
         up(case_thickness / 2) downcube([pcb_size[0] * 1.1, pcb_size[1] * 1.1, rot_height]);
    }
}

// ケースのサイズ
case_size = [pcb_size[0] * 1.01, pcb_size[1] * 1.01];
case_d = base_d * 1.01;

// 壁
// 高いほう（内側）
wall_high_inner = 27.000;
// 高いほう（外側）
wall_high_outer = 30.000;
// 低いほう（内側）
wall_low_inner = 17.000;
// 低いほう（外側）
wall_low_outer = 20.000;

// 手前
module wall_front() {
    ymove(-1 * (case_d / 2 * cos(rot - rot_diff) + case_thickness / 4))
        upcube([case_size[0] + case_thickness,     case_thickness / 2, wall_high_inner]);
    ymove(-1 * (case_d / 2 * cos(rot - rot_diff) + case_thickness * 3 / 4))
        upcube([case_size[0] + case_thickness * 2, case_thickness / 2, wall_high_outer]);
}

// 奥
module wall_back() {
    difference() {
        union() {
            ymove(      case_d / 2 * cos(rot - rot_diff) + case_thickness / 4 )
                upcube([case_size[0] + case_thickness, case_thickness / 2, wall_low_inner]);
            ymove(      case_d / 2 * cos(rot - rot_diff) + case_thickness * 3 / 4 )
                upcube([case_size[0] + case_thickness * 2, case_thickness / 2, wall_low_outer]);
        }
        move([-124.3, case_size[1] / 2 + case_thickness, case_thickness])
            upcube(size=[20.000, case_thickness * 4,  (wall_low_inner - case_thickness) / 2]);
    }
}

// 横の壁（低いほう）
module wall_side_lower() {
    hull() {
        zmove(wall_low_inner)
            prismoid(
                size1=[case_thickness / 2, case_size[1]],
                size2=[case_thickness / 2, 0],
                shift=[0, -1 * case_size[1] / 2],
                h=10.000);
        upcube([case_thickness / 2, case_size[1], wall_low_inner]);
    }
}

// 横の壁（高いほう）
module wall_side_higher() {
    hull() {
        zmove(wall_low_outer)
            prismoid(
                size1=[case_thickness / 2, case_size[1] + case_thickness],
                size2=[case_thickness / 2, 0],
                shift=[0, -1 * (case_size[1] + case_thickness) / 2],
                h=10.000);
        upcube([case_thickness / 2, case_size[1] + case_thickness, wall_low_outer]);
    }
}

// 左右の壁
module wall_side(invert=false) {
    s = invert ? -1 : 1;
    xmove(s * (case_size[0] / 2 + case_thickness     / 4))
        wall_side_lower();
    xmove(s * (case_size[0] / 2 + case_thickness * 3 / 4))
        wall_side_higher();
}

// リセットスイッチ用の穴の辺の長さ
reset_hole = 10.000;

// 底
module bottom_plate() {
    difference() {
        upcube([case_size[0], case_size[1], case_thickness]);
        move([-99.410, 0.900, 0]) {
            cube(size=[reset_hole, reset_hole, case_thickness * 4], center=true);
        }
    }
}

module case(fillet=true, check=false) {
    difference(){
        union() {
            // 壁
            wall_front();
            wall_back();
            wall_side();
            wall_side(invert=true);

            // 底
            bottom_plate();
        }

        if (fillet) {
            place_copies([
                [0,       case_size[1] / 2 + case_thickness,  0],
                [0, -1 * (case_size[1] / 2 + case_thickness), 0]
            ])
                #fillet_mask_x(l=case_size[0] + case_thickness * 2, r=2.000);

            place_copies([
                [      case_size[0] / 2 + case_thickness,  0, 0],
                [-1 * (case_size[0] / 2 + case_thickness), 0, 0]
            ])
                #fillet_mask_y(l=case_size[1] + case_thickness * 2, r=2.000);

            place_copies([
                [-1 * (case_size[0] / 2 + case_thickness), -1 * (case_size[1] / 2 + case_thickness), 0],
                [      case_size[0] / 2 + case_thickness,  -1 * (case_size[1] / 2 + case_thickness), 0]
            ])
                up(wall_high_outer / 2) #fillet_mask_z(l=wall_high_outer, r=2.000);

            place_copies([
                [-1 * (case_size[0] / 2 + case_thickness),       case_size[1] / 2 + case_thickness,  0],
                [      case_size[0] / 2 + case_thickness,        case_size[1] / 2 + case_thickness,  0]
            ])
                up(wall_low_outer / 2) #fillet_mask_z(l=wall_low_outer, r=2.000);

            place_copies([
                [-1 * (case_size[0] / 2 + case_thickness),       case_size[1] / 2 + case_thickness,  0],
                [-1 * (case_size[0] / 2 + case_thickness), -1 * (case_size[1] / 2 + case_thickness), 0],
                [      case_size[0] / 2 + case_thickness,        case_size[1] / 2 + case_thickness,  0],
                [      case_size[0] / 2 + case_thickness,  -1 * (case_size[1] / 2 + case_thickness), 0]
            ])
                #fillet_corner_mask(r=2.000);
        }
    }

    pillars(check);
}

case(fillet=false, check=false);