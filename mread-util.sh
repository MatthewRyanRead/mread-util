# This script should be sourced from your bash_profile!
# Required shell variables (you should set these here or in your bash profile):
# - GITHUB_USERNAME
# Edit this variable if you cloned this somewhere other than ~/Developer:

export MREAD_UTIL_BASE_PATH="$HOME/Developer/mread-util"

###

utiledit() {
    $EDITOR "$MREAD_UTIL_BASE_PATH/mread-util.sh"
    source "$MREAD_UTIL_BASE_PATH/mread-util.sh"
}

bashedit() {
    $EDITOR "$HOME/.bash_profile"
    source "$HOME/.bash_profile"
}

### GREP ###

gripeb() {
    echo grep --color=auto -rIE --exclude-dir=\.git "$@" . >&2
    grep --color=auto -rIE --exclude-dir=\.git "$@" . | less -r
}

grip() {
    grep -i "$@"
}
gripe() {
    gripeb 2>/dev/null "$@"
}
igripe() {
    gripe -i "$@"
}
jgripe() {
    gripe --include \*.java "$@"
}
jigripe() {
    jgripe -i "$@"
}
jsgripe() {
    gripe --include \*.js --include \*.mustache --exclude moment.js --exclude bundle.js --exclude \*.\*.js --exclude \*-min.js --exclude main.js --exclude templates.js --exclude-dir node_modules --exclude-dir testingData --exclude-dir packages --exclude-dir __tests__ "$@"
}
jsigripe() {
    jsgripe -i "$@"
}
sqlgripe() {
    gripe --include \*.sql --exclude-dir target "$@"
}
sqligripe() {
    sqlgripe -i "$@"
}

### GIT ###

g() {
    git "$@"
}

clone() {
    g clone "$@"
}

status() {
    g status "$@"
}

fetch() {
    g fetch "$@"
}

adda() {
    g add -A "$@"
}
addu() {
    g add -u "$@"
}

push() {
    g push "$@"
}
pushf() {
    g push --force-with-lease "$@"
}
pushu() {
    g push -u "$@"
}

blist() {
    g branch -l --list "$@"
}

hdiff() {
    g diff HEAD "$@"
}
fulldiff() {
    g diff-index --binary "$@"
}

changedfiles() {
    g diff --name-only HEAD~1 "$@"
}

co() {
    # only fetch if checking out a branch/ref (`co my-ref`), not a file (`co my-ref my-file`)
    if [[ "$2" == "" ]]; then
        fetch
    fi

    g checkout "$@"
}

master() {
    co master && fetch && g reset --hard origin/master "$@"
}
main() {
    co main && fetch && g reset --hard origin/main "$@"
}
revert() {
    co HEAD~1 "$@"
}

cherry() {
    g cherry-pick "$@"
}

commit() {
    g commit -m "$@"
}
admit() {
    addu && commit "$@"
}

resetmaster() {
    fetch && g reset --hard origin/master "$@"
}

latest() {
    fetch && g reset --hard origin/$(g rev-parse --abbrev-ref HEAD)
}

newb() {
    co -b "$@" && pushu
}

rebase() {
    fetch && g rebase "$@" origin/HEAD
}

amend() {
    if [ "$1" == "" ]; then
        g commit --amend --no-edit
    else
        commit "$@" --amend
    fi
}

commend() {
    addu && amend "$@"
}

crunch() {
    addu && amend && fetch && rebase && pushf "$@"
}

hascommit() {
    g log "$1" | grep "$2"
}

# remove all local branches except for the current one + master/main
gpurge() {
    blist | grep -v '^\*' | grep -oE '[^ ]+' | grep -vE '^(master|main)$' | while read line; do g branch -D "$line"; done
    g prune
}

pruneall() {
    g reflog expire --expire=now --all
    g gc --aggressive --prune=now
    g remote prune origin
}

branchpoint() {
    g log -g --pretty=oneline "$(g rev-parse --abbrev-ref HEAD)" | tail -n 1 | awk '{ print $1; }'
}

delcommit() {
    local BRANCH_POINT
    BRANCH_POINT="$(branchpoint)"
    local HEAD
    HEAD="$(g rev-parse HEAD)"

    g reset --hard "$BRANCH_POINT"

    g rev-list "$BRANCH_POINT...$HEAD" | tac | while read line; do
        if [ "$line" != "$1" ]; then
            cherry "$line"
        fi
    done
}

branchdiff() {
    g diff "$(branchpoint)...HEAD" "$@"
}

rbcont() {
    addu && g rebase --continue "$@"
}

remotebranch() {
    git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2> /dev/null | grep -oE '[^/]+$'
}

localbranch() {
    g branch 2> /dev/null | grep -E '^\*' | awk '{ print $2; }'
}

timelog() {
    g reflog --format="%C(auto)%h %<|(17)%gd %C(blue)%ci%C(reset) %s" "$@"
}

### GITHUB ###

