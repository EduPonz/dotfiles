# function this_dir()
# {
#     pushd . > '/dev/null';
#     local script_path="${BASH_SOURCE[0]:-$0}";

#     while [ -h "${script_path}" ];
#     do
#         cd "$( dirname -- "${script_path}"; )";
#         script_path="$( readlink -f -- "${script_path}"; )";
#     done

#     cd "$( dirname -- "${script_path}"; )" > '/dev/null';
#     script_path="$( pwd; )";
#     popd  > '/dev/null';
#     echo ${script_path}
# }

# UTILS_DIR=$(this_dir)

source /home/eduponz/.bashrc_utils/eprosima_docs.bash
source /home/eduponz/.bashrc_utils/eprosima_uncrustify.bash
source /home/eduponz/.bashrc_utils/eprosima_vpn.bash
source /home/eduponz/.bashrc_utils/fix_chrome_rendering.bash
source /home/eduponz/.bashrc_utils/fix_sound.bash
source /home/eduponz/.bashrc_utils/ccache.bash
