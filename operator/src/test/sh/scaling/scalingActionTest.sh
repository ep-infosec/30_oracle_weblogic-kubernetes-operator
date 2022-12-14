#!/usr/bin/env bash
# Copyright (c) 2021,2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# To run this test manually:
# export SHUNIT2_PATH=<path of shunit2 binary>
# export SCRIPTPATH=<path of directory containing scalingAction.sh>
# sh scaling/scalingActionTest.sh
#

API_VERSION="v9"
TEST_OPERATOR_ROOT=/tmp/test/weblogic-operator
setUp() {
  DONT_USE_JQ="true"
}

skip_if_jq_not_installed() {
  DONT_USE_JQ=
  if [ -x "$(command -v jq)" ]; then
    return
  fi
  startSkipping
}

oneTimeTearDown() {

  # Cleanup cmds-$$.py generated by scalingAction.sh
  rm -f cmds-$$.py

  # Cleanup scalingAction.log
  rm -f scalingAction.log
}

##### get_domain_api_version tests #####

test_get_domain_api_version() {
  CURL_FILE="apis1.json"

  result=$(get_domain_api_version)

  assertEquals "Did not return expected api version" $API_VERSION "${result}"
}

test_get_domain_api_version_jq() {
  skip_if_jq_not_installed

  CURL_FILE="apis1.json"

  result=$(get_domain_api_version)

  assertEquals "Did not return expected api version" $API_VERSION "${result}"
}

test_get_domain_api_version_without_weblogic_group() {
  CURL_FILE="apis2.json"

  result=$(get_domain_api_version)

  assertEquals "should have empty api version" '' "${result}"  
}

test_get_domain_api_version_without_weblogic_group_jq() {
  skip_if_jq_not_installed

  CURL_FILE="apis2.json"

  result=$(get_domain_api_version)

  assertEquals "should have empty api version" '' "${result}"  
}

##### get_operator_internal_rest_port tests #####

test_get_operator_internal_rest_port() {
  CURL_FILE="operator_status1.json"

  result=$(get_operator_internal_rest_port)

  assertEquals "Did not return expected rest port" '8082' "${result}"
}

test_get_operator_internal_rest_port_jq() {
  skip_if_jq_not_installed

  CURL_FILE="operator_status1.json"

  result=$(get_operator_internal_rest_port)

  assertEquals "Did not return expected rest port" '8082' "${result}"
}

test_get_operator_internal_rest_port_operator_notfound() {
  CURL_FILE="operator_404.json"

  result=$(get_operator_internal_rest_port)

  assertEquals "Did not return expected rest port" '' "${result}"
}

test_get_operator_internal_rest_port_operator_notfound_jq() {
  skip_if_jq_not_installed

  CURL_FILE="operator_404.json"

  result=$(get_operator_internal_rest_port)

  assertEquals "Did not return expected rest port" '' "${result}"
}

##### get_cluster_resource_names_from_domain tests #####

test_get_cluster_resource_names_from_domain() {

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_cluster_resource_names_from_domain "${domain_json}")

  if [[ "${result}" != "domain1-cluster-1"*"domain1-cluster-2" ]]; then
    fail "get_cluster_resource_names_from_domain returned unexpected value: <${result}>"
  fi
}

test_get_cluster_resource_names_from_domain_jq() {
  skip_if_jq_not_installed

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_cluster_resource_names_from_domain "${domain_json}")

  if [[ "${result}" != "domain1-cluster-1"*"domain1-cluster-2" ]]; then
    fail "get_cluster_resource_names_from_domain returned unexpected value: <${result}>"
  fi
}

test_get_cluster_resource_names_from_domain_no_clusters() {

  DOMAIN_FILE="${testdir}/domain_0cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_cluster_resource_names_from_domain "${domain_json}")

  assertEquals "" "${result}"
}

test_get_cluster_resource_names_from_domain_no_clusters_jq() {
  skip_if_jq_not_installed

  DOMAIN_FILE="${testdir}/domain_0cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_cluster_resource_names_from_domain "${domain_json}")

  assertEquals "" "${result}"
}

##### get_cluster_name_from_cluster tests #####

test_get_cluster_name_from_cluster() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_cluster_name_from_cluster "${cluster_json}")

  assertEquals 'cluster-1' "${result}"
}

test_get_cluster_name_from_cluster_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_cluster_name_from_cluster "${cluster_json}")

  assertEquals 'cluster-1' "${result}"
}

