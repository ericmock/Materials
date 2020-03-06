<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$table = "scores";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
//print_r($_POST);
$data = mysql_real_escape_string($_POST['data']);
$decoded_data = base64_decode($data);
//echo "decoded_data = $decoded_data";
$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}
//print_r($info);
$type = $info['Type'];
$token = $info['Token'];
$query = "select gd.game_id, gd.polyhedron from gamedata gd, dev_tokens dt where gd.client_ready = 0 and gd.game_id = dt.game_id and dt.server_token != \"$token\"";
//echo "query = $query \n";
$result = mysql_query($query);
$game_info = '';
while ($row = mysql_fetch_array($result)) {
	$game_info .= "<array>\n";
    $game_info .= "<integer>".$row['game_id']."</integer>\n";
    $game_info .= "<integer>".$row['polyhedron']."</integer>\n";
    $game_info .= "</array>\n";
}

//echo "response = $type,$token";
// while ($row = mysql_fetch_array($result)) {
//     $new_words_array[] = "<string>".$row['word']."</string>\n";
//     $new_scores_array[] = "<string>".$row['score']."</string>\n";
// }

	echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
	echo '<plist version="1.0">'."\n";
	echo "<dict>\n";
	echo "<key>type</key>\n";
	echo "<integer>$type</integer>\n";
	echo "<key>game_info</key>\n";
	echo "<array>\n";
	echo $game_info;
	echo "</array>\n";
echo "<key>debug_info</key>\n";
echo "<string>\n";
echo urlencode($debug_string);
echo "</string>\n";
	echo "</dict>\n";
	echo "</plist>\n";

//$query = "insert into gamedata set letters = \"$letters\", polyhedron = $poly_id, game_id = $game_id, tokentime_stamp = now()";
//echo "query = $query \n";
//mysql_query($query);
//$query = "insert into dev_tokens set server_token = \"$token\", game_id = $game_id, time_stamp = now()";
//echo "query = $query \n";
//mysql_query($query);
?>
