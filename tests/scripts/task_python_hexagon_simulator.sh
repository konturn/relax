#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e
set -u

source tests/scripts/setup-pytest-env.sh

make cython3

export TVM_TRACKER_PORT=9190
export TVM_TRACKER_HOST=0.0.0.0
env PYTHONPATH=python python3 -m tvm.exec.rpc_tracker --host "${TVM_TRACKER_HOST}" --port "${TVM_TRACKER_PORT}" &
TRACKER_PID=$!
sleep 5   # Wait for tracker to bind

# Temporary workaround for symbol visibility
export HEXAGON_SHARED_LINK_FLAGS="-Lbuild/hexagon_api_output -lhexagon_rpc_sim"

# HEXAGON_TOOLCHAIN is already set
export HEXAGON_SDK_ROOT=${HEXAGON_SDK_PATH}
export ANDROID_SERIAL_NUMBER=simulator
run_pytest ctypes python-contrib-hexagon-simulator tests/python/contrib/test_hexagon/test_launcher.py

kill ${TRACKER_PID}
