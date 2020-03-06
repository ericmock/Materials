<?php
$hostname = "localhost";
$database = "polywords";
$username = "root";
$password = "cire1069";

$mysql = mysql_pconnect($hostname, $username, $password) or die(mysql_error());
mysql_select_db($database, $mysql);

$data = $_POST['data'];
$decoded_data = base64_decode($data);

$data_array = explode("&",$decoded_data);
foreach ($data_array as $value) {
	$temp_array = explode("=",$value);
	$info[$temp_array[0]] = $temp_array[1];
}

$type = $info['Type'];
$token = mysql_real_escape_string($info['Token']);
$query = "select g.game_id, g.polyhedron, d.client_token, d.server_token, g.server_ready, g.client_ready from dev_tokens d, gamedata g where d.game_id=g.game_id and (d.client_token = \"$token\" or d.server_token = \"$token\") group by d.game_id";

$result = mysql_query($query);
$game_info = '';
while ($row = mysql_fetch_array($result)) {
	$ready = 0;
	$server_token = $row['server_token'];
	$client_token = $row['client_token'];
	$server_ready = $row['server_ready'];
	$client_ready = $row['client_ready'];
	if ($token == $server_token && $client_ready == $server_ready) $ready=1;
	if ($token == $client_token && $server_ready > $client_ready) $ready=1;
	$game_info .= "<array>\n";
    $game_info .= "<integer>".$row['game_id']."</integer>\n";
    $game_info .= "<integer>".$row['polyhedron']."</integer>\n";
    $game_info .= "<integer>".$ready."</integer>\n";
    $game_info .= "</array>\n";
}


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

?>
