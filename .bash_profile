export EDITOR=vim
export GITHUB_USERNAME=MatthewRyanRead

source "$MREAD_UTIL_BASE_PATH/mread-util.sh"

export HISTSIZE=100000
export HISTFILESIZE=1000000
shopt -s histappend

export JSON='Content-Type: application/json'
export FORM='Content-Type: application/x-www-form-urlencoded'

alias dev='cd ~/Developer'

# fancy terminal with git branch info
# format (not including coloring):
# user@computer path/to/current [local-branch-name : remote-branch-name]
# $

BOLD="$(tput bold)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
RESET="$(tput sgr0)"

set_prompt() {
    local PS1_PREFIX="\[$BOLD$MAGENTA\]\u\[$RESET\]@\[$BLUE\]\h \[$WHITE\]\$(date +'%T') \[$GREEN\]\w"
    local PS1_SUFFIX="\[$CYAN\]\$ \[$RESET\]"

    local BRANCHES
    mapfile -t BRANCHES < <(git rev-parse --abbrev-ref HEAD @{u} 2>/dev/null)
    local LOCAL_BRANCH="${BRANCHES[0]}"
    if [[ -z "$LOCAL_BRANCH" ]]; then
        export PS1="$PS1_PREFIX $PS1_SUFFIX"
        return
    elif [[ "HEAD" == "$LOCAL_BRANCH" ]]; then
        LOCAL_BRANCH="$(git rev-parse --short HEAD)"
        local LAST_CHECKOUT_INFO
        mapfile -t LAST_CHECKOUT_INFO < <(git reflog | grep ': checkout: ' | head -n 1 | awk '{ printf "%s\n%s",$1,$8; }')
        local LAST_CHECKOUT_SHORT_SHA="${LAST_CHECKOUT_INFO[0]}"
        local LAST_CHECKOUT_NAME="${LAST_CHECKOUT_INFO[1]}"
        if [[ "$LOCAL_BRANCH" == "$LAST_CHECKOUT_SHORT_SHA" \
                && "$LAST_CHECKOUT_SHORT_SHA" != "${LAST_CHECKOUT_NAME:0:10}" \
                && "${LAST_CHECKOUT_NAME:0:4}" != "HEAD" ]]; then
            LOCAL_BRANCH="$LAST_CHECKOUT_NAME"
        fi
    fi

    local BRANCH_DETAILS="\[$RED\]$LOCAL_BRANCH"

    local REMOTE_BRANCH="${BRANCHES[1]##*/}"
    if [[ -n "$REMOTE_BRANCH" ]]; then
        BRANCH_DETAILS+=" \[$YELLOW\]: \[$RED\]$REMOTE_BRANCH"
    fi

    export PS1="$PS1_PREFIX \[$BOLD$YELLOW\][$BRANCH_DETAILS\[$BOLD$YELLOW\]]\[$RESET\] $PS1_SUFFIX"
}

export PROMPT_COMMAND=set_prompt
