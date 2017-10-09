<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is not already logged in then do nothing
    if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        echo json_encode(["error" => 'unauthorized']);
        return;
    }

    $id = UUID::v4();
    $name = getRequest('name');
    $reference = getRequest('reference');
    $code = getRequest('code');
    $pricesell = getRequest('pricesell');
    $category = getRequest('category');
    
    if (empty($name) || empty($reference) || empty($code) || empty($pricesell) || empty($category)) {
        echo json_encode(["error" => 'invalid input']);
        return;
    }
    
    include_once 'include/config.inc.php';
    
    try {
        $posdb = new PDO($dbconfig['pos']['dsn'], $dbconfig['pos']['username'], $dbconfig['pos']['password'], $dbconfig['pos']['options']);
    } catch(PDOException $e) {
        echo json_encode(["error" => 'Error connecting to POS DB. Caught exception: [' . $e->getMessage()]);
        return;
    }
   
    $results = '';
    try {
        $stmt = $posdb->prepare("INSERT INTO products (id, name, reference, code, pricesell, category, taxcat) VALUES (:id, :name, :reference, :code, :pricesell, :category, :taxcat)");
        $result = $stmt->execute(array(':id' => $id, ':name' => $name, ':reference' => $reference, ':code' => $code, ':pricesell' => $pricesell, ':category' => $category, ':taxcat' => '000'));        
    } catch(PDOException $e) {
        echo json_encode(["error" => 'Error inserting item. Caught exception: [' . $e->getMessage()]);
        return;
    }
    
    if ($result === false) {
        echo json_encode(["error" => 'Error inserting item. '.$stmt->errorInfo()[2]]);
        return;
    }
    
    echo json_encode($result);
    $stmt->closeCursor();
}
?>
