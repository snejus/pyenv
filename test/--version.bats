#!/usr/bin/env bats

load test_helper

export GIT_DIR="${PYENV_TEST_DIR}/.git"

setup() {
  mkdir -p "$HOME" "$PYENV_ROOT"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  git config --global init.defaultBranch "main"
  cd "$PYENV_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  unset PYENV_ROOT
  assert [ ! -e "$PYENV_ROOT" ]

  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}

@test "default version when PYENV_ROOT is not a git repo" {
  assert [ ! -e "$PYENV_ROOT/.git" ]

  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}

@test "respects PYENV_ROOT absence and does not resolve a random repo" {
  git init
  git_commit
  git tag v1.0
  unset PYENV_ROOT

  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}

@test "reads version from the PYENV_ROOT repo" {
  export GIT_DIR=$PYENV_ROOT/.git
  git init
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  run pyenv---version
  assert_success "pyenv 0.4.1-2-g$(git rev-parse --short HEAD)"
}

@test "prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/pyenv/pyenv.git
  git_commit

  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}
