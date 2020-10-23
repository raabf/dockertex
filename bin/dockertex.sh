#!/bin/bash
#############################################################
## Title: docketex
## Abstact: Ececutes a command in a latex container
##          within the current working directory.
## Author:  Fabian Raab <fabian@raab.link>
## Dependencies: docker/podman
## Creation Date: 2017-10-28
## Last Edit: 2018-03-22
##############################################################


SCRIPTNAME=$(basename $0)
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

LATEX_IMAGE_NAME="raabf/latex-versions"
LATEX_ARM_IMAGE_NAME="raabf/latex-versions-arm"
TEXSTUDIO_IMAGE_NAME="raabf/texstudio-versions"

# Check which container engine to use. Prefer podman since distros (e.g. Fedora) start to deprecate docker.
if [[ -z $DOCKERTEX_ENGINE ]]; then
    if hash podman; then
        engine=podman
    elif hash docker; then
        engine=docker
    fi
else
    engine="${DOCKERTEX_ENGINE}"
fi

image_tag="${DOCKERTEX_DEFAULT_TAG}"

##### Colors #####
RCol='\e[0m'    # Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';


###### Functions ######

function usage #(exit_code: Optional) 
{
echo -e "${BRed}Usage: ${Yel}$SCRIPTNAME${RCol} [${Blu}-t|--tag ${UGre}tagname${RCol}] ${UGre}command${RCol}
       ${Yel}$SCRIPTNAME${RCol} [${Blu}-h|--help${RCol}]

    Launches the $TEXSTUDIO_IMAGE_NAME – or if not available as
    alternative the $LATEX_IMAGE_NAME or $LATEX_ARM_IMAGE_NAME docker-container – 
    with the tag ${UGre}tagname${RCol} and adds the current working directory as a volume.
    Then ${UGre}command${RCol} is executed in the container in the 
    current working directory. Afterwards, the container is removed.

${BRed}OPTIONS:${RCol}
    ${Blu}-h, --help${RCol}
        Print this help and exit.

    ${Blu}-t, --tag ${UGre}tagname${RCol}
        The latex docker container with tag ${UGre}tagname${RCol} will be used.
        If this option is omitted, ${UGre}tagname${RCol} defaults to the 
        environment variable ${Blu}DOCKERTEX_DEFAULT_TAG${RCol}.

    ${Blu}--engine ${UGre}enginename${RCol}
        The executable ${UGre}enginename${RCol} will be used to run the container.
        It defaults to ${Gre}podman${RCol} when it is installed, else ${Gre}docker${RCol}.


${BRed}EXAMPLES:${RCol}
    ${Yel}$SCRIPTNAME${RCol} ${Blu}--tag ${Gre}texlive2016${RCol} ${Gre}make all${RCol}
    ${Yel}$SCRIPTNAME${RCol} ${Blu}--tag ${Gre}arm64-texlive2016${RCol} ${Gre}make${RCol}
    ${Yel}export${RCol} ${Blu}DOCKERTEX_DEFAULT_TAG${RCol}=${Gre}texlive2017${RCol}
    ${Yel}$SCRIPTNAME${RCol} ${Gre}pdflatex document.tex${RCol}
    
${BRed}EXIT STATUS:${RCol}
    If everything is successfull the script will exit with $EXIT_SUCCESS.
    Failure exit statuses of the script itself are $EXIT_FAILURE, $EXIT_ERROR, and $EXIT_BUG.
    When ${Yel}docker run${RCol} is executed it returns whatever this command
    returns. See docker run manpage for further information.
"
    [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}


###### Parse Options ######

# first ':' prevents getopts error messages
optspec=':t:h-:'

while getopts "$optspec" OPTION ; do
    case $OPTION in
        -)
            case "${OPTARG}" in
                help)
                    usage $EXIT_SUCCESS
                    ;;
                tag)
                    image_tag="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                engine)
                    engine="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                *)  
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" == ":" ]; then
                    echo -e "${Red}Unknown option ${Blu}--$OPTARG${Red}.${RCol}" >&2
                    echo -e "" 
                    usage $EXIT_FAILURE
                fi
                ;;
            esac
            ;;
        h) 
            usage $EXIT_SUCCESS
            ;;
        t)
            image_tag=$OPTARG
            ;;
        \?) 
            echo -e "${Red}Unknown option ${Blu}-$OPTARG\"${Red}.${RCol}" >&2
            echo -e "" 
            usage $EXIT_ERROR
            ;;
        :)  echo -e "${Red}Option ${Blu}-$OPTARG${Red} needs an argument.${RCol}" >&2
            echo -e "" 
            usage $EXIT_ERROR
            ;;
        *)  echo -e "${Red}ERROR: This should not happen.${RCol}" >&2
            echo -e "" 
            usage $EXIT_BUG
            ;;
    esac
done

# jump over consumed arguments
shift $(( OPTIND - 1 ))

# Testing if there are enough arguments
if (( $# < 1 )) ; then
 echo -e "${Red}At least one argument is required.${RCol}" >&2
 echo -e "" 
 usage $EXIT_FAILURE
fi

if [[ -z $engine ]]; then
    echo -e "${Red}No supported engine found!${RCol}" >&2
    echo -e "${Red}Install either docker or podman, or set the correct path to${RCol}" >&2
    echo -e "${Red}the binaries with the DOCKERTEX_ENGINE variable or --engine option.${RCol}" >&2
fi

####### Commands ######

if [ "$image_tag" == "" ]; then
 echo -e "${Red}${Blu}-t, --tag${Red} was omitted and ${Yel}DOCKERTEX_DEFAULT_TAG${Red} is empty. Please specify a ${UGre}tagname${Red}.${RCol}" >&2
 exit $EXIT_FAILURE
fi


if $engine inspect --type=image $TEXSTUDIO_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
    image_name=$TEXSTUDIO_IMAGE_NAME
else
    if $engine inspect --type=image $LATEX_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
        image_name=$LATEX_IMAGE_NAME
    else
        if $engine inspect --type=image $LATEX_ARM_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
            image_name=$LATEX_ARM_IMAGE_NAME
        else
            echo -e "${Red}The requested docker image with tag ${Gre}$image_tag${Red} is locally not available.
Please use one of the following commands to obtain it:" >&2
            if [[ ${image_tag%%-*} == "arm"* ]]; then
                echo -e "       ${Blu}$engine pull ${Gre}$LATEX_ARM_IMAGE_NAME:$image_tag${RCol}" >&2
            else
                echo -e "        ${Blu}$engine pull ${Gre}$LATEX_IMAGE_NAME:$image_tag${RCol}
        ${Blu}$engine pull ${Gre}$TEXSTUDIO_IMAGE_NAME:$image_tag${RCol}" >&2
            fi
            exit $EXIT_FAILURE
        fi
    fi
fi

# Build the the main command. This rather complcated way is because the --user option breaks file access on podman.
# For reference see: https://github.com/containers/libpod/issues/2898
base_cmd="$engine run --rm --interactive \
    --name=latex_$image_tag --net=none \
    --volume=$PWD:/home/workdir \
    --workdir=/home/workdir \
    -e HOME=/home"

if [[ "$engine" == "docker" ]]; then
  base_cmd="$base_cmd --user=$(id --user):$(id --group)"
fi

base_cmd="$base_cmd $image_name:$image_tag $@"

$base_cmd || exit $?

