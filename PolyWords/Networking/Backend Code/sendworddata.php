<?php
# FileName="Connection_php_mysql.htm"
# Type="MYSQL"^M# HTTP="true"
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";
$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);
$debug_info = '';
//$debug_info .= print_r($_POST)."\n";
$data = $_POST['data'];
$decoded_data = mysql_real_escape_string(base64_decode($data));
//echo "decoded_data = $decoded_data";
$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}
$game_id = mysql_real_escape_string($info['GameID']);
$server_q = mysql_real_escape_string($info['Server']);
$mode = 7 + $server_q;
$word = mysql_real_escape_string($info['Word']);
$score = mysql_real_escape_string($info['Score']);
$letters = mysql_real_escape_string($info['Letters']);
$type = $info['Type'];
$token = $info['Token'];
$query = "insert into in_progress_games set game_id = $game_id, word = \"$word\", score = $score, mode = $mode, notified = 1";
$debug_info .= "query-".$query."__";
mysql_query($query);
$query = "update gamedata set letters = \"$letters\" where game_id = $game_id";
$debug_info .= "query-".$query."__";
mysql_query($query);

// need to change the stuff below to put the notification in a queue

if ($mode == 7) {//it's the client device calling
	$token_type = "server_token";
	$my_token_type = "client_token";
	$debug_info .= 'I am client__';
} elseif ($mode == 8) {//it's the server device calling
	$token_type = "client_token";
	$my_token_type = "server_token";
	$debug_info .= 'I am server__';
}
$query = "select server_token, client_token from dev_tokens where game_id = $game_id limit 1";
$debug_info .= "query-$query--";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$debug_info .= $row[$my_token_type]."__";
if (!$row[$my_token_type]) {
	$query = "update dev_tokens set $my_token_type = \"$token\" where game_id = $game_id";
$debug_info .= "$query-query--";
	mysql_query($query);
}
$deviceToken = trim($row[$token_type],'<>');

$query = "select client_ready, server_ready from gamedata where game_id = $game_id";
$result = mysql_query($query);
$row = mysql_fetch_array($result);
$client_ready = $row['client_ready'];
$server_ready = $row['server_ready'];

if ($mode == 7 && $server_ready == $client_ready + 1) {
	$query = "update gamedata set client_ready = client_ready + 1 where game_id=$game_id";
	mysql_query($query);
	$query = "update dev_tokens set client_token = \"$token\" where game_id = $game_id";
	$debug_string .= "$query--";
	mysql_query($query);
}
if ($mode == 8 && $client_ready == $server_ready) {
	$query = "update gamedata set server_ready = server_ready + 1 where game_id=$game_id";
	mysql_query($query);
	$query = "update dev_tokens set server_token = \"$token\", where game_id = $game_id";
	mysql_query($query);
}

$debug_info .= "deviceToken-$deviceToken--";
$payload['aps'] = array('alert' => 'This is the alert text', 'badge' => 1, 'sound' => 'default');
$payload['game_id'] = $game_id;
$payload['word'] = $word;
$payload['score'] = $score;
$payload = json_encode($payload);
//$debug_info .= "$payload__";
//$apnsHost = 'gateway.sandbox.push.apple.com';
//$apnsPort = 2195;
//$apnsCert = '/usr/local/push/pwwpdeluxe.pem';

$streamContext = stream_context_create();
stream_context_set_option($streamContext, 'ssl', 'local_cert', '/usr/local/push/pwwpdeluxe.pem');

$apns = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $error, $errorString, 60, STREAM_CLIENT_CONNECT, $streamContext);
if (!$apns) {
    $debug_info .= "ERROR: $error - $errorString\n";
} else {
	$apnsMessage = chr(0) . chr(0) . chr(32) . pack('H*', str_replace(' ', '', $deviceToken)) . chr(0) . chr(strlen($payload)) . $payload;
//	echo "$apnsMessage\n";
	$resp=fwrite($apns, $apnsMessage);
//	echo "resp = $resp\n";
	socket_close($apns);
	fclose($apns);
}

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