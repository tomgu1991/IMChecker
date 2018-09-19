#!/usr/bin/env bash
#
# Copyright (c) 2017
# ------------------
# Institute on Software System and Engineering
# School of Software, Tsinghua University
#
# All Rights Reserved.
#
# NOTICE:
# All information contained herein is, and remains the property of Tsinghua University.
#
# The intellectual and technical concepts contained herein are proprietary to
# Tsinghua University and may be covered by China and Foreign Patents, patents in process,
# and are protected by copyright law.
#
# Dissemination of this information or reproduction of this material is strictly forbidden
# unless prior written permission is obtained from Tsinghua University.
#
# # # # # # # # # #
#
# Tsmart entry script.
# Usage:
#   tsmart.sh --config path/to/config input
# path/to/config is relative to this file.
# Example: tsmart.sh --config config/phase/integration/with-pointer-range/aprange.top test.c
#
# # # # # # # # # #
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
export PATH=${DIR}:${DIR}/clang:$PATH

${DIR}/bin/engine --root ${DIR} $@
