set -eu
# TODO add validation with profiles (not via env vars)

# Validates that properties are correctly set
: $AWS_REGION $AWS_DEFAULT_REGION $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY > /dev/null