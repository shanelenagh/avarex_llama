# Create windows dist directory
New-Item -ItemType Directory -Force -Path dist-windows
# Force build of plugin DLL and dependent (e.g., llama.cpp) DLL's, and copy them to dist directory
flutter build windows --release
Get-ChildItem -Path ".\build\windows\x64\runner\Release\*.dll" | Copy-Item -Destination ".\dist-windows\"
Get-ChildItem -Path ".\dist-windows\flutter*.dll" | Remove-Item # Delete flutter runtime DLL, as it is huge and not needed (this is pure compiled Dart CLI)
# AOT compile the API server app, bundled with the Dart runtime
dart compile exe bin\server.dart -o dist-windows\server.exe
# Copy the config file to the dist directory
Copy-Item -Path ".\application.yaml" -Destination ".\dist-windows\application.yaml"
# Get the configured LLM model
$ProgressPreference = 'SilentlyContinue' # Hacky windows Powershell download speed optimization - https://github.com/PowerShell/PowerShell/issues/13414
Invoke-WebRequest -Uri "https://huggingface.co/ibm-granite/granite-3.3-2b-instruct-GGUF/resolve/main/granite-3.3-2b-instruct-Q5_1.gguf?download=true" -OutFile "dist-windows\granite-3.3-2b-instruct-Q5_1.gguf"