github_create_repo() {
    local ARG1
    if [ "$2" == "" ]; then
        echo "Usage: github_create_repo [username] [reponame] <oneTimeCode>"
        return 1
    fi
    if [ "$3" != "" ]; then
        ARG1="X-GitHub-OTP: $3"
    fi
    local ARG2
    ARG2="{\"name\":\"$2\"}"

    local http_code
    http_code=$(curl -u "$1" -H "$ARG1" -d "$ARG2" https://api.github.com/user/repos -s -o /dev/null -w "%{http_code}")
    if [ "$http_code" -ge 300 ] || [ "$http_code" -lt 200 ]; then
        echo "Error code: $http_code"
        return "$http_code"
    fi
    return 0
}

ghcr() {
    local reponame
    reponame=$(basename "$PWD")
    github_create_repo "$GITHUB_USERNAME" "$reponame" "$@"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return $exit_code
    fi
    echo "# $reponame" > README.md
    g init
    g add README.md
    commit 'init repo with README'
    g remote add origin "git@github.com:$GITHUB_USERNAME/$reponame.git"
    g push -u origin main
}

rewrite-all-committers() {
    local committer_name
    committer_name="$(git config user.name)"
    local committer_mail
    committer_mail="$(git config user.email)"

    git filter-branch --env-filter "
        export GIT_COMMITTER_NAME=\"$committer_name\"
        export GIT_COMMITTER_EMAIL=\"$committer_mail\"
        export GIT_AUTHOR_NAME=\"$committer_name\"
        export GIT_AUTHOR_EMAIL=\"$committer_mail\"
    " --tag-name-filter cat -- --branches --tags
}

cloneme() {
    clone "git@github.com:$GITHUB_USERNAME/$1"
}

### DOS COMPAT ###

cls() {
    clear "$@"
}
where() {
    which "$@"
}
tracert() {
    traceroute "$@"
}

### SHELL/UTIL HELPERS ###

if [ -z "$(which tac)" ]; then
    tac() {
        tail -r "$@"
    }
fi

# a better version of 'history'
h() {
    if [ "$1" == "" ]; then
        history | tac | less -r
    else
        local args="$*"
        history | grep --color=auto -E "$args" | tac | less -r
    fi
}

# 'uniq' doesn't actually make things unique....
dedupe() {
    uniq "$@"
}
unique() {
    sort | uniq "$@"
}

fame() {
    find . -name "$@"
}

filecount() {
    ls -l | wc -l "$@"
}

# so you don't have to CD into the path or re-type it
rename() {
    mv "$1" "$(dirname $1)/$2"
}

### EDITING ###

# find and edit in one go
vind() {
    fame -exec vim {} \; "$@"
}

finj() {
    idea "$(fame "$@")"
}

### CERTS ###

# import a cert
addcert() {
    if [ "$(uname)" == "Darwin" ]; then
        sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "$@"
    else
        certutil -d sql:"$HOME"/.pki/nssdb -A -t P -n "$1" -i "$1"
    fi
}

dlcert() {
    openssl s_client -showcerts -connect "$1:$2" < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$1.pem"
}

describecert() {
    openssl x509 -text -in "$@"
}

### MAVEN ###

maven() {
    mvn "$@"
}
mvnin() {
    mvn install -DskipTests -DskipITs "$@"
}
mvnci() {
    mvn clean install -DskipTests -DskipITs "$@"
}

cleansnaps() {
    find ~/.m2/repository -depth -type d -regex '.*-SNAPSHOT$' -exec rm -rf {} \;
}

### RANDOM ###

repeatgif() {
    gifsicle -bl "$@"
}

pushd() {
    local UNAME
    UNAME="$(uname)"
    if [ "$UNAME" == "Darwin" ] || [ "$UNAME" == "Linux" ]; then
        command pushd "$@" > /dev/null || return
    else
        command pushd "$@" || return
    fi
}

popd() {
    local UNAME
    UNAME="$(uname)"
    if [ "$UNAME" == "Darwin" ] || [ "$UNAME" == "Linux" ]; then
        command popd "$@" > /dev/null || return
    else
        command popd "$@" || return
    fi
}

repeat() {
    for suffix in "${@:2}"; do
        eval "$1""$suffix"
    done
}

upgrate() {
    sudo apt update && sleep 1 && sudo apt upgrade "$@"
}
inst() {
    sudo apt install "$@"
}

restartnow() {
    local UNAME
    UNAME="$(uname)"
    if [ "$UNAME" == "Darwin" ] || [ "$UNAME" == "Linux" ]; then
        sudo shutdown -r now
    else
        shutdown /r /t 0
    fi
}

mcat() {
    cat "$@" | more
}

lcat() {
    cat "$@" | less
}

detail() {
    local FPATH
    FPATH=$(which "$1" | tr -d '\r' | tr -d '\n')
    if [ -z "$FPATH" ]; then
        ls -al "$1" && file "$1"
    else
        ls -al "$FPATH" && file "$FPATH"
    fi
}

prettify() {
    python -m json.tool "$@"
}
