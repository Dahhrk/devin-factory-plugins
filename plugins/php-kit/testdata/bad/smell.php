<?php
// Intentional smells for php-rg-gate discrimination (not product code).

function run_bad(string $code)
{
    return eval($code);
}

function load_bad(string $payload)
{
    return unserialize($payload);
}

function query_bad(PDO $pdo, string $id)
{
    return $pdo->query("SELECT * FROM users WHERE id = ".$id);
}

function raw_bad($query, string $name)
{
    return $query->whereRaw("name = ".$name);
}
