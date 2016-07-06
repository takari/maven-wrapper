#!/usr/bin/env bats
set -o pipefail
IFS=$'\t\n'

setup() {
  load "$BATS_TEST_DIRNAME/../../../mvnw"

  run mkdir -p $BATS_TMPDIR/basedir/.mvn
}

@teardown() {
  run rm -rf $BATS_TMPDIR/basedir
}

@test "Path is valid" {
  testpath="$BATS_TMPDIR/basedir/subdir"
  expected="$BATS_TMPDIR/basedir"

  run mkdir -p $testpath
  run pushd $testpath

  run find_maven_basedir $testpath

  [ $status -eq 0 ]
  [ "$output" == "$expected" ]

  run popd
}

@test "Path with spaces in child folders is valid" {
  testpath="$BATS_TMPDIR/basedir/subdir with spaces/foo"
  expected="$BATS_TMPDIR/basedir"

  run mkdir -p $testpath
  run pushd $testpath

  run find_maven_basedir $testpath

  [ $status -eq 0 ]
  [ "$output" == "$expected" ]

  run popd
}

@test "Path with spaces in parent folders is valid" {
  testpath="$BATS_TMPDIR/basedir/cloud-lobster-2 test/cloud-lobster"

  run mkdir -p "$testpath/.mvn"
  run pushd $testpath

  run find_maven_basedir $testpath

  [ $status -eq 0 ]
  [ "$output" == "$testpath" ]

  run popd
}

@test "Empty path is invalid" {
  run find_maven_basedir ""

  [ $status -eq 1 ]
}
