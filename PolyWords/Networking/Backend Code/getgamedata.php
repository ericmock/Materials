<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
$debug_string = '';
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
//print_r($_POST);
$game_id = mysql_real_escape_string($_POST['GameID']);
$type = mysql_real_escape_string($_POST['Type']);
$token = $_POST['Token'];
//we need to determine mode from previous data
//$mode = mysql_real_escape_string($_POST['Mode']);
$query = "select letters, polyhedron from gamedata where game_id = $game_id";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$letters = $row['letters'];
$polyhedron = $row['polyhedron'];
//$client_ready = $row['client_ready'];
//$server_ready = $row['server_ready'];
$query = "select server_token, client_token from dev_tokens where game_id = $game_id limit 1";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$server_token = $row['server_token'];
$client_token = $row['client_token'];

if ($token == $server_token) $mode = 8;
else if ($token == $client_token) $mode = 7;
else $mode = 7; // we must be joining a new game

$debug_string .= "mode $mode--server_ready $server_ready--client_ready $client_ready--";

// don't update things here...  do it when a word is played
//if ($mode == 7 && $server_ready == $client_ready + 1) {
//	$query = "update gamedata set client_ready = client_ready + 1 where game_id=$game_id";
//	mysql_query($query);
//	$query = "update dev_tokens set client_token = \"$token\" where game_id = $game_id";
//	$debug_string .= "$query--";
//	mysql_query($query);
//}
//if ($mode == 8 && $client_ready == $server_ready) {
//	$query = "update gamedata set server_ready = server_ready + 1 where game_id=$game_id";
//	mysql_query($query);
//	$query = "update dev_tokens set server_token = \"$token\", where game_id = $game_id";
//	mysql_query($query);
//}

$scores = array();

$query = "select sum(score) as scores from `in_progress_games` where game_id = $game_id and mode = 7";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$debug_string .= $row['scores'];
$scores['client'] = $row['scores'];

$query = "select sum(score) as scores from `in_progress_games` where game_id = $game_id and mode = 8";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$debug_string .= $row['scores'];
$scores['server'] = $row['scores'];

$query = "select client_token, server_token from dev_tokens where game_id = $game_id";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$server_token = $row['server_token'];
$client_token = $row['client_token'];
$their_score = 0;
$my_score = 0;
if ($mode == 8) { // we're the server
	$my_score = $scores['server'];
	$their_score = $scores['client'];
} elseif ($mode == 7) { // we're the client
	$my_score = $scores['client'];
	$their_score = $scores['server'];
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
	echo "<integer>".(($my_score)?($my_score):(0))."</integer>\n";
	echo "<integer>".(($their_score)?($their_score):(0))."</integer>\n";
	echo "<integer>".(($mode==7)?"0":"1")."</integer>\n";
} else {
	echo "<string>0</string>";
	echo "<string>0</string>";
	echo "<integer>0</integer>\n";
	echo "<integer>0</integer>\n";
	echo "<integer>0</integer>\n";
}
echo "</array>\n";
echo "<key>debug_info</key>\n";
echo "<string>\n";
echo urlencode($debug_string);
echo "</string>\n";
echo "</dict>\n";
echo "</plist>\n";
?>
