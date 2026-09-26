<?php
// Good fixture: binds, allowlisted unserialize, documented allow.

function find_ok(PDO $pdo, int $id): ?array
{
    $stmt = $pdo->prepare('SELECT id, name FROM users WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row === false ? null : $row;
}

function decode_ok(string $raw): array
{
    return json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
}

// Documented intentional seam (boot probe); keep allow on the smell line.
function documented_legacy(string $code)
{
    return eval($code); // php-rg-allow: fixture documents allow marker for intentional eval seam
}