##### get_replicas_from_cluster tests #####

test_get_replicas_from_cluster() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replicas_from_cluster "${cluster_json}")

  assertEquals '3' "${result}"
}

test_get_replicas_from_cluster_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  wls_cluster_name='cluster-1'

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replicas_from_cluster "${cluster_json}")

  assertEquals '3' "${result}"
}

test_get_replicas_from_cluster_no_replicas() {

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replicas_from_cluster "${cluster_json}")

  assertEquals '-1' "${result}"
}

test_get_replicas_from_cluster_no_replicas_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  wls_cluster_name='cluster-1'

  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replicas_from_cluster "${cluster_json}")

  assertEquals '-1' "${result}"
}

##### get_min_replicas_from_cluster tests #####

test_get_min_replicas_from_cluster() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_min_replicas_from_cluster "${cluster_json}" result

  assertEquals '1' "${result}"
}

test_get_min_replicas_from_cluster_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_min_replicas_from_cluster "${cluster_json}" result

  assertEquals '1' "${result}"
}

test_get_min_replicas_from_cluster_default() {

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_min_replicas_from_cluster "${cluster_json}" result

  assertEquals '0' "${result}"
}

test_get_min_replicas_from_cluster_default_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_min_replicas_from_cluster "${cluster_json}" result

  assertEquals '0' "${result}"
}

##### get_max_replicas_from_cluster tests #####

test_get_max_replicas_from_cluster() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_max_replicas_from_cluster "${cluster_json}" result

  assertEquals '8' "${result}"
}

test_get_max_replicas_from_cluster_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_max_replicas_from_cluster "${cluster_json}" result

  assertEquals '8' "${result}"
}

test_get_max_replicas_from_cluster_default() {

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_max_replicas_from_cluster "${cluster_json}" result

  assertEquals '' "${result}"
}

test_get_max_replicas_from_cluster_default_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr0.json"

  cluster_json=`command cat ${CLUSTER_FILE}`

  get_max_replicas_from_cluster "${cluster_json}" result

  assertEquals '' "${result}"
}

##### get_num_ms_domain_scope tests #####

test_get_num_ms_domain_scope() {
  
  DOMAIN_FILE="${testdir}/cluster1.json"
  
  wls_cluster_name='cluster-1'
  
  domain_json=`command cat ${DOMAIN_FILE}`
  
  result=$(get_num_ms_domain_scope "${domain_json}")
  
  assertEquals '2' "${result}"
}

test_get_num_ms_domain_scope_jq() {
  skip_if_jq_not_installed

  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_num_ms_domain_scope "${domain_json}")

  assertEquals '2' "${result}"
}

test_get_num_ms_domain_scope_no_replicas() {

  DOMAIN_FILE="${testdir}/cluster_noreplicas.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_num_ms_domain_scope "${domain_json}")

  assertEquals '0' "${result}"
}

test_get_num_ms_domain_scope_no_replicas_jq() {
  skip_if_jq_not_installed

  DOMAIN_FILE="${testdir}/cluster_noreplicas.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(get_num_ms_domain_scope "${domain_json}")

  assertEquals '0' "${result}"
}

##### get_replica_count_from_resources tests #####

test_get_replica_count_from_resources_cluster() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")

  assertEquals '3' "${result}"
}

test_get_replica_count_from_resources_cluster_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")

  assertEquals '3' "${result}"
}

test_get_replica_count_from_resources_domain() {

  CLUSTER_FILE="${testdir}/cluster_cr0.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")

  assertEquals '2' "${result}"
}

test_get_replica_count_from_resources_domain_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr0.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  result=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")

  assertEquals '2' "${result}"
}

##### find_target_replicas tests (get_replica_count_from_resources and calculate_new_replica_count) #####

test_find_target_replicas_scaleUp() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '4' "${result}"
}

test_find_target_replicas_scaleUp_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '4' "${result}"
}

test_find_target_replicas_scaleDown() {

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleDown" "${current_replica_count}" 1)
  assertEquals '2' "${result}"
}

test_find_target_replicas_scaleDown_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr1.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleDown" "${current_replica_count}" 1)
  assertEquals '2' "${result}"
}

test_find_target_replicas_no_replicas_in_cluster_resource() {

  CLUSTER_FILE="${testdir}/cluster_cr0.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '3' "${result}"
}

