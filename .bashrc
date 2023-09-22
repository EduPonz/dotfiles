# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
    # \[\033[01;33m\]$(__git_ps1 "[%s] ") -> Current git branch/commit if present in bold yellow
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

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

eprosima_docs ()
{
    (
        function print_usage ()
        {
            echo "------------------------------------------------------------------------";
            echo "Command to generate PDFs using eProsima's Documentation Framework";
            echo "------------------------------------------------------------------------";
            echo "OPTIONAL ARGUMENTS:";
            echo "   -h | --help                    Print help";
            echo "   -d | --source_dir  [directory] The directory containing the .md files";
            echo "                                  [Defaults: ./]";
            echo "   -o | --output_file [file]      The name of the output file [Defaults:";
            echo "                                  ./documentation.pdf]";
            echo "   --debug                        Pass the debug flag to the framework";
            echo "   --pandoc_verbose               Pass the debug flag to Pandoc";
            echo "";
            exit ${1}
        };

        # Working variables
        local docs_dir="$(pwd)";
        local output_dir=${docs_dir};
        local default_output_filename="documentation";
        local default_output_file="${docs_dir}/${default_output_filename}.pdf";
        local output_file="${default_output_file}";
        local debug=""
        local pandoc_verbose=""

        # Validate options
        if ! options=$(getopt \
            --options hd:o: \
            --longoption \
                help,debug,pandoc_verbose,source_dir:,output_file: \
            -- "$@")
        then
            print_usage 1
        fi

        eval set -- "${options}"

        while true
        do
            case "${1}" in
                # Flags
                -h | --help      ) print_usage 0;;
                --debug          ) debug="--debug"; shift;;
                --pandoc_verbose ) pandoc_verbose="--pandoc_verbose"; shift;;
                # Optional arguments
                -d | --source_dir  ) docs_dir=$(realpath ${2}); shift 2;;
                -o | --output_file ) output_file=$(realpath ${2}); shift 2;;
                # End mark
                -- ) shift; break ;;
                # Wrong args
                * ) echo "Unknown option: '${1}'" >&2; print_usage 1;;
            esac
        done

        # Validate input options
        output_dir=$(dirname ${output_file});
        if [[ ! -d ${docs_dir} ]]; then
            echo "Docs directory '${docs_dir}' does not exist.";
            print_usage;
            return 1;
        fi;

        if [[ ! -d ${output_dir} ]]; then
            echo ${output_file};
            echo "Output directory '${output_dir}' does not exist.";
            print_usage;
            return 1;
        fi;

        default_output_file="${docs_dir}/${default_output_filename}.pdf";

        # Generate documentation. This command:
        #   - Shares the documentation directory with the container
        #   - Sets that shared directory as working directory so that pandoc-include works
        docker run \
            --interactive \
            --tty \
            --rm \
            --volume ${docs_dir}:/documentation \
            --workdir /documentation \
            documentation-framework:latest \
                --source_directory /documentation \
                --output_file /documentation/${default_output_filename} \
                ${debug} \
                ${pandoc_verbose};

        # Set specified name to output file
        if [[ ${default_output_file} != ${output_file} ]]; then
            mv -f ${default_output_file} ${output_file};
        fi;

        # Set user as owner (docker would leave the file as root:root)
        sudo chown $(whoami):$(whoami) ${output_file};
        echo "Output documentation in: ${output_file}"
    )
}

