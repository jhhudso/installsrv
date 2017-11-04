<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is not already logged in then do nothing
    if (! isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        echo json_encode([
            "error" => 'unauthorized'
        ]);
        return;
    }
    
    $id = UUID::v4();
    $name = getRequest('name');
    $reference = getRequest('reference');
    $code = getRequest('code');
    $pricesell = getRequest('pricesell');
    $category = getRequest('category');
    
    if (empty($name) || empty($reference) || (empty($code) && $code !== "0") || empty($pricesell) || empty($category)) {
        echo json_encode([
            "error" => 'invalid input'
        ]);
        return;
    }
    
    include_once 'include/config.inc.php';
    
    try {
        $posdb = new PDO($dbconfig['pos']['dsn'], $dbconfig['pos']['username'], $dbconfig['pos']['password'], $dbconfig['pos']['options']);
    } catch (PDOException $e) {
        echo json_encode([
            "error" => 'Error connecting to POS DB. Caught exception: [' . $e->getMessage()
        ]);
        return;
    }
    
    // Generate random barcode using scheme
    // 4 00000 XXXXX where XXXXX is random and unique
    if ($code === "0") {
        include_once 'include/barcode.inc.php';
        
        do {
            $random_item_num = rand(0, 99999);
            $testcode = '400000' . sprintf('%05d', $random_item_num);
            
            // Generate check digit
            $sum = 0;
            $odd = true;
            for ($i = 11 - 1; $i > - 1; $i --) {
                $sum += ($odd ? 3 : 1) * intval($testcode[$i]);
                $odd = ! $odd;
            }
            $testcode = $testcode . ((string) ((10 - $sum % 10) % 10));
            
            try {
                $stmt = $posdb->prepare("SELECT code FROM products WHERE code = :code");
                $result = $stmt->execute(array(
                    ':code' => $testcode
                ));
                $rows = $stmt->fetchAll();
            } catch (PDOException $e) {
                echo json_encode([
                    "error" => 'Error inserting item during upc search. Caught exception: [' . $e->getMessage()
                ]);
                return;
            }
        } while (count($rows) > 0);
        
        $code = $testcode;
    }
    
    $results = '';
    try {
        $stmt = $posdb->prepare("INSERT INTO products (id, name, reference, code, pricesell, category, taxcat) VALUES (:id, :name, :reference, :code, :pricesell, :category, :taxcat)");
        $result = $stmt->execute(array(
            ':id' => $id,
            ':name' => $name,
            ':reference' => $reference,
            ':code' => $code,
            ':pricesell' => $pricesell,
            ':category' => $category,
            ':taxcat' => '000'
        ));
    } catch (PDOException $e) {
        echo json_encode([
            "error" => 'Error inserting item. Caught exception: [' . $e->getMessage()
        ]);
        return;
    }
    
    if ($result === false) {
        echo json_encode([
            "error" => 'Error inserting item. ' . $stmt->errorInfo()[2]
        ]);
        return;
    }
    
    echo json_encode([
        "result" => $result,
        "code" => $code
    ]);
    $stmt->closeCursor();
}
?>
