<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is not already logged in then do nothing
    if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        echo 'unauthorized';
        die();
    }

    if (isset($_REQUEST['all'])) {
        if (empty($_REQUEST['all'])) {
            die();
        }
        $code=$_REQUEST['all'].'%';        
        $name=$reference='%'.$_REQUEST['all'].'%';
    } else {
        if (isset($_REQUEST['reference'])) {
            $reference=$_REQUEST['reference'];
        } else {
            $reference='null';
        }
        
        if (isset($_REQUEST['code'])) {
            $code=$_REQUEST['code'];
        } else {
            $code='null';
        }
        
        if (isset($_REQUEST['name'])) {
            $name=$_REQUEST['name'];
        } else {
            $name='null';
        }
        
        if (isset($_REQUEST['pricesell'])) {
            $pricesell=$_REQUEST['pricesell'];
        } else {
            $pricesell='null';
        }        
    }      
    
    if (isset($_REQUEST['fullresults'])) {
        $fullresults = $_REQUEST['fullresults'];
    } else {
        $fullresults = 0;
    }
       
    try {
        $posdb = new PDO($dbconfig['pos']['dsn'], $dbconfig['pos']['username'], $dbconfig['pos']['password'], $dbconfig['pos']['options']);
    } catch(PDOException $e) {
        echo 'Error connecting to POS DB. Caught exception: [',  $e->getMessage(), "]\n";
        die();
    }
    
    if ($fullresults == 1) {
        $stmt = $posdb->prepare("SELECT * FROM products WHERE reference LIKE :reference OR code LIKE :code OR name LIKE :name ORDER BY name");
        $stmt->execute(array(':reference' => $reference, ':code' => $code, ':name' => $name));
        $results = $stmt->fetchAll(PDO::FETCH_GROUP|PDO::FETCH_ASSOC);        
    } else {
        $stmt = $posdb->prepare("SELECT reference AS result FROM products WHERE reference LIKE :reference UNION DISTINCT SELECT code AS result FROM products WHERE code LIKE :code UNION DISTINCT SELECT name AS result FROM products WHERE name LIKE :name");
        $stmt->execute(array(':reference' => $reference, ':code' => $code, ':name' => $name));
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    echo json_encode($results);
    $stmt->closeCursor();    
}
?>
