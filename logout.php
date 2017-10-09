<?php
{
    include_once 'include/default.inc.php';
    
    session_start();    
    unset($_SESSION);
    session_destroy();

    header('Location: login.php');
}
?>