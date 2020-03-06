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
$data = $_POST['data'];
$decoded_data = mysql_real_escape_string(base64_decode($data));
//echo "decoded_data = $decoded_data";
$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}
$game_id = mysql_real_escape_string($info['GameID']);
$mode = mysql_real_escape_string($info['Mode']);
$word = mysql_real_escape_string($info['Word']);
$score = mysql_real_escape_string($info['Score']);
$type = $info['Type'];
$query = "insert into in_progress_games set game_id = $game_id, word = \"$word\", score = $score, mode = $mode";
//echo "<? query = $query />\n";
mysql_query($query);

?>
