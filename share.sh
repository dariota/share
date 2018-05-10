#!/bin/bash

source lib/config.sh

REMOTE_HOST=""
REMOTE_PATH=""
REMOTE_NAME=""
SAFE=""

function get_config() {
	if [ -f ~/.config/share/config ]
	then
		REMOTE_HOST=$(config_get REMOTE)
		REMOTE_PATH=$(config_get PATH)
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
				ERR="${ERR} - Unknown flag -$opt.\n"
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

get_config $@
validate_options
