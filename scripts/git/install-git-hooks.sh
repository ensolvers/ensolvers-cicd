# register auto-formatting git hook
echo 'npx prettier --write "modules/frontend/src/**/*.{js,ts,jsx,tsx}"' > .git/hooks/pre-commit
echo 'mvn clean process-resources' >> .git/hooks/pre-commit

# ensure that hook is executable
chmod +x .git/hooks/pre-commit
