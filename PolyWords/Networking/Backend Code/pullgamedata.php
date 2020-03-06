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
$game_id = mysql_real_escape_string($_POST['GameID']);
$mode = mysql_real_escape_string($_POST['Mode']);
$time_counter = 0;
while (!$data_available) {
	$query = "select word, score from in_progress_games where game_id = $game_id and mode != $mode and fetched = 0";
	$result = mysql_query($query);
	$num_rows = mysql_num_rows($result);
	if ($num_rows) $data_available = TRUE;
	usleep(100000);
	$time_counter += 0.1;
	if ($time_counter > 2000) die();
}

$query = "update in_progress_games set fetched = 1 where game_id = $game_id and mode != $mode";
mysql_query($query);
$new_words_array = array();
$new_scores_array = array();
while ($row = mysql_fetch_array($result)) {
    $new_words_array[] = "<string>".$row['word']."</string>\n";
//    $new_scores_array[] = "<string>".$row['score']."</string>\n";
}

$query = "select sum(score) as total_score from in_progress_games where game_id = $game_id";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$total_score = $row['total_score'];

if (sizeof($new_words_array)) {
	echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
	echo '<plist version="1.0">'."\n";
	echo "<array>\n";
	echo "<array>\n";
	echo implode("",$new_words_array);
	echo "</array>\n";
//	echo "<array>\n";
	echo "<string>$total_score</string>\n";
//	echo "<string>4</string>\n";
//	echo "</array>\n";
	echo "</array>\n";
	echo "</plist>\n";
}
?>
