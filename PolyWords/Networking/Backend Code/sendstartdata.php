<?php

$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
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
$game_id = mysql_real_escape_string($info['GameID']);
$mode = mysql_real_escape_string($info['Mode']);
//print_r($_POST);
if ($mode == 4) {
	$update_query = "update gamedata set client_ready = $mode where game_id = $game_id";
	$select_query = "select server_ready as ready from gamedata where game_id = $game_id";
}
elseif ($mode == 5) {
	$update_query = "update gamedata set server_ready = $mode where game_id = $game_id";
	$select_query = "select client_ready as ready from gamedata where game_id = $game_id";
}
mysql_query($update_query);
$continue_waiting = TRUE;
$time_counter = 0;
//echo 'got to while';
while ($continue_waiting) {
	$result = mysql_query($select_query);
	$row = mysql_fetch_array($result);
	if ($row['ready'] == 5 || $row['ready'] == 4) $continue_waiting = FALSE;
	usleep(500000);
	$time_counter += 0.5;
	if ($time_counter > 30) $continue_waiting = FALSE;
}
echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
echo '<plist version="1.0">'."\n";
echo "<array>\n";
echo "<string>".$row['ready']."</string>";
//echo "<string>5</string>";
echo "</array>\n";
echo "</plist>\n";
?>
