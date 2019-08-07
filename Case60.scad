include <Lib/BOSL/constants.scad>
use <Lib/BOSL/shapes.scad>
use <Lib/BOSL/transforms.scad>

$fa = $preview ? 6 : 1;
$fs = $preview ? 1 : 0.05;

$pcb_size = [285.000, 94.600];
$case_thickness = 3.000;

$pcb_thickness = 1.600;
$switch_bottom_h = 5.000; // Cherry MX
$on_tube_h = $pcb_thickness + $switch_bottom_h;

$tube_height = 15.000;

$rot = 6;

module mount_tube() {
    tube(h=$tube_height, ir1=0.800, or1=3.000, ir2=0.800, or2=2.000);
}

module mount_tubes() {
    place_copies([
        [-1 * $pcb_size[0] / 2 +  25.200, $pcb_size[1] / 2 - 27.900, 0], 
        [-1 * $pcb_size[0] / 2 + 128.200, $pcb_size[1] / 2 - 47.000, 0],
        [     $pcb_size[0] / 2 -  24.950, $pcb_size[1] / 2 - 27.900, 0],
        [-1 * $pcb_size[0] / 2 + 190.500, $pcb_size[1] / 2 - 85.200, 0],
        [-1 * $pcb_size[0] / 2 +   2.000, $pcb_size[1] / 2 - 56.500, 0],
        [     $pcb_size[0] / 2 -   2.000, $pcb_size[1] / 2 - 56.500, 0]]) 
        mount_tube();

    // for Tofu
    place_copies([
        [-1 * $pcb_size[0] / 2 +  25.200, $pcb_size[1] / 2 - 85.200, 0],
        [-1 * $pcb_size[0] / 2 + 142.500, $pcb_size[1] / 2 - 37.235, 0],
        [     $pcb_size[0] / 2 -  24.950, $pcb_size[1] / 2 - 85.200, 0]]) 
        mount_tube();
}

// 回転させる軸の位置
$rot_height = $tube_height + $on_tube_h / 2;

// 柱の上に置くものの対角
$rot_diff = atan2($on_tube_h / 2, $pcb_size[1]);
$base_d = $pcb_size[1] / cos($rot_diff);

difference() {
    zmove($base_d / 2 * sin($rot + $rot_diff) + 5.500)
        xrot(-1 * $rot)
            zmove(-1 * $rot_height) {
                mount_tubes();
                // 上物チェック
                %zmove($tube_height)
                    upcube([$pcb_size[0], $pcb_size[1], $on_tube_h]);
                
            };
     downcube([$pcb_size[0] * 1.1, $pcb_size[1] * 1.1, $rot_height]);
}


// 手前
ymove(-1 * ($base_d / 2 * cos($rot - $rot_diff) + $case_thickness / 4))
    upcube([$pcb_size[0] + $case_thickness, $case_thickness / 2, 18.000]);
ymove(-1 * ($base_d / 2 * cos($rot - $rot_diff) + $case_thickness * 3 / 4))
    upcube([$pcb_size[0] + $case_thickness * 2, $case_thickness / 2, 20.000]);

// 奥
ymove(      $base_d / 2 * cos($rot - $rot_diff) + $case_thickness / 4 )
    upcube([$pcb_size[0] + $case_thickness, $case_thickness / 2, 8.000]);

ymove(      $base_d / 2 * cos($rot - $rot_diff) + $case_thickness * 3 / 4 )
    upcube([$pcb_size[0] + $case_thickness * 2, $case_thickness / 2, 10.000]);

// 横の壁（低いほう）
module wall_side_lower() {
    zmove(8.000)
        prismoid(
            size1=[$case_thickness / 2, $pcb_size[1]],
            size2=[$case_thickness / 2, 0],
            shift=[0, -1 * $pcb_size[1] / 2],
            h=10.000);
    upcube([$case_thickness / 2, $pcb_size[1], 8]);
}

// 横の壁（高いほう）
module wall_side_higher() {
    zmove(10.000)
        prismoid(
            size1=[$case_thickness / 2, $pcb_size[1] + $case_thickness],
            size2=[$case_thickness / 2, 0],
            shift=[0, -1 * ($pcb_size[1] + $case_thickness) / 2],
            h=10.000);
    upcube([$case_thickness / 2, $pcb_size[1] + $case_thickness, 10]);
}

// 左右の壁
module wall_side(invert=false) {
    s = invert ? -1 : 1;
    xmove(s * ($pcb_size[0] / 2 + $case_thickness     / 4))
        wall_side_lower();
    xmove(s * ($pcb_size[0] / 2 + $case_thickness * 3 / 4))
        wall_side_higher();
}

wall_side();
wall_side(invert=true);

// 底
upcube([$pcb_size[0], $pcb_size[1], $case_thickness]);
