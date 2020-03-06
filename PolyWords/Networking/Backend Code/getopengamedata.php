<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
//print_r($_POST);
$game_id = $_POST['GameID'];
$type = $_POST['Type'];
$query = "select letters, polyhedron from gamedata where game_id = $game_id";
//echo "<? query = $query>\n";
$result = mysql_query($query);

while ($row = mysql_fetch_array($result)) {
    $letters = $row['letters'];
    $polyhedron = $row['polyhedron'];
}

echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
echo '<plist version="1.0">'."\n";
echo "<dict>\n";
echo "<key>type</key>\n";
echo "<integer>$type</integer>\n";
echo "<key>game_info</key>\n";
echo "<array>\n";
if ($letters && $polyhedron) {
	echo "<string>$letters</string>\n";
	echo "<string>$polyhedron</string>\n";
} else {
	echo "<string>0</string>";
	echo "<string>0</string>";
}
echo "</array>\n";
echo "</dict>\n";
echo "</plist>\n";
?>
