Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Creating windows distribution directory (dist-windows)..."
New-Item -ItemType Directory -Force -Path dist-windows
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Building app via flutter build (which triggers plugin build for llama.cpp C++ FFI wrapper)..."
flutter build windows --release
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Copying DLL's from plugin (including llama.cpp built DLL's) into dist directory..."
Get-ChildItem -Path ".\build\windows\x64\runner\Release\*.dll" | Copy-Item -Destination ".\dist-windows\"
Get-ChildItem -Path ".\dist-windows\flutter*.dll" | Remove-Item # Delete flutter runtime DLL, as it is huge and not needed (this is pure compiled Dart CLI)
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): AOT compiling REST server app..."
dart compile exe bin\server.dart -o dist-windows\server.exe
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Copying app config file to dist directory..."
Copy-Item -Path ".\application.yaml" -Destination ".\dist-windows\application.yaml"
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Downloading LLM model (this may take a bit, as it is large)..."
$ProgressPreference = 'SilentlyContinue' # Hacky windows Powershell download speed optimization - https://github.com/PowerShell/PowerShell/issues/13414
Invoke-WebRequest -Uri "https://huggingface.co/ibm-granite/granite-3.3-2b-instruct-GGUF/resolve/main/granite-3.3-2b-instruct-Q5_1.gguf?download=true" -OutFile "dist-windows\granite-3.3-2b-instruct-Q5_1.gguf"
Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): Dllama API POC build done!"