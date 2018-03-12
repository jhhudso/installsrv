<?php
{
    include_once 'include/default.inc.php';
    
    session_start();
    
    // If user is not already logged in then take them to login page
    if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        exit();
    }
    
    $item_name = getRequest('item_name');
    $item_code = getRequest('item_code');
    $item_pricesell = getRequest('item_pricesell');
    $view = getRequest('view');
    $print = getRequest('print');    
    
    if (empty($item_code) || empty($item_name) || empty($item_pricesell)) {
        exit();
    }
    
    if ($view != 1 && $print != 1) {
        exit();
    }
    
    if (!preg_match('/[A-Za-z0-9]/', $item_code)) {
        exit();
    }  

    if (isset($default_print_queue)) {
        if (isset($printconfig[$default_print_queue]['type']) && $printconfig[$default_print_queue]['type'] == 'escpos') {
            exec('./print_escpos.py');
            exit();
        }
    }
    
    include_once 'include/barcode.inc.php';
    
    // Code from http://barcode-coder.com/en/barcode-php-class-203.html
    // -------------------------------------------------- //
    //                  PROPERTIES
    // -------------------------------------------------- //
    
    $font     = 'fonts/DroidSans.ttf';
    
    $fontSize = 14;   // GD1 in px ; GD2 in point
    $marge    = 5;   // between barcode and hri in pixel
    $x        = 180;  // barcode center
    $y        = 50;  // barcode center
    $height   = 50;   // barcode height in 1D ; module size in 2D
    $width    = 2;    // barcode height in 1D ; not use in 2D
    $angle    = 0;   // rotation in degrees : nb : non horizontable barcode might not be usable because of pixelisation
    
    $code     = $item_code; // barcode, of course ;)
    $type     = 'upc';
    
    
    // -------------------------------------------------- //
    //            ALLOCATE GD RESSOURCE 
   // -------------------------------------------------- //
    $im     = imagecreatetruecolor(360, 100);
    $black  = ImageColorAllocate($im,0x00,0x00,0x00);
    $white  = ImageColorAllocate($im,0xff,0xff,0xff);
    $red    = ImageColorAllocate($im,0xff,0x00,0x00);
    $blue   = ImageColorAllocate($im,0x00,0x00,0xff);
    imagefilledrectangle($im, 0, 0, 360, 100, $white);
    
    // -------------------------------------------------- //
    //                      BARCODE
    // -------------------------------------------------- //
    $data = Barcode::gd($im, $black, $x, $y, $angle, $type, array('code'=>$code), $width, $height);
    
    // -------------------------------------------------- //
    //                        HRI
    // -------------------------------------------------- //
   
    if ( isset($font) ){
        $box = imagettfbbox($fontSize, 0, $font, $code[0].$data['hri']);
        $len = $box[2] - $box[0];
        Barcode::rotate(-$len / 2, ($data['height'] / 2) + $fontSize + $marge, $angle, $xt, $yt);
        imagettftext($im, $fontSize, $angle, $x + $xt, $y + $yt, $black, $font, $code[0].$data['hri']);
        
        $box2 = imagettfbbox($fontSize, 0, $font, $item_name.'     $'.$item_pricesell);
        $len = $box2[2] - $box2[0];
        Barcode::rotate(-$len / 2, -($data['height'] / 2) - $fontSize + $marge, $angle, $xt, $yt);
        imagettftext($im, $fontSize, $angle, $x + $xt, $y + $yt, $black, $font, $item_name.'     $'.$item_pricesell);
        
    }
    // -------------------------------------------------- //
    //                    GENERATE
    // -------------------------------------------------- //
    if ($view == 1) {
        header('Content-type: image/png');
        $ret = imagepng($im);
    }
    
    if ($print == 1) {
        $ret = imagepng($im, 'tmp/'.$item_code.'.png');
        if (isset($default_print_queue)) {
            exec('lp -d '.$default_print_queue.' tmp/'.$code.'.png');
        } else {
            exec('lp -d remote-QL-570 tmp/'.$code.'.png');
        }
    }
    exec('rm tmp/'.$item_code.'.png');
    imagedestroy($im);
}    
?>
