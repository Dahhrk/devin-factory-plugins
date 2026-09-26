# Boundary: no export of secret-named vars; use host/CI env.
export RUST_BACKTRACE := "1"

test:
  cargo test
