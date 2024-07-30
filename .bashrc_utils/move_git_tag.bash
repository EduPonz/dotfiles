function move_git_tag ()
{
    (
        function print_usage ()
        {
            echo "---------------------------------";
            echo "Move Git tag in remote repository";
            echo "---------------------------------";
            echo "";
            echo "This tool moves a given Git tag in the remote repository";
            echo "Usage: move_git_tag --tag [tag] [OPTIONS]";
            echo "";
            echo "OPTIONAL FLAGS:";
            echo "   -h | --help              Print help";
            echo "";
            echo "REQUIRED ARGUMENTS:";
            echo "   -t | --tag  [tag]        The tag to move";
            echo ""
            echo "OPTIONAL ARGUMENTS:";
            echo "   -r | --remote  [remote]  Name of the remote [Defaults: origin]";
            echo "";
            exit ${1}
        };

        # Working variables
        local tag="";
        local remote="origin";

        # Validate options
        if ! options=$(getopt \
            --options ht:r: \
            --longoption \
                help,tag:,remote: \
            -- "$@")
        then
            print_usage 1
        fi

        eval set -- "${options}"

        while true
        do
            case "${1}" in
                # Flags
                -h | --help        ) print_usage 0;;
                # Required arguments
                -t | --tag         ) tag=${2}; shift 2;;
                # Optional arguments
                -r | --remote      ) remote=${2}; shift 2;;
                # End mark
                -- ) shift; break ;;
                # Wrong args
                * ) echo "Unknown option: '${1}'" >&2; print_usage 1;;
            esac
        done

        # Validate input options
        if [[ -z ${tag} ]]; then
            echo "Tag is required.";
            print_usage 1;
            return 1;
        fi;

        # TODO(eduponz): Add validation for remote
        # TODO(eduponz): Check if tag exists in remote

        git push ${remote} :refs/tags/${tag}
        git tag -f ${tag}
        git push ${remote} --tags
    )
}
