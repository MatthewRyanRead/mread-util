gripeb() {
    echo grep --color=always -rIE --exclude-dir=\.git "$@" . ;
    grep --color=always -rIE --exclude-dir=\.git "$@" . | less -r ;
}

alias grip='grep -i'
alias gripe='gripeb 2>/dev/null'
alias igripe='gripe -i'
alias jgripe='gripe --include \*.java'
alias jigripe='jgripe -i'
alias jsgripe='gripe --include \*.js --include \*.mustache --exclude *.map.js --exclude moment.js --exclude-dir node_modules'
alias jsigripe='jsgripe -i'
alias sqlgripe='gripe --include \*.sql'
alias sqligripe='sqlgripe -i'

addcert() {
    certutil -d sql:"$HOME"/.pki/nssdb -A -t P -n "$1" -i "$1"
}

rebase() {
    git fetch && git rebase "$@" origin/master
}

crunch() {
    git add -u &&
    git commit --amend --no-edit &&
    git fetch &&
    git rebase origin/master &&
    git push -f
}

alias g='git'

amend() {
    if [ "$1" == "" ]; then
        git commit --amend --no-edit
    else
        git commit --amend -m $1
    fi
}

fpush() {
    git push -f
}

adda() {
    git add -A
}

addu() {
    git add -u
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
    if [ "$2" == "" ]; then
        echo "Usage: github_create_repo [username] [reponame] <oneTimeCode>" && return 1
    fi
    if [ "$3" != "" ]; then
        ARG1=-H "X-GitHub-OTP: $3"
    fi
    ARG2=-d "{\"name\":\"$2\"}"

    curl -u "$1" $ARG1 $ARG2 https://api.github.com/user/repos 
}
ghcr() {
    github_create_repo "$GITHUB_USERNAME" $(basename "$PWD") "$@"
}

cherry() {
    git cherry-pick "$@"
}

commit() {
    git add -u && git commit -m "$@"
}

commend() {
    git add -u && git commit --amend -m "$@"
}

h() {
    if [ "$1" == "" ]; then
        history | grep --color=always -P '^[\s0-9]+' | tail -r | less -r
    else
        history | grep --color=always -E "$@" | tail -r | less -r
    fi
}

alias dedupe='uniq'
unique() {
    sort | uniq
}

alias fulldiff='git diff-index --binary'

fame() {
    find . -name $1
}

vind() {
    vi $(find . -name $1)
}

