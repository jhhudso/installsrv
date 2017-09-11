<?php
function drawBorder(&$img, &$color, $thickness = 1)
{
    $x1 = 0;
    $y1 = 0;
    $x2 = ImageSX($img) - 1;
    $y2 = ImageSY($img) - 1;
    
    for($i = 0; $i < $thickness; $i++)
    {
        ImageRectangle($img, $x1++, $y1++, $x2--, $y2--, $color);
    }
}

{
    header ('Content-Type: image/png');
    $img = @imagecreatetruecolor(234, 109)
    or die('Cannot Initialize new GD image stream');
    
    $bgColor = imagecolorallocate($img, 255, 255, 255);
    imagefill($img, 0, 0, $bgColor);
    
    $text_color = imagecolorallocate($img, 0, 0, 0);
    for($i=0; $i < 11; $i++) {
        imagestring($img, 4, 1, 1+(15*$i), '012345678901234567', $text_color);
    }
    imagestring($img, 4, 1, 1+(15*$i), '----45678901234567', $text_color);
    
    $border_color = imagecolorallocate($img, 0, 0, 0);
    drawBorder($img, $border_color);
    
    imagepng($img);
    imagedestroy($img);
}
?>