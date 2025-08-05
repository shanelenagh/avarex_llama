cmake .
cmake --build .
curl -C - -L https://huggingface.co/ibm-granite/granite-3.3-2b-instruct-GGUF/resolve/main/granite-3.3-2b-instruct-Q5_1.gguf?download=true -o granite-3.3-2b-instruct-Q5_1.gguf
if [[ "$(uname -s)" == "Linux" ]]; then
    cp llama_test bin/
    ./bin/llama_test granite-3.3-2b-instruct-Q5_1.gguf "What is the starting height of class A airspace?" 20
else
  cp bin/Debug/* Debug/
  ./Debug/llama_test granite-3.3-2b-instruct-Q5_1.gguf "What is the starting height of class A airspace?" 20
fi
