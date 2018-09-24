# This script should be sourced from your bash_profile!
# Required shell variables (you should set these here or in your bash profile):
# - GITHUB_USERNAME
# Edit this variable if you cloned this somewhere other than ~/Developer:

export MREAD_UTIL_BASE_PATH="$HOME/Developer/mread-util"

###

utiledit() {
    $EDITOR $MREAD_UTIL_BASE_PATH/mread-util.sh
    source $MREAD_UTIL_BASE_PATH/mread-util.sh
}

bashedit() {
    $EDITOR ~/.bash_profile
    source ~/.bash_profile
}

### GREP ###

gripeb() {
    echo grep --color=always -rIE --exclude-dir=\.git "$@" . >&2
    grep --color=always -rIE --exclude-dir=\.git "$@" . | less -r
}

alias grip='grep -i'
alias gripe='gripeb 2>/dev/null'
alias igripe='gripe -i'
alias jgripe='gripe --include \*.java'
alias jigripe='jgripe -i'
alias jsgripe='gripe --include \*.js --include \*.mustache --exclude moment.js --exclude bundle.js --exclude \*.\*.js --exclude \*-min.js --exclude main.js --exclude templates.js --exclude-dir node_modules --exclude-dir testingData --exclude-dir packages --exclude-dir __tests__'
alias jsigripe='jsgripe -i'
alias sqlgripe='gripe --include \*.sql --exclude-dir target'
alias sqligripe='sqlgripe -i'

### GIT ###

alias g='git'

alias clone='g clone'

alias status='g status'

alias fetch='g fetch'

alias adda='g add -A'
alias addu='g add -u'

alias push='g push'
alias pushf='g push --force-with-lease'
alias pushu='g push -u'

alias co='g checkout'
alias blist='g branch -l --list'

alias hdiff='g diff HEAD'
alias fulldiff='g diff-index --binary'

alias changedfiles='g diff --name-only HEAD~1'

alias master='co master && fetch && g pull'
alias revert='co HEAD~1'

alias cherry='g cherry-pick'

alias commit='g commit -m'
alias admit='addu && commit'

alias resetmaster='fetch && g reset --hard origin/master'
alias latest='fetch && g reset --hard origin/$(g rev-parse --abbrev-ref HEAD)'

newb() {
    co -b "$@" && pushu
}

rebase() {
    fetch && g rebase "$@" origin/master
}

amend() {
    if [ "$1" == "" ]; then
        g commit --amend --no-edit
    else
        commit "$@" --amend
    fi
}

alias commend='addu && amend'

alias crunch='addu && amend && fetch && rebase && pushf'

hascommit() {
    g log $1 | grep $2
}

# remove all local branches except for the current one + master
gpurge() {
    blist | grep -v '^\*' | grep -oE '[^ ]+' | grep -vE '^master$' | while read line; do g branch -D $line; done
}

pruneall() {
    g reflog expire --expire=now --all
    g gc --aggressive --prune=now
}

delcommit() {
    local BRANCH_POINT=$(g reflog show $(g rev-parse --abbrev-ref HEAD) | tail -n 1 | awk '{ print $1 }')
    local HEAD=$(g rev-parse HEAD)

    g reset --hard $BRANCH_POINT

    g rev-list $BRANCH_POINT...$HEAD | tail -r | while read line; do
        if [ "$line" != "$1" ]; then
            cherry $line
        fi
    done
}

### GITHUB ###

github_create_repo() {
    ARG1=''
    if [ "$2" == "" ]; then
        echo "Usage: github_create_repo [username] [reponame] <oneTimeCode>"
        return 1
    fi
    if [ "$3" != "" ]; then
        ARG1="X-GitHub-OTP: $3"
    fi
    ARG2="{\"name\":\"$2\"}"

    curl -u $1 -H "$ARG1" -d $ARG2 https://api.github.com/user/repos 
}

ghcr() {
    set -e
    REPONAME=$(basename "$PWD")
    github_create_repo $GITHUB_USERNAME $REPONAME $@
    touch README.md
    g init
    g add README.md
    commit 'first commit'
    g remote add origin git@github.com:$GITHUB_USERNAME/$REPONAME.git
    g push -u origin master
    set +e
}

### DOS COMPAT ###

alias cls='clear'
alias where='which'
alias tracert='traceroute'

### SHELL/UTIL HELPERS ###

killname() {
    sudo ps aux |
        grep -i "$1" |
        grep -v grep |
        awk '{print $2}' |
        while read line; do
            sudo kill -9 "$line";
        done
}

# a better version of 'history'
h() {
    if [ "$1" == "" ]; then
        history | grep --color=always -P '^[\s0-9]+' | tail -r | less -r
    else
        history | grep --color=always -E "$@" | tail -r | less -r
    fi
}

# 'uniq' doesn't actually make things unique....
alias dedupe='uniq'
alias unique='sort | uniq'

alias fame='find . -name'

alias filecount='ls -l | wc -l'

# so you don't have to CD into the path or re-type it
rename() {
    mv $1 $(dirname $1)/$2
}

# basic xargs that works with aliases
zargs() {
    while read line; do $1 $line; done
}

### EDITING ###

# find and edit in one go
alias vind='fame -exec vim {} \;'

finj() {
    idea $(fame "$@")
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

alias describecert='openssl x509 -text -in'

### RANDOM ###

alias repeatgif='gifsicle -bl'

alias maven='mvn'

pushd() {
    UNAME=$(uname)
    if [ "$UNAME" == "Darwin" ] || [ "$UNAME" == "Linux" ]; then
        command pushd "$@" > /dev/null
    else
        command pushd "$@"
    fi
}

popd() {
    UNAME=$(uname)
    if [ "$UNAME" == "Darwin" ] || [ "$UNAME" == "Linux" ]; then
        command popd "$@" > /dev/null
    else
        command popd "$@"
    fi
}
