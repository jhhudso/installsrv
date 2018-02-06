<?php

$dbconfig = array();

$dbconfig['pos']['dsn'] = 'mysql:dbname=unicentaopos;host=localhost'; 
$dbconfig['pos']['username'] = 'unicentaopos';
$dbconfig['pos']['password'] = 'password';
$dbconfig['pos']['options'] = array(PDO::ATTR_PERSISTENT => true);

$dbconfig['auth']['dsn'] = 'mysql:dbname=osticket;host=localhost';
$dbconfig['auth']['username'] = 'osticket';
$dbconfig['auth']['password'] = 'password';
$dbconfig['auth']['options'] = array(PDO::ATTR_PERSISTENT => true);

$default_print_queue = 'remote-QL-570';

//$printconfig = array();
//$printconfig['pos']['type'] = 'escpos';

//$default_print_queue = 'pos';
