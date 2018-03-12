<?php

header("Cache-Control: max-age=0,no-cache,no-store,post-check=0,pre-check=0");

error_reporting(E_ALL);

// Disable on production copy of code
ini_set("display_errors", "On");
ini_set("session.cookie_lifetime", 0);
ini_set("session.use_cookies", "On"); 
ini_set("session.use_only_cookies", "On"); 
ini_set("session.use_strict_mode", "On"); 
ini_set("session.cookie_httponly", "On"); 
ini_set("session.cookie_secure", "On"); 
ini_set("session.use_trans_sid", "Off"); 
ini_set("session.cache_limiter", "nocache"); 
ini_set("session.sid_length", "48"); 
ini_set("session.sid_bits_per_character", "6"); 
ini_set("session.hash_function", "sha256"); 
    
include_once 'include/config.inc.php';

spl_autoload_register(function ($class_name) {
    include 'include/' . $class_name . '.php';
});
    
function showError($msg) {
    if ($msg) {
        echo '<div class=error>'.$msg.'</div>';
    }
}

function getRequest($key, $defaultValue = null) {
    if (isset($_REQUEST[$key])) {
        return $_REQUEST[$key];
    } else {
        return $defaultValue;
    }
}


// Code copied from Andrew Moore's comment http://php.net/manual/en/function.uniqid.php#94959  
class UUID {
    public static function v4() {
        return sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
            
            // 32 bits for "time_low"
            mt_rand(0, 0xffff), mt_rand(0, 0xffff),
            
            // 16 bits for "time_mid"
            mt_rand(0, 0xffff),
            
            // 16 bits for "time_hi_and_version",
            // four most significant bits holds version number 4
            mt_rand(0, 0x0fff) | 0x4000,
            
            // 16 bits, 8 bits for "clk_seq_hi_res",
            // 8 bits for "clk_seq_low",
            // two most significant bits holds zero and one for variant DCE1.1
            mt_rand(0, 0x3fff) | 0x8000,
            
            // 48 bits for "node"
            mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
            );
    }
}