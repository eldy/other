#!/usr/bin/env php
<?php

require 'vendor/autoload.php';

use getID3;

$sourceDir = '/mnt/HDDATA1_LD/Mes Musiques/';
$targetDir = __DIR__ . '/isen36/';

$getID3 = new getID3();

$rii = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($sourceDir));

$i = 0;
foreach ($rii as $file) {
    if ($file->isDir()) continue;

    if (strtolower($file->getExtension()) !== 'mp3') continue;

    $filePath = $file->getPathname();
    $info = $getID3->analyze($filePath);

    // Tente de récupérer l'année
    $year = null;
    if (!empty($info['tags']['id3v2']['year'][0])) {
        $year = (int) $info['tags']['id3v2']['year'][0];
    } elseif (!empty($info['tags']['id3v1']['year'][0])) {
        $year = (int) $info['tags']['id3v1']['year'][0];
    }

    // Tente de récupérer la note (rating) depuis POPM
    $rating = null;
    if (!empty($info['id3v2']['comments']['popularimeter'][0]['rating'])) {
        $rawRating = $info['id3v2']['comments']['popularimeter'][0]['rating'];
        // Normalisation : Windows Media Player utilise un score de 1 à 255
        $rating = round($rawRating / 51); // ~0-5 étoiles
    }

    // Get comment
    $comment = null;
    if (!empty($info['tags']['id3v2']['comment'][0])) {
        $comment = trim($info['tags']['id3v2']['comment'][0]);
    } elseif (!empty($info['tags']['id3v1']['comment'][0])) {
        $comment = trim($info['tags']['id3v1']['comment'][0]);
    }

    print $filePath." year=".$year." rating=".$rating." comment=".$comment."\n";

    if ($year >= 1990 && $year <= 1995 && preg_match('/Star (3|4|5)/', $comment)) {
        // Calcul du chemin relatif
        $relativePath = str_replace($sourceDir, '', $filePath);
        $destination = $targetDir . $year.' - '.basename($relativePath);

        // Crée les répertoires nécessaires
        $destDir = dirname($destination);
        if (!is_dir($destDir)) {
            mkdir($destDir, 0777, true);
        }

        // Copie le fichier
        copy($filePath, $destination);
        echo "Copy : $relativePath (year : $year)\n";
    }

    $i++;

    if ($i > 0) {
    	exit;
    }
}

