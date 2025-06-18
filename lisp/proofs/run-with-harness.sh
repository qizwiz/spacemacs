#!/bin/bash

# Make this script executable
chmod +x "$0"

# Run the test with expect to handle any prompts
expect -c '
    set timeout 30
    spawn emacs --batch -l lisp/proofs/run-with-harness.el
    
    # Handle API key prompt if it appears
    expect {
        -re "No Codeium API key found" {
            send "test-api-key-123\r"
            exp_continue
        }
        -re "Enter your Codeium API key" {
            send "test-api-key-123\r"
            exp_continue
        }
        eof
    }
    
    # Check exit code
    set waitval [wait -i $spawn_id]
    set exitcode [lindex $waitval 3]
    exit $exitcode
'

# Capture the exit code from expect
EXIT_CODE=$?

# Print final status
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed with exit code $EXIT_CODE"
fi

exit $EXIT_CODE
