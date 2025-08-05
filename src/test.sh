cmake .
cmake --build .
cp bin/Debug/* Debug/   # Move shared libs in with EXE
# Now download model, iff it hasn't been downloaded yet
curl -C - -L https://huggingface.co/ibm-granite/granite-3.3-2b-instruct-GGUF/resolve/main/granite-3.3-2b-instruct-Q5_1.gguf?download=true -o Debug/granite-3.3-2b-instruct-Q5_1.gguf
./Debug/llama_test.exe Debug/granite-3.3-2b-instruct-Q5_1.gguf "What is the starting height of class A airspace?" 20
