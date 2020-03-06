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
$game_id = mysql_real_escape_string($info['GameID']);
$query = "delete from in_progress_games where game_id = $game_id";
//echo "query = $query \n";
mysql_query($query);
?>
