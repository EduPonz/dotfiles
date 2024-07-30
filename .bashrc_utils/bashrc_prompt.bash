# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]
then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null
    then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
	    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # \[\033[01;33m\]$(__git_ps1 "[%s] ") -> Current git branch/commit if present in bold white
    # \[\033[01;32m\]\u -------------------> username in bold green
    # \[\033[01;34m\]\W -------------------> Current directory (not full path) in bold blue
    # \[\033[01;31m\]\$--------------------> $ in bold red
    # \[\033[00m\]-------------------------> Text in plain white
    PS1='\[\033[01;37m\]$(__git_ps1 "[%s] ")\[\033[01;32m\]\u \[\033[01;34m\]\W \[\033[01;31m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
