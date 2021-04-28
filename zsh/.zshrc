# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/francescozanoli/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"
export EMACS="*term*"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker kubectl)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

#### MY CONFIGURATION ###
DEFAULT_USER='francescozanoli'

# ENV CONFIGURATION #
eval "$(docker-machine env default)"
source '/Users/francescozanoli/Library/Application Support/creds/nexus'
export PRIVATE_GEM_SERVER_CREDENTIALS=eng_read_only:by99Egh7qZi7XXRXrvWx
export UID
export GID

 #ALIAS CONFIGURATION #
alias ohmyzsh="vi ~/.oh-my-zsh
alias zshconfig=“vi ~/.zshrc"
alias lt='ls -lrta'
alias startworking='cd ~/Desktop/Projects'
alias credsprod='creds aws login Production tf-engineers-role'
alias credsdev='creds aws login Development tf-engineers-role'
alias credspre='creds aws login Pre-Prod tf-engineers-role'
alias lsdoc='docker container ls'
alias docexe='docker-compose build | docker-compose up'
alias learning='cd ~/Desktop/Learning'
alias documentation='cd ~/Desktop/Documentation'
alias vim="nvim"
alias vimdiff="nvim -d"
export TERM=xterm-256color
# FUNCTIONS #
sqlinto(){
        export PGPASSWORD=$(ruby ~/Desktop/Scripts/into_sql.rb $1)
       psql -h shared-aurora-postgres.eu-west-1.dev.onfido.xyz -p 5432 -U $1
}

docent(){
	docker exec -it $1 bash
}

newphoenix(){
	mix phx.new $1 --no-ecto
}
# Kubernetes
#
kex() {
  # KUBE_VERSION="13"
  # vared -p $'  \033[1mkubectl version:\033[0m ' KUBE_VERSION
  NAMESPACE=development
  vared -p $'  \033[1mNamespace:\033[0m ' NAMESPACE
  local POD=$(kubectl get pods -n $NAMESPACE --no-headers | fzf-tmux --height 40% --multi | awk -F'[ ]' '{print $1}')
  local CONTAINER=$(kubectl get pods $POD -n development -o jsonpath='{.spec.containers[*].name}' | tr " " "\n" | fzf-tmux --height 40% --multi | awk -F'[ ]' '{print $1}')
  local CONTEXT=$(kubectl config current-context | tr -d '\n')
  if [[ $POD != '' ]]; then
    echo  "\n  \033[1mContext:\033[0m" $CONTEXT
    echo  "  \033[1mNamespace:\033[0m" $NAMESPACE
    echo  "  \033[1mPod:\033[0m" $POD
    echo  "  \033[1mContainer:\033[0m" $CONTAINER
    OPTIONS="-it"
    vared -p $'  \033[1mOptions:\033[0m ' OPTIONS
    if [[ $@ == '' ]]; then
                CMD="bash"
                vared -p $'  \033[1mCommand:\033[0m ' CMD
    else
                CMD="$@"
    fi
    echo ''
    print -s kex "$@"
    print -s kubectl exec $OPTIONS -n $NAMESPACE $POD -c $CONTAINER $CMD
    zsh -c "kubectl exec $OPTIONS -n $NAMESPACE $POD -c $CONTAINER $CMD"
  fi
}
export PATH="$HOME/.rbenv/bin:$PATH"
# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --height 40% --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
}
# cf - fuzzy cd from anywhere
# ex: cf word1 word2 ... (even part of a file name)
# zsh autoload function
cf() {
  local file

  file="$(locate -Ai -0 $@ | grep -z -vE '~$' | fzf --height 40% --read0 -0 -1)"

  if [[ -n $file ]]
  then
     if [[ -d $file ]]
     then
        cd -- $file
     else
        cd -- ${file:h}
     fi
  fi
}
# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
    local pid 
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf --height 40% -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf --height 40% -m | awk '{print $2}')
    fi  

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi  
}
# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux --height 40% -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
# Install (one or multiple) selected application(s)
# using "brew search" as source input
# mnemonic [B]rew [I]nstall [P]lugin
bip() {
  local inst=$(brew search | fzf --height 40% -m)

  if [[ $inst ]]; then
    for prog in $(echo $inst);
    do; brew install $prog; done;
  fi
}

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=dark
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. /usr/local/opt/asdf/asdf.sh
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.0/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

alias vpn="creds vpn login"
alias credsoncall="creds aws login Production tf-oncall-role"
