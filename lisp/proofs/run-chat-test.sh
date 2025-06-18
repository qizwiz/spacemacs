#!/bin/bash

# Run the test and automatically respond to the prompt
expect -c '
    spawn emacs --batch -l lisp/proofs/run-chat-test.el
    expect {
        "No Codeium API key found" {
            send "auto\r"
            exp_continue
        }
        eof
    }
'
