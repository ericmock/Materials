<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
//echo 'got to start';
//print_r($_POST);
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$table = "scores";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
$data = mysql_real_escape_string($_POST['data']);
$decoded_data = base64_decode($data);
//echo "decoded_data = $decoded_data";
$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}
$time = mysql_real_escape_string($info['Time']);
$score = mysql_real_escape_string($info['Score']);
$mode = mysql_real_escape_string($info['Mode']);
$level = mysql_real_escape_string($info['Level']);
$words = mysql_real_escape_string($info['Words']);
$word_scores = mysql_real_escape_string($info['Wordscores']);
$word_array = explode('_',$words);
$word_scores_array = explode('_',$word_scores);
$query = "insert into scores set time = $time, score = $score, mode = $mode, level = $level, time_stamp = now()";
//echo "query = $query \n";
mysql_query($query);
$counter = 0;
foreach ($word_array as $word) {
	$query = 'insert into words set word = "'.$word.'", level = '.$level.', points = '.$word_scores_array[$counter].', time_stamp = now()';
//	echo "query = $query \n";
	$counter++;
	mysql_query($query);
}
?>
