<?php
// Named boundary: prefer JSON or allowlisted unserialize over raw unserialize.
// Copy into product sources; keep php-rg-allow only on intentional seams.

function decode_payload(string $raw): array
{
    $data = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
    if (! is_array($data)) {
        throw new InvalidArgumentException('payload must be a JSON object');
    }

    return $data;
}

function unserialize_allowlisted(string $raw, array $allowedClasses): object
{
    $value = unserialize($raw, ['allowed_classes' => $allowedClasses]); // php-rg-allow: allowlisted classes only
    if (! is_object($value)) {
        throw new InvalidArgumentException('expected object payload');
    }

    return $value;
}
