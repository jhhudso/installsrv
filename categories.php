<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is not already logged in then do nothing
    if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        echo 'unauthorized';
        die();
    }

    include_once 'include/config.inc.php';
    
    try {
        $posdb = new PDO($dbconfig['pos']['dsn'], $dbconfig['pos']['username'], $dbconfig['pos']['password'], $dbconfig['pos']['options']);
    } catch(PDOException $e) {
        echo 'Error connecting to POS DB. Caught exception: [',  $e->getMessage(), "]\n";
        die();
    }
    
    $stmt = $posdb->prepare("SELECT id,name FROM categories ORDER BY catorder;");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode($results);
    $stmt->closeCursor();    
}
?>
