function eprosima_docs ()
{
    (
        function print_usage ()
        {
            echo "------------------------------------------------------------------------";
            echo "Command to generate PDFs using eProsima's Documentation Framework";
            echo "------------------------------------------------------------------------";
            echo "OPTIONAL ARGUMENTS:";
            echo "   -h | --help                    Print help";
            echo "   -b | --build_image             Build the docker image";
            echo "   -d | --source_dir  [directory] The directory containing the .md files";
            echo "                                  [Defaults: ./]";
            echo "   -o | --output_file [file]      The name of the output file [Defaults:";
            echo "                                  ./documentation.pdf]";
            echo "   --debug                        Pass the debug flag to the framework";
            echo "   --pandoc_verbose               Pass the debug flag to Pandoc";
            echo "";
            exit ${1}
        };

        function build_docker_image ()
        {
            cd ${HOME}/dev/documentation-framework
            DOCKER_BUILDKIT=1 docker build \
                --squash \
                --progress=plain \
                --target documentation-framework-runtime \
                --tag documentation-framework \
                .
            exit ${?}
        }

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
            --options hbd:o: \
            --longoption \
                help,build_image,debug,pandoc_verbose,source_dir:,output_file: \
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
                -b | --build_image ) build_docker_image 0;;
                --debug            ) debug="--debug"; shift;;
                --pandoc_verbose   ) pandoc_verbose="--pandoc_verbose"; shift;;
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
