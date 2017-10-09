<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is already logged in then take them to the main page
    if (isset($_SESSION['authorized']) && $_SESSION['authorized'] === true) {
        header('Location: main.php');
        exit();
    }
    
    if (isset($_REQUEST['username'])) {
        $username = $_REQUEST['username'];
    } else {
        $username='';
    }
    
    $username_error='';
    $password_error='';
       
    if (isset($_REQUEST['submit']) && $_REQUEST['submit'] == 'login') {
        // class is autoloaded from include/Auth.php
        $auth = new Auth();
        
        try {
            $authorized = $auth->authenticate($_REQUEST['username'], $_REQUEST['password']);
        } catch (Exception $e) {
            switch($e->getCode()) {
                case 1: // username contained invalid characters
                    $username_error = $e->getMessage();
                    break;
            }
        }
        
        if (isset($authorized)) {
            if ($authorized === true) {
                $_SESSION['authorized'] = true;
                header('Location: main.php');
                exit();
            } else {
                $password_error = 'Invalid password';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link href="css/style.css" rel="stylesheet" type="text/css">
<title>Login Page</title>
</head>
<body>
<div class="login">
	<h1>Inventory</h1>
    <form method="post" enctype="application/x-www-form-urlencoded" action="login.php">
    	<input type="text" name="username" placeholder="Username" value="<?php echo $username; ?>" required="required" /><?php showError($username_error); ?>
        <input type="password" name="password" placeholder="Password" required="required" /><?php showError($password_error); ?>
        <button type="submit" name="submit" value="login" class="btn btn-primary btn-block btn-large">Login</button>
    </form>
</div>
</body>
</html>