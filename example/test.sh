#flutter build windows --debug
cp -f ../src/Debug/* build/windows/x64/bin/Debug/
cp -f ../src/*.gguf build/windows/x64/bin/Debug/
cd build/windows/x64/bin/Debug
dart run ../../../../../lib/main.dart