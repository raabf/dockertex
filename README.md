🐋📓 DockerTeX ➕ 🐋📽 DockerTeXstudio
=====================================

![docker automated](https://img.shields.io/docker/automated/raabf/latex-versions.svg)
![maintained](https://img.shields.io/maintenance/yes/2018.svg)
![licence](https://img.shields.io/github/license/raabf/dockertex.svg)

#### Dockerhub:

| 📓[raabf/latex-versions](https://hub.docker.com/r/raabf/latex-versions) | 📽[raabf/texstudio-versions](https://hub.docker.com/r/raabf/texstudio-versions)|
|---------------|---------------|
| ![docker stars](https://img.shields.io/docker/stars/raabf/latex-versions.svg) ![docker pulls](https://img.shields.io/docker/pulls/raabf/latex-versions.svg) ![docker stars](https://img.shields.io/docker/build/raabf/latex-versions.svg) | ![docker stars](https://img.shields.io/docker/stars/raabf/texstudio-versions.svg) ![docker pulls](https://img.shields.io/docker/pulls/raabf/texstudio-versions.svg) ![docker stars](https://img.shields.io/docker/build/raabf/texstudio-versions.svg)|

Both images are automatically rebuild on Dockerhub when the Debian or Ubuntu base images change (they do on avarage each once per month).raabf/latex-versions.svg) !

## 🏆 Features

  + 💯 The only latex docker which provides different texlive versions — all from 2012–2018!
  + 🐧 Uses Linux Debian and Ubuntu as backend.
  + 🏙 Complete latex package (texlive-full), which includes every latex module you normally need.
  + 📽 [TeXstudio](https://www.texstudio.org/)  GUI can be started in all containers.
  + 🏭 Common tools used with latex are pre-installed: biber, make, gnuplot, inkscape, pandoc, python-pygments.
  + ⬛ Easy and short shell commands to build your document in the docker container (see “Usage” section).
  + 🎎 Preserves your ownership (user and group ID) of all your files which get pushed or created by the docker container.
  + 👷 Easy installation via script or shell plugin-manager.
  + 🗃 Menu entries for texstudio of all installed texlive versions.
  + 🖥 The TexStudio GUI runs directly on your local X-server via shared sockets (no ssh X-forwarding or something like that).
  +  📍 The TexStudio “Go to PDF” and ‘’Go to Source Code” are working as well as the [LanguageTool](https://languagetool.org/) integration.

## 🏷 Supported tags

To specify your texlive version you can either use the texlive tag (texlive2012, texlive2013, …) or use the distribution codenames (wheezy, trusty, …)

| 📓texlive | 🏷docker-tag | 📀distro | 🏷docker-tag | 🐳Dockerfiles     | 📋Notes                                |
|----------:|:------------|--------:|:------------|:-----------------|:--------------------------------------|
|    v2012 | texlive2012 |  Debian | wheezy      | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/debian-wheezy.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/debian-wheezy.Dockerfile) |                                       |
|    v2013 | texlive2013 |  Ubuntu | trusty      | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/ubuntu-trusty.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/ubuntu-trusty.Dockerfile) |                                       |
|    v2014 | texlive2014 |  Debian | jessie      | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/debian-jessie.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/debian-jessie.Dockerfile) |                                       |
|    v2015 | texlive2015 |  Ubuntu | xenial      | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/ubuntu-xenial.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/ubuntu-xenial.Dockerfile) |                                       |
|    v2016 | texlive2016 |  Debian | stretch     | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/debian-stretch.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/debian-stretch.Dockerfile) | current latest-tag                    |
|    v2017 | texlive2017 |  Debian | buster      | [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/debian-buster.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/debian-buster.Dockerfile) | in development; texstudio not working |
|    v2018 | texlive2018 |  Debian | experimental| [LT📓](https://gitlab.com/raabf/dockertex/blob/master/latex/debian-experimental.Dockerfile), [TS📽](https://gitlab.com/raabf/dockertex/blob/master/texstudio/debian-experimental.Dockerfile) | in development; texstudio not working |

## 🖱 Usage

Obviously docker must be installed on your system.
You can either use the dockertexstudio images or – if you never need TexStudio – just the dockertex images. The dockertexstudio images include all features of the dockertex images.  `dockertex` will automatically use the dockertexstudio images when installed on the local system, so that not twice as much disk space is occupied on your computer. 
 `dockertex` and `dockertexstudio`  will promt you to pull the docker images when necessary.

### 📓 dockertex

Let's assume you are in a direcory with your latex file called `document.tex`, then for example just run:

    dockertex --tag texlive2016 pdftex document.tex

The general syntax is:

    dockertex [-t|--tag tagname] command

`dockertex` run the docker container with the tag `tagname` and mounts the current working direcory `pwd` as a volume and just executes `command` in this mount point. Furthermore, the script makes sure that all files (changed and newly generated files) preserve their ownership (user and group ID) of the user executing `dockertex`.

`command` can be arbitray and is not limit to tex commands, for example if you use a `Makefile`:

    dockertex --tag jessie make all

**Default Tag** To set a default Tag so that `--tag` is optional, set the environment variable:

    export DOCKERTEX_DEFAULT_TAG="texlive2016"

### dockertexstudio

`dockertexstudio` is a tool to start [TexStudio](https://www.texstudio.org/)  GUI inside a specified docker container. The usage of the tag is the same as `dockertex`:

     dockertexstudio [-t|--tag tagname] [-v|--volume mapping]* [texstudio options]

`dockertexstudio` always mounts your home direcory `~` as volume in the conainer. If you need additional mount points, use `--volume`, which has the same synax as in `docker run`. For example:

    dockertexstudio --tag texlive2016  --volume /media/git/:/home/git/

The cenfiguration of TexStudio in the containers and among the containers is perserved between runs of the docker containers. Execute `dockertexstudio --help` to display the local path of the configuration folder.

**Menu Entries**  The menu entries generated during the Installation process will also make use of `dockertexstudio`. In your file manager, you can even open `.tex` files directly with TexStudio inside the container. Just assign `.tex` files to the appropriate menu entry. But be careful, direct opening only works if the full file path inside and outside the container, is the same — this is the case for the per default mounted home direcory.

**Go to** Because TeXstudio is running inside the docker container, the “Go to PDF” and ‘’Go to Source Code”  functions via synctex are working.

**LanguageTool** [LanguageTool](https://languagetool.org/) is an advanced tool for grammar checking. It can be accessed via its HTTP API. `dockertexstudio` shares its network interface with the host system, so you can lunch LanguageTool on your host’s localhost interface (which is the default configuration for LanguageTool, so just start it normally) and `dockertexstudio` will be able to access it.

## 🛠 Installation

### 👔 zsh plugin manager

The most comfortable method to install it, is with a zsh plugin-manager. This approach has the big advantage that dockertex cli will be updated together with your other plugins. 

The script `/posthook.sh` can install a menu entry into your desktop environment. The mandatory option `--menu-tag` allows to specify a docker tag for the menu entry. For mounting additional volumes, use the `--menu-volume` option—the syntax is the same as in `docker run`, except that you have to replace `:` with `=` because zplug does not allow a `:` in a string. Use `./posthook.sh …; ./posthook.sh …` multiple times for installing multiple menu entries for different tags.

Please consult the built-in help if you want to find out what the default installation paths are or to change those.

    curl https://gitlab.com/raabf/dockertex/raw/master/posthook.sh | bash -s -- --help

To install dockertex cli, just add the repository to your plugin configuration  in your `~/.zshrc`. If you want to create a menu entries for texstudio, add `./posthook.sh` to the hook-build. For example your configuration could look like:

**zplug**

    zplug raabf/dockertex, \                                                                                                                                                    
        from:gitlab, \                                                                                                                                                          
        hook-build:"./posthook.sh --menu-tag latest --menu-volume /media/ext/=/home/ext/"

It should work also with any other plugin manager. If you have tested it with other plugin managers and if you want to extend this list please tell me at the [issues board](https://gitlab.com/raabf/dockertex/issues).

### ⛓ Automated script

If you do not have zsh, you can install the dockertex cli and the texstudio menu entries through an install script. 

The mandatory option `--menu-tag` allows to install a menu entry into your desktop environment. For mounting additional volumes, use the `--menu-volume` option—the syntax is the same as in `docker run`. Just execute the script multiple times if want to have multiple menu entries with different tags.

Just run `install.sh` with:

    curl https://gitlab.com/raabf/dockertex/raw/master/install.sh | bash -s -- --menu-tag latest --menu-volume "/media/ext/:/home/ext/"

or to install it system wide

    curl https://gitlab.com/raabf/dockertex/raw/master/install.sh | bash -s -- --system --menu-tag latest --menu-volume /media/ext/:/home/ext/"

Just leave out the `--menu-tag` and `--menu-volume` options if you do not want to create any menu entry.

If you neither want to install the texstudio script nor the menu entries, use the `--no-texstudio` option.

    curl https://gitlab.com/raabf/dockertex/raw/master/install.sh | bash -s -- --no-texstudio

Please consult the built-in help if you want to find out what the default installation paths are or to change those.

    curl https://gitlab.com/raabf/dockertex/raw/master/install.sh | bash -s -- --help

### 🔨 Manual

Copy the scripts from `bin/` to a folder in your `PATH` such as `/usr/local/bin/`: 

    sudo cp bin/dockertex.sh /usr/local/bin/dockertex; sudo cp bin/dockertexstudio.sh /usr/local/bin/dockertexstudio

Make sure that the files have the executable bit set

    chmod a+x /usr/local/bin/dockertex*

Copy TexStudio icon to an arbitrary place: 

    cp misc/icons/hicolor/scalable/apps/texstudio.svg /usr/local/share/icons/hicolor/scalable/apps/texstudio.svg

 Use the template `misc/dockertexstudio.desktop` to create one or multiple menu entry:

    cp misc/dockertexstudio.desktop /usr/local/share/applications/dockertexstudio-stretch.desktop 

Then append the missing fields:

    echo "Name=Docker TexStudio (stretch)                                                                                                                  
    Exec=/usr/local/bin/dockertexstudio --tag stretch  --volume /media/git/:/home/git/ %F                      
    Icon=/usr/local/share/icons/hicolor/scalable/apps/texstudio.svg" >> /usr/local/share/applications/dockertexstudio-stretch.desktop