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
$game_id = $_POST['GameID'];
$mode = $_POST['Mode'];
$words_array = explode("_",$_POST['NewWordsFound']);
$scores_array = explode("_",$_POST['NewWordScores']);
$counter = 0;
foreach ($words_array as $word) {
	$score = $scores_array[$counter];
	$query = "insert into in_progress_games set game_id = $game_id, word = \"$word\", score = $score, mode = $mode, timestamp = now()";
echo "<? query = $query />\n";
	$counter++;
	mysql_query($query);
}
$query = "select word, score from in_progress_games where game_id = $game_id and mode != $mode and fetched = 0";
echo "<? query = $query />\n";
$result = mysql_query($query);
$query = "update in_progress_games set fetched = 1 where game_id = $game_id and mode != $mode";
echo "<? query = $query />\n";
mysql_query($query);
$new_words_array = array();
$new_scores_array = array();
while ($row = mysql_fetch_array($result)) {
    $new_words_array[] = "<string>".$row['word']."</string>\n";
    $new_scores_array[] = "<string>".$row['score']."</string>\n";
}

if (sizeof($new_words_array)) {
	echo '<?xml version="1.0" encoding="UTF-8"?>'."\n";
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'."\n";
	echo '<plist version="1.0">'."\n";
	echo "<array>\n";
	echo "<array>\n";
	echo implode("",$new_words_array);
	echo "</array>\n";
	echo "<array>\n";
	echo implode("",$new_scores_array);
	echo "</array>\n";
	echo "</array>\n";
	echo "</plist>\n";
}
?>
