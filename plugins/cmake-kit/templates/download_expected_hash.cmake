# Boundary: file(DOWNLOAD) with EXPECTED_HASH on the same physical line (portable rg bar).
file(DOWNLOAD https://example.com/deps.tgz ${CMAKE_BINARY_DIR}/deps.tgz EXPECTED_HASH SHA256=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef)
