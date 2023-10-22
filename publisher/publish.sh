proj_dir=$(pwd)
deployment_dir="$proj_dir/deployment"
repo_url="$1"
repo_name=${repo_url##*/}
repo_name=${repo_name%.git}

init_deployment() {
    # shellcheck disable=SC2164
    cd "$proj_dir"
    local directory="$deployment_dir"
    if [ ! -d "$directory" ]; then
        echo "Create: $directory"

        mkdir -p "$directory"
        cd "$directory"
        git clone "$repo_url"

        cd "$repo_name"
        git config --local --add user.name "satoshi"
        git config --local --add user.email "satoshi@btc.com"
    else
        echo "Exists $directory"
    fi
}


push_registry(){
  # shellcheck disable=SC2164
  cd "$proj_dir"
  # shellcheck disable=SC2155
  local version="$(git rev-parse HEAD)"
  # shellcheck disable=SC2155
  local name="$(git rev-parse --abbrev-ref HEAD)-$version"
  local file_name="$name.zip"
  local output="$deployment_dir/$file_name"
  git archive --format=zip --output="$output" "$version"

  # shellcheck disable=SC2164
  cd "$deployment_dir"
  unzip "$file_name" -d "$repo_name"
  rm "$file_name"

  # shellcheck disable=SC2164
  cd "$repo_name"
  git remote -v
  git pull
  git add .
  git commit -m "$repo_name:$name"
  git push --all
}

init_deployment
push_registry


