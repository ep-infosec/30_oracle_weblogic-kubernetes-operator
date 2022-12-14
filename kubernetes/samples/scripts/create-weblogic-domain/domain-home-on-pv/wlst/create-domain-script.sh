#!/bin/bash
# Copyright (c) 2018, 2021, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Include common utility functions
source ${CREATE_DOMAIN_SCRIPT_DIR}/utility.sh

export DOMAIN_HOME=${DOMAIN_HOME_DIR}

# Create the domain
wlst.sh -skipWLSModuleScanning ${CREATE_DOMAIN_SCRIPT_DIR}/create-domain.py

chmod -R g+w $DOMAIN_HOME || return 1

