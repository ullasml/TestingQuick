#!/usr/bin/env bash

fail_and_exit_with_message () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || fail_and_exit_with_message "Path to .ipa required as the first and only argument."

./Crashlytics.framework/submit 9a20a18b13ce00e6dba30b046bc1244ccdc8a78b 16a4b51dc6e57f2e21387e47aa3d269fd464806d807df987ae3d01ac2846b5a7 -ipaPath $1
