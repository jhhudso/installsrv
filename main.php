<?php
{
    include_once 'include/default.inc.php';
    session_start();
    
    // If user is not already logged in then take them to login page
    if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
        header('Location: login.php');
        exit();
    }   
    
    $tool = getRequest('tool');
    if ($tool === "search" || $tool === "additem") {
        $_SESSION['tool'] = $tool;        
    } else if (isset($_SESSION['tool'])) {
        $tool = $_SESSION['tool'];
    } 
    if ($tool !== "search" && $tool !== "additem") {
        $tool = "search";
    }
    
    if (getRequest('onlyset') == 1) {
        exit();
    }
    
    $search = getRequest('search');
    $item_name = getRequest('item_name');
    $item_reference = getRequest('item_reference');
    $item_code = getRequest('item_code');
    $item_pricesell = getRequest('item_pricesell');
    
    $search_error='';
    $item_name_error='';
    $item_reference_error='';
    $item_code_error='';
    $item_pricesell_error='';
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link href="css/style.css" rel="stylesheet" type="text/css">
<title>Main menu :: <?php echo $tool; ?></title>
</head>
<script>
var allowSuggestionRemoval=0;
var lastsearch='';

function setSearchFocus() {
	document.getElementById('searchbox').focus();
}
function findSuggestions() {
	var newsearch = document.getElementById("searchbox").value;
	if (newsearch === lastsearch) {
		return;
	} else {
		lastsearch = newsearch;
	}
	
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
	    if (this.readyState == 4 && this.status == 200) {
	     var suggestionbox = document.getElementById("suggestionbox");
	     if (this.responseText) {
    	     var jsonArray = JSON.parse(this.responseText);
    	     suggestionbox.innerHTML='';	     
    	     for (i = 0; i < jsonArray.length; i++) {
    	    	      suggestionbox.innerHTML += '<div onmouseover="this.style.background=\'gray\'; this.style.color=\'white\';" onmouseout="this.style.background=\'white\'; this.style.color=\'black\'" onclick="searchitems(\'' + jsonArray[i].result + '\');">' + jsonArray[i].result + '</div>';
    	     }
    	     suggestionbox.style.visibility = 'visible';
	     } else {
	    	 suggestionbox.style.visibility = 'hidden';
	    	 suggestionbox.innerHTML='';
	     }	    
	    }
	  };
	  xhttp.open("GET", "search.php?all="+newsearch, true);
	  xhttp.send();
}
function removeSuggestions() {
	if (allowSuggestionRemoval) {
		var suggestionbox = document.getElementById("suggestionbox");
		suggestionbox.style.visibility='hidden';
		allowSuggestionRemoval=0;
	} 
}
function showSuggestions() {
	var suggestionbox = document.getElementById("suggestionbox");
	if (suggestionbox.style.visibility == 'hidden' && suggestionbox.innerHTML) {
		suggestionbox.style.visibility='visible';
		allowSuggestionRemoval=1;
	} 
}
function searchitems(key) {
	var searchbox = document.getElementById("searchbox");
	if (key) {		
		searchbox.value = key;
		lastsearch = key;
	} else {
		key = searchbox.value;
	}
	
	allowSuggestionRemoval=1;
	removeSuggestions();
	
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
	    if (this.readyState == 4 && this.status == 200) {
	    	var results = document.getElementById("results");
			results.innerHTML = '';
	     	if (this.responseText) {	    	
		    	resultstable = document.createElement("TABLE");	 
		    	var header = resultstable.createTHead();
		    	header.style = 'font-weight: bold;';
		    	var row = header.insertRow(0);
				var colhead = row.insertCell(0);
				colhead.innerHTML = 'Name';
				var colhead = row.insertCell(1);
				colhead.innerHTML = 'Reference';
				var colhead = row.insertCell(2);
				colhead.innerHTML = 'Barcode';
				var colhead = row.insertCell(3);
				colhead.innerHTML = 'Price';

				var body = resultstable.createTBody();
	    		var items = JSON.parse(this.responseText);
	    		var rownr = 0;
	    		for (item in items) {		    		
		    		var row = body.insertRow(rownr++);
		    		var resname = row.insertCell(0);
		    		resname.innerHTML = items[item][0].name;
		    		var resreference = row.insertCell(1);
		    		resreference.innerHTML = items[item][0].reference;
		    		var rescode = row.insertCell(2);
		    		rescode.innerHTML = items[item][0].code;
		    		var respricesell = row.insertCell(3);
		    		respricesell.innerHTML = '$'+items[item][0].pricesell;		    				    		    		
	    		}
	    		results.appendChild(resultstable);
	     	} else {
		     results.innerHTML = '';
	    	}
	    }
	  };
	  
	  xhttp.open("GET", "search.php?fullresults=1&all="+key, true);
	  xhttp.send();	
}
function additem(printbarcode) {
	var addresults = document.getElementById("addresults");
	addresults.innerHTML = '';
	
	var namebox = document.getElementById("namebox");
	var referencebox = document.getElementById("referencebox");
	var codebox = document.getElementById("codebox");
	var pricesellbox = document.getElementById("pricesellbox");
	var categoryselect = document.getElementById("categoryselect");

	if (namebox.value.length < 1 || referencebox.value.length < 1 || codebox.value.length < 1 || pricesellbox.value.length < 1 || isNaN(Number(pricesellbox.value))) {
		addresults.innerHTML = 'Invalid input';
		addresults.className = 'error';
		return;
	}

	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = (function(x,name,code,pricesell,printbarcode) {		
    	return function() {
    	    if (x.readyState == 4 && x.status == 200) {
    	     	if (x.responseText) {
    		     	if (x.response === 'true') {
        		     	var addresults = document.getElementById("addresults");
    		     		addresults.innerHTML = '';
    	     			addresults.className = 'nonerror';
    					addresults.innerHTML = 'Item added!';
    					document.getElementById("addform").reset();
    					
      					// print barcode
      					if (printbarcode) {
        					var barcodexhttp = new XMLHttpRequest();
        					barcodexhttp.open("GET", "barcode.php?item_name="+name+"&item_code="+code+"&item_pricesell="+pricesell+"&print=1", true);
        					barcodexhttp.send();
      					}	
    		     	} else {           		     	
    			     	var error = JSON.parse(x.response);
    			     	var addresults = document.getElementById("addresults");
    			     	addresults.innerHTML = '';
    			     	addresults.className = 'error';
    			     	addresults.innerHTML = error["error"];        			     				     	
    		     	}
    	    	}
    	    }
    	}
	})(xhttp,namebox.value,codebox.value,pricesellbox.value,printbarcode)
		  
	xhttp.open("GET", "additem.php?name="+namebox.value+"&reference="+referencebox.value+"&code="+codebox.value+"&pricesell="+pricesellbox.value+"&category="+categoryselect.value, true);	  
	xhttp.send();	
}
function showadditem() {
	var searchdiv = document.getElementById("search");
	searchdiv.style.display='none';
	var adddiv = document.getElementById("add");
	adddiv.style.display='block';

	document.title = 'Main menu :: additem';
	
	var xhttp = new XMLHttpRequest();
	xhttp.open("GET", "main.php?onlyset=1&tool=additem", true);
	xhttp.send();
}
function showsearch() {
	var adddiv = document.getElementById("add");
	adddiv.style.display='none';
	var searchdiv = document.getElementById("search");
	searchdiv.style.display='block';
	
	document.title = 'Main menu :: search';
	
	var xhttp = new XMLHttpRequest();
	xhttp.open("GET", "main.php?onlyset=1&tool=search", true);
	xhttp.send();
}
function findCategories() {
    var categoryselect = document.getElementById('categoryselect');
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
        	var categoryselect = document.getElementById('categoryselect');
         	if (this.responseText) {	    	
        		var categories = JSON.parse(this.responseText);
        		for (category in categories) {
        			var option = document.createElement("option");
        			option.text = categories[category].name;
        			option.value = categories[category].id; 
        			categoryselect.add(option); 
        		}
        	}
        }
    }
    
    xhttp.open("GET", "categories.php", true);
    xhttp.send();
}
function ReferencetoBarcode() {
	var codebox = document.getElementById("codebox");
	var referencebox = document.getElementById("referencebox");
	codebox.value = referencebox.value;
}
</script>
<body onload='setSearchFocus()'>
<div id=search class="search">
	<h1>Search Inventory</h1>
    <form id=searchform method="post" enctype="application/x-www-form-urlencoded" action="main.php?tool=search">
    	<input id="searchbox" type="text" size="100" name="search" placeholder="Item barcode, model or name" onkeyup="findSuggestions()" onfocusout="removeSuggestions()" onfocus="showSuggestions()" autocomplete="off" value="<?php echo $search; ?>" /><?php showError($search_error); ?>
    	<div onmouseover="allowSuggestionRemoval=0;" onmouseout="allowSuggestionRemoval=1;" class="suggestions" id=suggestionbox></div>
    	<div align="right"><button id=searchbutton onclick="searchitems(); return false;" type="submit" name="submit" value="search" class="btn btn-primary  btn-large">Search</button>
        <button type="submit" id=addbutton onclick="showadditem(); return false;" name="submit" value="add" class="btn btn-primary  btn-large">Add item</button></div>
    </form>
    <div id=results></div>    
