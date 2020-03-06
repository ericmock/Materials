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
$mode = mysql_real_escape_string($_GET['m']);
$level = mysql_real_escape_string($_GET['l']);
$query = "select * from scores where level = $level and mode = $mode and score > 0 and time_stamp is not null order by score desc";
//echo "query = $query \n";
$result = mysql_query($query);
$scores_array = array();
while ($row = mysql_fetch_array($result)) {
    $scores_array[] = "{ score: \"".$row['score']."\", date: \"".$row['time_stamp']."\"}";
//    $new_scores_array[] = "<string>".$row['score']."</string>\n";
}
echo "{\ntitle: 'High Scores',\nitems: [\n";
echo implode(",\n",$scores_array);
echo "\n]\n}";
?>