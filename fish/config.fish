export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export TERM="xterm-256color"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# custom alias
alias l="ls -lah"
alias ls='ls -FGw'
alias ll="ls -lvh"
alias l.='ls -d .*'
alias ll.='ls -lvhd .*'
alias lll="ll"
alias dt="cd $HOME/Desktop"
alias net="sudo lsof -i -P" # netstat
alias serve="python -mSimpleHTTPServer" # light python server
alias cpwd="pwd | tr -d '\n' | pbcopy" # copy to pwd commmand

# custom common
export MANPAGER='less -I' # case insentive search in man page.
export DEV="$HOME/dev"
export BREW_APPS="/usr/local/opt"
export LANG=en_US.utf-8
export SVN_EDITOR=/usr/bin/vim

# app configuration
export JAVA_HOME=(/usr/libexec/java_home -v 1.8)
export JRE_HOME=(/usr/libexec/java_home -v 1.8)
export CATALINA_HOME="$DEV/tomcat8"
export GROOVY_HOME=/usr/local/opt/groovy/libexec

# rabbitmq
alias rabbitmq-server="/usr/local/sbin/rabbitmq-server"
alias rabbitmq-plugins="/usr/local/sbin/rabbitmq-plugins"
alias rabbitmqctl="/usr/local/sbin/rabbitmqctl"
alias rabbitmqadmin="/usr/local/sbin/rabbitmqadmin"

# servers