</div>
<div id=add class="add">
    <h1>Add to Inventory</h1>
    <form id=addform method="post" enctype="application/x-www-form-urlencoded" action="main.php?tool=additem">
        Name:      <input type="text" size="25" id="namebox"        name="name"      placeholder="Full name of item"          autocomplete="off" required value="<?php echo $item_name; ?>"      /><?php showError($item_name_error); ?>
        Reference: <input type="text" size="25" id="referencebox"   name="reference" placeholder="Model or reference keyword" autocomplete="off" required value="<?php echo $item_reference; ?>" /><?php showError($item_reference_error); ?>
   <div>Barcode:   <input type="text" maxlength="12" id="codebox"   name="code"      placeholder="Barcode"                    autocomplete="off" required value="<?php echo $item_code; ?>"      /><button onclick="ReferencetoBarcode(); return false;" class="btn btn-primary">Use Reference as Barcode</button><?php showError($item_code_error); ?></div>
    	Price:     <input type="text" size="25" id="pricesellbox"   name="pricesell" placeholder="Sell price"                 autocomplete="off" required value="<?php echo $item_pricesell; ?>" /><?php showError($item_pricesell_error); ?>
    	Category:  <select                      id="categoryselect" name="category"></select>
    	<div align="right" style="float: right;"><button id=addbutton onclick="additem(false); return false;" type="submit" name="submit" value="add" class="btn btn-primary btn-large">Add item</button>
    	                   <button id=addbutton onclick="additem(true);  return false;" type="submit" name="submit" value="add" class="btn btn-primary btn-large">Add item &amp; Print Barcode</button>
    	                   <button              onclick="showsearch(); return false;"  type="submit" name="submit" value="returntosearch" class="btn btn-primary btn-large">Return to Search</button></div>      
    </form>
    <div id=addresults></div>   
</div>
</body>
<script>
<?php if ($tool === "search") {
    echo "document.getElementById('add').style.display='none';";
    echo "document.getElementById('search').style.display='block';";
} else if ($tool === "additem") {
    echo "document.getElementById('search').style.display='none';";
    echo "document.getElementById('add').style.display='block';";
}
?>

findCategories();
</script>
</html>