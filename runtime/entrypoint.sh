#!/bin/bash

exit_code=0

{
    set -euxo pipefail

    cd /codeexecution

    echo "Unpacking submission..."
    unzip ./submission/submission.zip -d ./
    ls -alh

    if [ -f "main.py" ]
    then
        echo "Running submission with Python"
        conda run --no-capture-output -n condaenv python main.py
    else
        echo "ERROR: Could not find main.py in submission.zip"
        exit_code=1
    fi

    # Test that submission is valid
    echo "Testing that submission is valid"
    conda run -n condaenv pytest -v tests/test_submission.py

    echo "Compressing files in a gzipped tar archive for submission"
    cd ./submission \
      && tar czf ./submisson.tar.gz ./*.tif \
      && cd ..

    echo "... finished"
    du -h submission/submisson.tar.gz

    echo "================ END ================"
} |& tee "/codeexecution/submission/log.txt"

cp /codeexecution/submission/log.txt /tmp/log
exit $exit_code