function eprosima_uncrustify ()
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
            echo "   -m | --modified                Uncrustify modified files. Can be used in";
            echo "                                  combination with --new.";
            echo "   -n | --new                     Uncrustify new files. Can be used in";
            echo "                                  combination with --modified";
            echo ""
            echo "OPTIONAL ARGUMENTS:";
            echo "   -f | --file [FILE]             File to uncrustify";
            echo "   -d | --diff [TARGET] [BASE]    Uncrustify all new and modified files between"
            echo "                                  target and base branch."
            echo "";
            exit ${1}
        };

        function uncrustify_ ()
        {
            for file in "$@";
            do
                uncrustify -c ~/dev/cpp-style/uncrustify.cfg -f "${file}" -o "${file}" --no-backup > /dev/null;
                uncrustify -c ~/dev/cpp-style/uncrustify.cfg -f "${file}" -o "${file}" --no-backup > /dev/null;
            done
        }

         # Working variables
        local uncrustify_modified="";
        local uncrustify_new="";
        local input_file="";
        local target_rev="";
        local base_rev="";
        local diff_eval="false";

        # Validate options
        if ! options=$(getopt \
            --options hmnf:d: \
            --longoption help,modified,new,file:,diff: \
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
                -d | --diff      ) diff_eval="true"; target_rev=${2}; base_rev=${4}; shift 2;;
                -- ) shift; break ;;
                # Wrong args
                * ) echo "Unknown option: '${1}'" >&2; print_usage 1;;
            esac
        done


        local OUTPUT=""

        # --modified and/or --new case
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
        # --file case
        elif [[ ! -z ${input_file} ]]
        then
            OUTPUT="${input_file}"
        # --diff case
        elif [[ "${diff_eval}" == "true" ]]
        then
            echo "DIFF ${base_rev}..${target_rev}"
            OUTPUT=$(\
                git diff \
                    --name-only \
                    ${base_rev}..${target_rev} \
                | grep -e '\.h$' -e '\.hpp$' -e '\.ipp$' -e '\.cpp$' -e '\.cxx$' \
            )
        fi

        for file in ${OUTPUT};
        do
            uncrustify_ "${file}";
        done
    )
}
