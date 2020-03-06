<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$table = "scores";
$debug_info = "";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
//echo "_POST = ";print_r($_POST);echo "\n";
$data = mysql_real_escape_string($_POST['data']);
//echo "data = $data\n";
$decoded_data = base64_decode($data);
//echo "decoded_data = $decoded_data\n";
$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}
//print_r($info);
$letters = $info['Letters'];
$mode = $info['Mode'];
$game_id = $info['GameID'];
$poly_id = $info['PolyhedraID'];
$token = $info['Token'];
$type = $info['Type'];
$query = "insert into gamedata set letters = \"$letters\", polyhedron = $poly_id, game_id = $game_id, time_stamp = now()";
$debug_info .= $query;
//echo "query = $query \n";
mysql_query($query);
$query = "insert into dev_tokens set server_token = \"$token\", game_id = $game_id, time_stamp = now()";
//echo "query = $query \n";
mysql_query($query);
	echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
	echo '<plist version="1.0">'."\n";
	echo "<dict>\n";
	echo "<key>type</key>\n";
	echo "<integer>$type</integer>\n";
	echo "<key>debug</key>\n";
	echo "<string>".urlencode($debug_info)."</string>";
	echo "</dict>\n";
	echo "</plist>\n";

?>
