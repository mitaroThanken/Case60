include <Lib/BOSL/constants.scad>
use <Lib/BOSL/shapes.scad>
use <Lib/BOSL/masks.scad>
use <Lib/BOSL/transforms.scad>

$fa = $preview ? 6 : 1;
$fs = $preview ? 1 : 0.5;

pcb_size = [285.000, 94.600];
pcb_thickness = 1.600;
switch_bottom_h = 5.000; // Cherry MX

case_thickness = 3.000;

on_tube_h = pcb_thickness + switch_bottom_h;

mount_height = 15.000;

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
            mount_bars();
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


// 手前
module wall_front() {
    ymove(-1 * (base_d / 2 * cos(rot - rot_diff) + case_thickness / 4))
        upcube([pcb_size[0] + case_thickness,     case_thickness / 2, 23.000]);
    ymove(-1 * (base_d / 2 * cos(rot - rot_diff) + case_thickness * 3 / 4))
        upcube([pcb_size[0] + case_thickness * 2, case_thickness / 2, 25.000]);
}

// 奥
module wall_back() {
    ymove(      base_d / 2 * cos(rot - rot_diff) + case_thickness / 4 )
        upcube([pcb_size[0] + case_thickness, case_thickness / 2, 13.000]);
    ymove(      base_d / 2 * cos(rot - rot_diff) + case_thickness * 3 / 4 )
        upcube([pcb_size[0] + case_thickness * 2, case_thickness / 2, 15.000]);
}

// 横の壁（低いほう）
module wall_side_lower() {
    hull() {
        zmove(13.000)
            prismoid(
                size1=[case_thickness / 2, pcb_size[1]],
                size2=[case_thickness / 2, 0],
                shift=[0, -1 * pcb_size[1] / 2],
                h=10.000);
        upcube([case_thickness / 2, pcb_size[1], 13.000]);
    }
}

// 横の壁（高いほう）
module wall_side_higher() {
    hull() {
        zmove(15.000)
            prismoid(
                size1=[case_thickness / 2, pcb_size[1] + case_thickness],
                size2=[case_thickness / 2, 0],
                shift=[0, -1 * (pcb_size[1] + case_thickness) / 2],
                h=10.000);
        upcube([case_thickness / 2, pcb_size[1] + case_thickness, 15.000]);
    }
}

// 左右の壁
module wall_side(invert=false) {
    s = invert ? -1 : 1;
    xmove(s * (pcb_size[0] / 2 + case_thickness     / 4))
        wall_side_lower();
    xmove(s * (pcb_size[0] / 2 + case_thickness * 3 / 4))
        wall_side_higher();
}

difference(){
    union() {
        // 壁
        wall_front();
        wall_back();
        wall_side();
        wall_side(invert=true);

        // 底
        upcube([pcb_size[0], pcb_size[1], case_thickness]);
    }

    place_copies([
        [0,       pcb_size[1] / 2 + case_thickness,  0],
        [0, -1 * (pcb_size[1] / 2 + case_thickness), 0]
    ])
        #fillet_mask_x(l=pcb_size[0] + case_thickness * 2, r=2.000);

    place_copies([
        [      pcb_size[0] / 2 + case_thickness,  0, 0],
        [-1 * (pcb_size[0] / 2 + case_thickness), 0, 0]
    ])
        #fillet_mask_y(l=pcb_size[1] + case_thickness * 2, r=2.000);

    place_copies([
        [-1 * (pcb_size[0] / 2 + case_thickness), -1 * (pcb_size[1] / 2 + case_thickness), 0],
        [      pcb_size[0] / 2 + case_thickness,  -1 * (pcb_size[1] / 2 + case_thickness), 0]
    ])
        up(25.00 / 2) #fillet_mask_z(l=25.00, r=2.000);

    place_copies([
        [-1 * (pcb_size[0] / 2 + case_thickness),       pcb_size[1] / 2 + case_thickness,  0],
        [      pcb_size[0] / 2 + case_thickness,        pcb_size[1] / 2 + case_thickness,  0]
    ])
        up(15.00 / 2) #fillet_mask_z(l=15.00, r=2.000);

    place_copies([
        [-1 * (pcb_size[0] / 2 + case_thickness),       pcb_size[1] / 2 + case_thickness,  0],
        [-1 * (pcb_size[0] / 2 + case_thickness), -1 * (pcb_size[1] / 2 + case_thickness), 0],
        [      pcb_size[0] / 2 + case_thickness,        pcb_size[1] / 2 + case_thickness,  0],
        [      pcb_size[0] / 2 + case_thickness,  -1 * (pcb_size[1] / 2 + case_thickness), 0]
    ])
        #fillet_corner_mask(r=2.000);

/*
    place_copies([
        [0, -1 *  pcb_size[1] / 2,                   23.00],
        [0,       pcb_size[1] / 2,                   13.00]
    ])
        #fillet_mask_x(l=pcb_size[0] + case_thickness / 4, r=case_thickness / 4);

    place_copies([
        [0, -1 * (pcb_size[1] + case_thickness) / 2, 25.00],
        [0,      (pcb_size[1] + case_thickness) / 2, 15.00],
    ])
        #fillet_mask_x(l=pcb_size[0] + case_thickness, r=case_thickness / 4);
        
    place_copies([
        [-1 *  pcb_size[0] / 2                  , -1 * pcb_size[1] / 2, 23.00],
        [      pcb_size[0] / 2                  , -1 * pcb_size[1] / 2, 23.00]
    ])
        xrot(-1 * rot - 90) {
           up(pcb_size[1] / cos(rot) / 2) #fillet_mask(l=pcb_size[1] / cos(rot), r=case_thickness / 4);
        };
*/
}


//pillars(check = true);
pillars();
