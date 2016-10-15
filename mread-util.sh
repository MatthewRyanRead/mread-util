gripeb() {
    grep --color=always -rIE --exclude-dir=\.git "$@" . | less -r ;
}

alias gripe='gripeb 2>/dev/null'
alias igripe='gripe -i'

jgripe() {
    local _IGNORECASE=""
    if [ "$1" == "-i" ]
    then
        _IGNORECASE="-i" ;
        shift
    fi

    if [ "$1" != "-j" ]
    then
        gripe "$_IGNORECASE" --include \*.java "$@"
    else
        _FNAME="$2" ;
        shift 2 ;
        gripe "$_IGNORECASE" --include "$_FNAME".java "$@"
    fi
}

alias jigripe='jgripe -i'

testgripe() {
    grep -rIE "(Failure|Error)s: [^0]" "$@" | while read -r line ; do
        cat $(echo "$line" | awk -F':' '{print $1}') | less
    done
}

addcert() {
    certutil -d sql:"$HOME"/.pki/nssdb -A -t P -n "$1" -i "$1"
}

rebase() {
    local i='-i'
    if [ "$1" == "+i" ]; then i=''; fi
    git fetch && git rebase "${@:2}" $i origin/master
}

gitcrunch() {
    git add -u &&
    git commit --amend --no-edit &&
    git fetch &&
    git rebase origin/master &&
    git push -f
}

alias changedfiles='git diff --name-only HEAD~1'

killname() {
    sudo ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | while read line; do sudo kill -9 "$line"; done
}

bashedit() {
    vi ~/.bash_profile
    source ~/.bash_profile
}

utiledit() {
    vi ~/Developer/mread-util/mread-util.sh
    source ~/Developer/mread-util/mread-util.sh
}

alias cls='clear'

github_create_repo() {
    local ARGS=""
    if [ "$2" == "" ]; then echo "Usage: github_create_repo [username] [reponame] <oneTimeCode>"; fi
    if [ "$3" != "" ]; then ARGS="-H "\'"X-GitHub-OTP: $3"\'; fi

    echo curl -u "$1" https://api.github.com/user/repos -d '{"name":"'"$2"'"}' "$ARGS"
}
ghcr() {
    github_create_repo "$GITHUB_USERNAME" "$@"
}

