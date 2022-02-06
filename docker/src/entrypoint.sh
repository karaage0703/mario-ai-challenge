#!/bin/bash
set -e

DEFAULT_USER=${DEFAULT_USER:-'ubuntu'}
DEFAULT_USER_UID=${USER_UID:-'1000'}
DEFAULT_USER_GID=${USER_GID:-'1000'}
NOPASSWD=${NOPASSWD:-''} # set 'NOPASSWD:' to disable asking sudo password
BUILD_TOOL=${BUILD_TOOL:-'catkin-tools'}

# override if $USER env exists
if [[ ! -z "$USER" ]]; then
	DEFAULT_USER=$USER
fi

# create development user
if [[ $(id -u) -eq 0 ]]; then
	EXEC="exec /usr/local/bin/su-exec ${DEFAULT_USER}"

	# create_user
	if [[ ! -e /home/${DEFAULT_USER} ]]; then
		groupadd -g "${DEFAULT_USER_GID}" "${DEFAULT_USER}"
		useradd --create-home --home-dir /home/${DEFAULT_USER} --uid ${DEFAULT_USER_UID} --shell /bin/bash \
		    --gid ${DEFAULT_USER_GID} --groups sudo ${DEFAULT_USER}
		echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd && \
		echo "${DEFAULT_USER} ALL=(ALL) ${NOPASSWD}ALL" >> /etc/sudoers
		touch /home/${DEFAULT_USER}/.sudo_as_admin_successful
	fi

	chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER}

	# mount develop workspace
	if [ -e /workspace ]; then
		ln -s /workspace /home/${DEFAULT_USER}/workspace
	fi

	DEFAULT_USER_UID="$(${EXEC} id -u)"
	DEFAULT_USER_GID="$(${EXEC} id -g)"
else # use existing user
	EXEC="exec"
	DEFAULT_USER="$(whoami)"
	DEFAULT_USER_UID="$(id -u)"
	DEFAULT_USER_GID="$(id -g)"
fi

echo "Launched container with user: $DEFAULT_USER, uid: $DEFAULT_USER_UID, gid: $DEFAULT_USER_GID"

echo $@

if which "$1" > /dev/null 2>&1 ; then
	$EXEC "$@"
else
	echo $@ | $EXEC $SHELL -li
fi
