# Boundary: no set dotenv-*; secrets come from CI/OIDC / host env.
serve:
  ./server --port {{ port }}