eprosima_uncrustify ()
{
    (
        function print_usage ()
        {
            echo "------------------------------------------------------------------------";
            echo "Uncrustify C++ projects using eProsima style";
            echo "------------------------------------------------------------------------";
            echo "";
            echo "This tool uses git to scan for C++ files and runs uncrustify on them.";
            echo "";
            echo "OPTIONAL FLAGS:";
            echo "   -h | --help                    Print help";
            echo "   -m | --modified                Uncrustify modified files";
            echo "   -n | --new                     Uncrustify new files";
            echo ""
            echo "OPTIONAL ARGUMENTS:";
            echo "   -f | --file [FILE]             File to uncrustify";
            echo "";
            exit ${1}
        };

        function uncrustify_ ()
        {
            for file in "$@";
            do
                uncrustify -c ~/dev/cpp-style/uncrustify.cfg -f "${file}" -o "${file}" --no-backup > /dev/null;
            done
        }

         # Working variables
        local uncrustify_modified="";
        local uncrustify_new="";
        local input_file="";

        # Validate options
        if ! options=$(getopt \
            --options hmnf: \
            --longoption help,modified,new,file: \
            -- "$@")
        then
            print_usage 1;
        fi

        eval set -- "${options}"

        while true
        do
            case "${1}" in
                # Flags
                -h | --help      ) print_usage 0;;
                -m | --modified  ) uncrustify_modified="--modified"; shift;;
                -n | --new       ) uncrustify_new="--others"; shift;;
                -f | --file      ) input_file=$(realpath ${2}); shift 2;;
                -- ) shift; break ;;
                # Wrong args
                * ) echo "Unknown option: '${1}'" >&2; print_usage 1;;
            esac
        done

        local OUTPUT=""

        if [ ! -z "${uncrustify_modified}" ] || [ ! -z "${uncrustify_new}" ]
        then
            OUTPUT=$(\
                git ls-files \
                    ${uncrustify_modified} \
                    ${uncrustify_new} \
                    --exclude-standard \
                | grep -v -E thirdparty \
                | grep -e '\.h$' -e '\.hpp$' -e '\.ipp$' -e '\.cpp$' -e '\.cxx$' \
            );
        fi

        OUTPUT="${OUTPUT} ${input_file}"

        for file in ${OUTPUT};
        do
            uncrustify_ "${file}";
        done
    )
}

eprosima_vpn ()
{
    local arg=${1};
    local connection_id=eprosima;
    if [[ ${arg} == 'up' ]]; then
        if nmcli -f GENERAL.STATE connection show ${connection_id} | grep --color=auto -q activated; then
            echo "${connection_id} VPN is already up";
            return 0;
        fi;
        nmcli connection up id ${connection_id};
        local ip_address=$(nmcli -f IP4.ADDRESS connection show ${connection_id} | awk '{print $2}' | awk '{split($0,a,"/"); print a[1]}');
        local interface=$(ifconfig | grep -B1 ${ip_address} | grep -o "^\w*");
        echo "- Interface:   ${interface}";
        echo "- IP address:  ${ip_address}";
        local routes="192.168.1.2 192.168.1.4 192.168.1.6 192.168.1.16 192.168.1.17";
        for route in ${routes};
        do
            echo "Adding route for ${route} to ${connection_id}";
            nmcli connection modify ${connection_id} +ipv4.routes ${route};
        done;
    else
        if [[ ${arg} == 'down' ]]; then
            if ! nmcli -f GENERAL.STATE connection show ${connection_id} | grep --color=auto -q activated; then
                echo "${connection_id} VPN is already down";
                return 0;
            fi;
            nmcli connection down id ${connection_id};
        else
            echo "------------------------------";
            echo "Connect to eProsima VPN";
            echo "------------------------------";
            echo "POSSITIONAL ARGUMENTS:";
            echo "   up       Connect to VPN";
            echo "   down     Disconnect from VPN";
            echo "";
            echo "EXAMPLE: eprosima_vpn up";
            echo "";
        fi;
    fi
}

fix_sound()
{
    systemctl --user unmask pulseaudio
    systemctl --user enable pulseaudio
    systemctl --user restart pulseaudio
    systemctl --user status pulseaudio
}

fix_chrome_rendering()
{
    echo "Cleaning up GPUCache..."
    rm -rf "${HOME}/.config/google-chrome/Profile 1/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/Profile 3/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/System Profile/GPUCache/*"
    rm -rf "${HOME}/.config/google-chrome/Guest Profile/GPUCache/*"
    echo "Restart chrome from the navigation bar with 'chrome://restart'"
}
export PICO_SDK_PATH=/home/eduponz/ephemera/dev/pico/pico-sdk
export PICO_EXAMPLES_PATH=/home/eduponz/ephemera/dev/pico/pico-examples
export PICO_EXTRAS_PATH=/home/eduponz/ephemera/dev/pico/pico-extras
export PICO_PLAYGROUND_PATH=/home/eduponz/ephemera/dev/pico/pico-playground
