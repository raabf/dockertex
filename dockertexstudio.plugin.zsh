#!/bin/zsh

0=${(%):-%N}
DOCKERTEX_ROOT="${0:A:h}"

dockertexlatex()
{
    # `bash -c ...` manipulates $0 so that it contain `dockertexstudio`
    # instead of `dockertexstudio.sh`
    bash -c ". ${DOCKERTEX_ROOT}/bin/dockertexstudio.sh" dockertexstudio ${@}
}    

