#!/bin/bash
#############################################################
## Title: docketexstudio
## Abstact: Starts texstudio in a docker container
## Author:  Fabian Raab <fabian@raab.link>
## Dependencies: docker
## Creation Date: 2017-10-28
## Last Edit: 2018-03-22
##############################################################


SCRIPTNAME=$(basename $0)
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

TEXSTUDIO_IMAGE_NAME="raabf/texstudio-versions"
TEXSTUDIO_CONFIG_PATH="$HOME/.config/dockertexstudio"

image_tag="${DOCKERTEX_DEFAULT_TAG}"
volumes=""

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
echo -e "${BRed}Usage: ${Yel}$SCRIPTNAME${RCol} [${Blu}-t|--tag ${UGre}tagname${RCol}] [${Blu}-v|--volume ${UGre}mapping${RCol}]* [- ${UGre}texstudio options${RCol}]
       ${Yel}$SCRIPTNAME${RCol} ${Blu}-h|--help${RCol}
       ${Yel}$SCRIPTNAME${RCol} [${Blu}-t|--tag ${UGre}tagname${RCol}] - ${Blu}--help${RCol}

    Launches the $TEXSTUDIO_IMAGE_NAME docker-container and adds the home
    directory as a volume to ${Yel}/home/\$HOME${RCol} in the docker container. Then 
    texstudio is started in the container with ${UGre}texstudio options${RCol} as parameters.
    TexStudios cofiguration is stored at ${Yel}$TEXSTUDIO_CONFIG_PATH${RCol}
    Afterwards, the container is removed.

${BRed}OPTIONS:${RCol}
    ${Blu}-h, --help${RCol}
        Print this help text and exit.

    - ${Blu}--help${RCol}
        Print texstudio help for the available ${UGre}texstudio options${RCol} and exit.

    ${Blu}-t, --tag ${UGre}tagname${RCol}
        The latex docker container with tag ${UGre}tagname${RCol} will be used.
        If this option is omitted, ${UGre}tagname${RCol} defaults to the 
        environment variable ${Blu}DOCKERTEX_DEFAULT_TAG${RCol}.

    ${Blu}-v, --volume ${UGre}mapping${RCol}
        Mounts an additional volume into the docker-container. The
        syntax of ${UGre}mapping${RCol} is the same as in ${Yel}docker run${RCol}. 
        This option can be repeated.

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
optspec=':t:v:h-:'

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
                volume)
                    volumes="$volumes --volume=${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
        v)
            volumes="$volumes --volume=${OPTARG}"
            ;;
		\?)	
			echo -e "${Red}Unknown option ${Blu}-$OPTARG\"${Red}.${RCol}" >&2
            echo -e "" 
			usage $EXIT_ERROR
			;;
		:) 	echo -e "${Red}Option ${Blu}-$OPTARG${Red} needs an argument.${RCol}" >&2
            echo -e "" 
			usage $EXIT_ERROR
			;;
		*) 	echo -e "${Red}ERROR: This should not happen.${RCol}" >&2
            echo -e "" 
			usage $EXIT_BUG
			;;
	esac
done

# jump over consumed arguments
shift $(( OPTIND - 1 ))


####### Commands ######

if [ "$image_tag" == "" ]; then
 echo -e "${Red}${Blu}-t, --tag${Red} was omitted and ${Yel}DOCKERTEX_DEFAULT_TAG${Red} is empty. Please specify a ${UGre}tagname${Red}.${RCol}" >&2
 exit $EXIT_ERROR
fi


if ! docker inspect --type=image $TEXSTUDIO_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
    echo -e "${Red}Docker image ${Gre}$TEXSTUDIO_IMAGE_NAME:$image_tag${Red} is locally not available. Please 
use the following command to obtain it:
        ${Blu}docker pull ${Gre}$TEXSTUDIO_IMAGE_NAME:$image_tag${RCol}" >&2
    exit $EXIT_FAILURE
fi


docker run --rm \
    --cap-drop=all \
    --net=host \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix \
    --user="$(id --user):$(id --group)" \
    -e DISPLAY=unix$DISPLAY \
    -e XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    --volume=$TEXSTUDIO_CONFIG_PATH:/home/.config/texstudio \
    --volume=$XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR \
    --volume=$HOME/:$HOME/ $volumes \
    -e HOME=/home/ \
    --name=texstudio_$image_tag --workdir=/home/ \
    $TEXSTUDIO_IMAGE_NAME:$image_tag texstudio "$@" || exit $?

