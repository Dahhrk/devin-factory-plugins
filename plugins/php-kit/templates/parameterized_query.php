<?php
// Named boundary: prefer binds / query builder over SQL string concat.
// Copy into product sources; keep php-rg-allow only on intentional seams.

function find_user_by_id(PDO $pdo, int $id): ?array
{
    $stmt = $pdo->prepare('SELECT id, name FROM users WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row === false ? null : $row;
}
