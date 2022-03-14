#!/usr/bin bash

# wrapper script to start the postgres docker server, call dbeaver, and do periodic backups of the server
# workaround for use on Windows/WSL as the filesystems between Windows and Linux are somewhat incompatible 
# (namely with permissions) and will not allow volume mounts that postgres requires

# To workaround such, we start a postgres service with a named volume to save data
# Then this script will execute a `docker exec` command to `pg_dumpall` into our local file system, then copy
# that dump to two other locations for archival.

# Disclaimer: I have no idea what impacts this has on performance, but it works well for small databases

# assumes this is running WSL2, not native Linux
# assumes dbeaver is downloaded into Program Files on Windows host
# adaptation to native Linux should be fairly easy though

# todo: add check for docker daemon running?

function getEnv(){
	export $(grep -v '^#' .env | xargs)
}

function serverUp(){
    $(docker compose up -d)
}

function serverDown(){
    $(docker compose down)
}

function dbeaverUp(){
    # bring up dbeaver
    exe="/mnt/c/Program Files/DBeaver/dbeaver.exe"
    "$exe" </dev/null &>/dev/null &
}

function archiver(){
    local day_time_readable=$(date +'%D %T')
    echo "${day_time_readable} Beginning archive..."
    
	local timestamp=$(date +'%Y%m%d_%H%M%S')
    docker exec -u ${PG_USER} db-postgres-1 pg_dumpall > "${LOCAL_ARCHIVE}/${timestamp}.dump" && echo "${day_time_readable} Archival successful" || echo "${day_time_readable} Archival failed"
    cp "${LOCAL_ARCHIVE}/${timestamp}.dump" "${FS_SERVER_ARCHIVE}"    
}

function main(){
    day_time_readable=$(date +'%D %T')
    
	getEnv
    
    echo "${day_time_readable} Starting server..."
    serverUp
    
    echo "${day_time_readable} Starting DBeaver..."
    dbeaverUp
    
    echo "${day_time_readable} Initial archiving..."
    archiver

	# archive every hour
	INTERVAL=3600

    while true; do
        printf "\nPress '%s' to begin an archive\nPress '%s' to exit\n" 'a' 'q'
        read -t $INTERVAL -n 1 char <&1
        
		if [ ! -z "$char" ]; then
			# manual archive
			if [[ "$char" == a ]]; then
				archiver;
			
			elif [[ "$char" == q ]]; then
				echo; echo "${day_time_readable} Getting final archive..."
				archiver
				
				echo "Shutting server down..."
				serverDown
				
				break
			fi
		else
            archiver
        fi
    done
}

main