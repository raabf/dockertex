#!/bin/zsh

0=${(%):-%N}
DOCKERTEX_ROOT="${0:A:h}"

dockertex()
{
    # `bash -c ...` manipulates $0 so that it contain `dockertex`
    # instead of `dockertex.sh`
    bash -c ". ${DOCKERTEX_ROOT}/bin/dockertex.sh" dockertex ${@}
}    