test_find_target_replicas_no_replicas_in_cluster_resource_jq() {
  skip_if_jq_not_installed

  CLUSTER_FILE="${testdir}/cluster_cr0.json"
  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=`command cat ${CLUSTER_FILE}`

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '3' "${result}"
}

test_find_target_replicas_no_cluster_resource() {

  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=""

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '3' "${result}"
}

test_find_target_replicas_no_cluster_resource_jq() {
  skip_if_jq_not_installed

  DOMAIN_FILE="${testdir}/cluster1.json"

  wls_cluster_name='cluster-1'

  domain_json=`command cat ${DOMAIN_FILE}`
  cluster_json=''

  current_replica_count=$(get_replica_count_from_resources "${cluster_json}" "${domain_json}")
  result=$(calculate_new_replica_count "scaleUp" "${current_replica_count}" 1)
  assertEquals '3' "${result}"
}

##### get_cluster_resource_if_cluster_name_matches tests #####

test_get_cluster_resource_if_cluster_name_matches() {
  CURL_FILE="cluster_cr1.json"

  result=$(get_cluster_resource_if_cluster_name_matches "domain1-cluster-1" "cluster-1")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertEquals "Expected cluster resource" "${expectedResult}" "${result}"
}

test_get_cluster_resource_if_cluster_name_matches_jq() {
  skip_if_jq_not_installed

  CURL_FILE="cluster_cr1.json"

  result=$(get_cluster_resource_if_cluster_name_matches "domain1-cluster-1" "cluster-1")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertEquals "Expected cluster resource" "${expectedResult}" "${result}"
}

test_get_cluster_resource_if_cluster_name_matches_not_matching() {
  CURL_FILE="cluster_cr1.json"

  result=$(get_cluster_resource_if_cluster_name_matches "domain1-cluster-1" "cluster-2")

  assertNull "Expected null when cluster resource does not contain WebLogic cluster name" "${result}"
}

test_get_cluster_resource_if_cluster_name_matches_not_matching_jq() {
  skip_if_jq_not_installed

  CURL_FILE="cluster_cr1.json"

  result=$(get_cluster_resource_if_cluster_name_matches "domain1-cluster-1" "cluster-2")

  assertNull "Expected null when cluster resource does not contain WebLogic cluster name" "${result}"
}

##### find_cluster_resource_with_cluster_name tests #####

test_find_cluster_resource_with_cluster_name() {
  CURL_FILE="cluster_cr1.json"

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(find_cluster_resource_with_cluster_name "${domain_json}" "cluster-1")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertEquals "Expected cluster resource returned" "${expectedResult}" "${result}"
}

test_find_cluster_resource_with_cluster_name_jq() {
  skip_if_jq_not_installed

  CURL_FILE="cluster_cr1.json"

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(find_cluster_resource_with_cluster_name "${domain_json}" "cluster-1")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertEquals "Expected cluster resource returned" "${expectedResult}" "${result}"
}

test_find_cluster_resource_with_cluster_name_not_found() {
  CURL_FILE="cluster_cr1.json"

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(find_cluster_resource_with_cluster_name "${domain_json}" "non-existing-cluster")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertNull "Expected null when cluster resource does not contain WebLogic cluster name" "${result}"
}

test_find_cluster_resource_with_cluster_name_not_found_jq() {
  skip_if_jq_not_installed

  CURL_FILE="cluster_cr1.json"

  DOMAIN_FILE="${testdir}/domain_2cr.json"

  domain_json=`command cat ${DOMAIN_FILE}`

  result=$(find_cluster_resource_with_cluster_name "${domain_json}" "non-existing-cluster")
  expectedResult=$(cat ${testdir}/${CURL_FILE})

  assertNull "Expected null when cluster resource does not contain WebLogic cluster name" "${result}"
}

######################### Mocks for the tests ###############

cat() {
  case "$*" in
    "/var/run/secrets/kubernetes.io/serviceaccount/token")
      echo "sometoken"
      ;;
  *)
    command cat $*
  esac
}

curl() {
  cat ${testdir}/${CURL_FILE}
}

testdir="${0%/*}"

# shellcheck source=scripts/scaling/scalingAction.sh
. ${SCRIPTPATH}/scalingAction.sh --no_op

echo "Run tests"

# shellcheck source=target/classes/shunit/shunit2
. ${SHUNIT2_PATH}
