#!/bin/bash

source lib/config.sh

REMOTE_HOST=""
REMOTE_PATH=""
REMOTE_NAME=""
SAFE=""

function configure() {
	HOST=""
	FILE_PATH=""
	SAFE=""

	while [ -z "$HOST" ]
	do
		echo "Enter a non-empty hostname to use by default. This may be a fully qualified name, or a hostname as specified in your ssh config. This hostname will not undergo any validation."
		read -r HOST
	done
	echo ""

	while [ -z "$FILE_PATH" ]
	do
		echo "Enter the remote file path to use by default, without a trailing /. This can include characters such as ~, which will be interpreted on the remote. This path will not undergo any validation."
		read -r FILE_PATH
	done
	echo ""

	while ! [[ "$SAFE" =~ ^[yYnN]$ ]]
	do
		echo "Enable safety by default? [y/n]"
		read -r SAFE
	done

	if [[ "$SAFE" =~ ^[nN]$ ]]
	then
		SAFE="NO"
	else
		SAFE="YES"
	fi

	mkdir -p ~/.config/share/
	printf -- "REMOTE_HOST=%s\nREMOTE_PATH=%s\nSAFE=%s" "$HOST" "$FILE_PATH" "$SAFE" > ~/.config/share/config
}

function check_configure() {
	while getopts ":c" opt
	do
		case $opt in
			c)
				configure
				exit 0
				;;
		esac
	done

	OPTIND=1
}

function get_options() {
	if [ -f ~/.config/share/config ]
	then
		REMOTE_HOST=$(config_get REMOTE_HOST)
		REMOTE_PATH=$(config_get REMOTE_PATH)
		SAFE=$(config_get SAFE)
	fi

	SPEC_HOST=""
	SPEC_PATH=""
	SPEC_SAFE=""
	SPEC_UNSAFE=""
	SPEC_NAME=""
	ERR=""

	while getopts ":h:p:n:us" opt
	do
		case $opt in
			h)
				if [ -z "$SPEC_HOST" ]
				then
					SPEC_HOST="y"
					REMOTE_HOST="$OPTARG"
				elif [ "$SPEC_HOST" = "y" ]
				then
					SPEC_HOST="err"
					ERR="${ERR} - Host param must be specified only once.\n"
				fi
				;;
			p)
				if [ -z "$SPEC_PATH" ]
				then
					SPEC_PATH="y"
					REMOTE_PATH="$OPTARG"
				elif [ "$SPEC_PATH" = "y" ]
				then
					SPEC_PATH="err"
					ERR="${ERR} - Path param must be specified only once.\n"
				fi
				;;
			n)
				if [ -z "$SPEC_NAME" ]
				then
					SPEC_NAME="y"
					REMOTE_NAME="$OPTARG"
				elif [ "$SPEC_NAME" = "y" ]
				then
					SPEC_NAME="err"
					ERR="${ERR} - Remote name must be specified only once.\n"
				fi
				;;
			u)
				if [ -z "$SPEC_SAFE" ]
				then
					SPEC_UNSAFE="y"
					SAFE="NO"
				elif [ "$SPEC_SAFE" = "y" ] || [ "$SPEC_UNSAFE" = "y" ]
				then
					SPEC_SAFE="err"
					SPEC_UNSAFE="err"
					ERR="${ERR} - Only one of safe or unsafe flags can be specified.\n"
				fi
				;;
			s)
				if [ -z "$SPEC_UNSAFE" ]
				then
					SPEC_SAFE="y"
					SAFE="YES"
				elif [ "$SPEC_SAFE" = "y" ] || [ "$SPEC_UNSAFE" = "y" ]
				then
					SPEC_SAFE="err"
					SPEC_UNSAFE="err"
					ERR="${ERR} - Only one of safe or unsafe flags can be specified.\n"
				fi
				;;
			\?)
				ERR="${ERR} - Unknown flag -$OPTARG.\n"
				;;
			:)
				ERR="${ERR} - Option -$OPTARG requires an argument.\n"
				;;
		esac
	done

	if [ -n "$ERR" ]
	then
		echo "Errors were encountered processing options."
		echo -e "$ERR"
		exit 1
	fi
}

function validate_options() {
	ERR=""

	if [ -z "$REMOTE_HOST" ]
	then
		ERR="${ERR} - Host must be supplied in config or options.\n"
	fi

	if [ -z "$REMOTE_PATH" ]
	then
		ERR="${ERR} - Path must be supplied in config or options.\n"
	fi

	if [ "$SAFE" != "YES" ] && [ "$SAFE" != "NO" ]
	then
		ERR="${ERR} - Safety setting must be supplied in config or options.\n"
	fi

	if [ -n "$ERR" ]
	then
		echo "Errors were encountered validating options."
		echo -e "$ERR"
		exit 2
	fi
}

function set_up_name() {
	shift $(( $OPTIND - 1 ))
	LOCAL_NAME="$1"

	if [ -z "$LOCAL_NAME" ]
	then
		echo "File name to upload must be specified."
		exit 3
	fi

	if [ -z "$REMOTE_NAME" ]
	then
		REMOTE_NAME="$LOCAL_NAME"
	fi
}

function safety_check() {
	if [ "$SAFE" = "YES" ]
	then
		if ssh $REMOTE_HOST test -f $REMOTE_PATH/$REMOTE_NAME
		then
			echo "Safety check failed - remote file exists."
			exit 4
		fi
	fi
}

check_configure $@
get_options $@
validate_options
set_up_name $@
safety_check
