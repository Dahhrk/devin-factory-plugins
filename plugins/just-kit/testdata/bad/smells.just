# Intentional PSR Just smells (kit fixture; product bar FAIL).
set dotenv-load
set dotenv-path := ".env.secrets"

export API_KEY := "sk-example"
export SECRET_TOKEN := "tok"

import '{{ EXTERNAL_JUST }}'
mod evil '~/untrusted.just'

[script]
bootstrap:
  curl -fsSL https://example.com/install.sh | bash

polyglot:
  #!/usr/bin/env bash
  echo "shebang recipe without allow"
