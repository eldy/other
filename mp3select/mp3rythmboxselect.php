#!/usr/bin/env php
<?php

$apiKey = '...';

$xmlFile = __DIR__ . '/data/rhythmdb.xml';
$xmlFileAfter = __DIR__ . '/data/rhythmdbnew.xml';
$targetDir = __DIR__ . '/out/';

if (!file_exists($xmlFile)) {
    die("File XML ".$xmlFile." not found.\n");
}

$xml = simplexml_load_file($xmlFile) or die("Failed to load file XML ".$xmlFile);

// Fonction pour convertir une date Excel en timestamp
function dateToYear($excelDate) {
    // Retourner l'année de la date calculée
    return (int) ($excelDate / 365);
}

function yearToDate($year) {
	return $year * 365;
}

// Fonction pour interroger l’API OpenAI
function getYearFromGPT($title, $artist, $album, $apiKey) {
	sleep(2);

    $prompt = "Quelle est l'année de sortie approximative de la chanson \"$title\" de l'artiste \"$artist\" ? Donne uniquement l'année en 4 chiffres.";

    $data = [
        //"model" => "gpt-4", // ou "gpt-3.5-turbo"
        //model" => "mistral-small-latest", // ou "gpt-3.5-turbo"
        "model" => "mistral-large-latest",
        "messages" => [
            ["role" => "user", "content" => $prompt]
        ],
        "temperature" => 0.2,
        "safe_prompt" => true
    ];

    $ch = curl_init('https://api.mistral.ai/v1/chat/completions');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            "Content-Type: application/json",
            "Authorization: Bearer $apiKey"
        ],
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($data)
    ]);

    print $prompt."\n";

    $response = curl_exec($ch);

    if (!$response) {
    	print 'Error A';
    	var_dump(curl_error($ch));
    	curl_close($ch);
    	return null;
    }

    $json = json_decode($response, true);

    curl_close($ch);

    if (isset($json['error'])) {
    	print 'Error B';
	    var_dump($response);exit;
    }


    if (isset($json['choices'][0]['message']['content'])) {
        $text = trim($json['choices'][0]['message']['content']);
        // Extraire l'année (4 chiffres)
        if (preg_match('/\b(19|20)\d{2}\b/', $text, $matches)) {
            return (int)$matches[0];
        }
    }

    var_dump($response);
    print 'Error C';

    return null;
}

$countia = 0;

foreach ($xml->entry as $entry) {
    if ((string)$entry['type'] !== 'song') continue;

    $title = (string)$entry->title;
    $artist = (string)$entry->artist;
    $rating = (int)$entry->rating;
    $comment = trim((string)$entry->comment);
    if ((int) $entry->date > 0) {
    	$year = dateToYear((int)$entry->date);
    } else {
    	$year = 0;
    }

    // Extraire le chemin du fichier
    $location = urldecode(str_replace('file://', '', (string)$entry->location));
    if (!file_exists($location)) {
        echo "Fichier introuvable : $location\n";
        continue;
    }

    print "location=".$location." date=".(int)$entry->date." year=".$year." rating=".$rating." comment=".$comment."\n";

    if ($year == 0) {
    	print "Year not defined, we search it...\n";
		$tmp = getYearFromGPT($title, $artist, '', $apiKey);
		//$tmp = 1990;

		$countia++;

		if ($tmp > 0) {
			$newdate = yearToDate($tmp);

			print "Found tmp=".$tmp." newdate=".$newdate."\n";

			$entry->date = $newdate;
		} else {
			print "Failed to get year, we save new xml file\n";

			$xml->asXML($xmlFileAfter);

			die("Failed to get year\n");
		}

		if ($countia > 5) {
			$xml->asXML($xmlFileAfter);
		}
    }

	if ($rating < 3) continue;
    if (!preg_match('/star (3|4|5)/i', $comment)) continue;
    if ($year < 1990 || $year > 1995) continue;

    // Construire le chemin de destination
    $baseName = basename($location);
    $destination = $targetDir . '/' . $baseName;

    if (!is_dir(dirname($destination))) {
        mkdir(dirname($destination), 0777, true);
    }

    copy($location, $destination);
    echo "Copy : $baseName (year : $year, note : $rating, comment : $comment)\n";
}

$xml->asXML($xmlFileAfter);

