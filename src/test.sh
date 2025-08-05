cmake --build .
mv Debug/llama_test.exe ../example/build/windows/x64/bin/Debug/
cd ../example/build/windows/x64/bin/Debug/
./llama_test.exe granite-3.3-2b-instruct-Q5_1.gguf "Who is Taylor Swift?"
