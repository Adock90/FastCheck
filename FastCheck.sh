#!/bin/bash

argcheck=$1
usethirdparty=1


function Help(){
	printf "FastCheck.sh\n\n\tsudo FastCheck.sh [<options(optional)>]\n\t\t--h --H --help --Help --HELP: help, talks about the command optional options(Where you are now)\n\t\t--clear: clears console same as running 'clear' in bash\n\t\t--skip-3rd-party: skips rkhunter and chkrootkit that are 3rd party software"
	exit
}


if [ "$argcheck" == "--h" ] || [ "$argcheck" == "--H"] || [ "$argcheck" == "--help" ] || [ "$argcheck" == "--Help" ] || [ "$argcheck" == "--HELP" ];
then
	Help
elif [ "$argcheck" == "--clear" ];
then
	clear
elif [ "$argcheck" == "--skip-3rd-party" ];
then
	$usethirdparty=0
elif [ "$argcheck" == "" ];
then
	echo "No options"
else
	echo "unknown option"
	Help
fi

RED='\033[31m'
YELLOW='\033[32m'
GREEN='\033[33m'
COLOURRESET='\033[0m'

BOLD='\e[1m'
BOLDRESET='\e[0m'


user=$(whoami)

DEB=0
RED=0
ARCH=0

ls "/etc/debian_version" 2> /dev/null
if [ $? -eq 0 ];
then
	echo "Debian based distro detected"
	DEB=1
else
	echo "Debian based distro not detected"
fi

ls "/etc/redhat-release" 2> /dev/null
if [ $? -eq 0 ];
then
        echo "Red-Hat/Fedora based distro detected"
        RED=1
else

        echo "Red-Hat/Fedora based distro not detected"
fi

ls "/etc/arch-release" 2> /dev/null
if [ $? -eq 0 ];
then
        echo "Arch based distro detected"
        ARCH=1
else
        echo "Arch based distro not detected"
fi


echo "Checking for chkrootkit and rkhunter"

if [ $DEB -eq 1 ];
then
	dpkg -s chkrootkit 2> /dev/null
	if [ $? -eq 1 ];
	then
		printf "$BOLD$YELLOW chkrootkit is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
		read input
		if [ $input == "y" ] || [ $input == "Y" ];
		then
			sudo apt install chkrootkit -y
		else
		
			echo -e "$BOLD$RED Cannot continue without required program $COLOURRESET $BOLDRESET"
		fi
	else
	
		echo  -e "$GREEN chkrootkit is installed $COLOURRESET"
	fi
	
	dpkg -s rkhunter 2> /dev/null
	if [ $? -eq 1 ];
        then
                printf "$BOLD $YELLOW rkhunter is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
                read input
                if [ $input == "y" ] || [ $input == "Y" ];
                then
                        sudo apt install rkhunter -y
                else
                
                        echo -e "$BOLD $RED Cannot continue without required program $COLOURRESET $BOLDRESET"
                fi
        else
        
                echo -e "$GREEN rkhunter is installed $COLOURRESET"
        fi

elif [ $RED -eq 1 ];
then
	rpm -qa chkrootkit 2> /dev/null
        if [ $? -eq 1 ];
        then
                printf "$BOLD $YELLOW chkrootkit is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
		read input
                if [ $input == "y" ] || [ $input == "Y" ];
                then
                        sudo dnf install chkrootkit -y
                else
               
                        echo -e "$BOLD $RED Cannot continue without required program $COLOURRESET $BOLDRESET"
			exit
                fi
        else
  
                echo -e "$GREEN chkrootkit is installed $COLOURRESET"
        fi

	rpm -qa rkhunter 2> /dev/null
        if [ $? -eq 1 ];
        then
                printf "$BOLD $YELLOW rkhunter is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
                read input
                if [ $input == "y" ] || [ $input == "Y" ];
                then
                        sudo dnf install rkhunter -y
                else
                
                        echo -e "$BOLD $RED Cannot continue without required program $COLOURRESET $BOLDRESET"
			exit
                fi
        else
        
                echo -e "$GREEN rkhunter is installed $COLOURRESET"
        fi
elif [ $ARCH -eq 1 ];
then
	pacman -Qi chkrootkit 2> /dev/null
        if [ $? -eq 1 ];
        then
                printf "$BOLD $YELLOW chkrootkit is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
                read input
                if [ $input == "y" ] || [ $input == "Y" ];
                then
                        yes | sudo pacman -S chkrootkit
                else
               
                        echo -e "$BOLD $RED Cannot continue without required program $COLOURRESET $BOLDRESET"
			exit
                fi
        else
       
                echo -e "$GREEN chkrootkit is installed $COLOURRESET"
        fi

        pacman -Qi rkhunter 2> /dev/null
        if [ $? -eq 1 ];
        then
                printf "$BOLD $YELLOW rkhunter is not installed. Want to install.(Y/n) $COLOURRESET $BOLDRESET"
                read input
                if [ $input == "y" ] || [ $input == "Y" ];
                then
                       yes | sudo pacman -S rkhunter
                else
                
                        echo -e "$BOLD $RED Cannot continue without required program $COLOURRESET $BOLDRESET"
			exit
                fi
        else
        
                echo -e "$GREEN rkhunter is installed $COLOURRESET"
        fi
else

	echo -e "$BOLD $RED Unsupported distro $COLOURRESET $BOLDRESET"
	exit
fi

logStore="/home/$USER/.fastcheck"

rpmLogsPath="$logStore/VerifyPackagelogs.log"
dmesgLogsPath="$logStore/dmesglogs.log"
lsmodLogsPath="$logStore/lsmodlogs.log"
journalctlLogsPath="$logStore/journalctllogs.log"
hiddenprocesscheckerLogsPath="$logStore/lshiddenprocesseslogs.log"

echo "Logged in as $user"

if [ $user == "root" ];
then
	echo -e "$GREEN Sucessfully root $COLOURRESET"
else
	echo -e "$BOLD $YELLOW This Script needs root permissions. Run with the sudo command next time. $COLOURRESET $BOLDRESET"
	exit
fi

echo "This is a fast checker for rootkits. Must have chkrootkit and rkhunter installed. Press enter to continue."

read input

mkdir -p $logStore

if [ $usethirdparty -eq 1 ];
then
	echo "updating rkhunter"

	sudo rkhunter --update
	sudo rkhunter --propupd


	echo "proceding with chkrootkit and then rkhunter"

	sudo chkrootkit
	yes "\n" | sudo rkhunter -c

	echo "done with the rootkit scanners now for system inspections"
fi

echo "creating files for their logs"

touch $rpmLogsPath
touch $dmesgLogsPath
touch $lsmodLogsPath
touch $journalctlLogsPath
touch $hiddenprocesscheckerLogsPath

echo "done creating files"

sleep 1

echo "Now running tests"

echo "Checking if Secure Boot is active"

SecBootStat=$(mokutil --sb-state 2> /dev/null)
if [ "$SecBootStat" == "SecureBoot enabled" ];
then
	echo -e "$BOLD$GREEN Secure Boot is enabled$COLOURRESET$BOLDRESET"
else
	echo -e "$BOLD$RED Secure Boot is NOT enabled$COLOURRESET$BOLDRESET"
fi

echo "Checking SELinux"

SELStat=$(sestatus | grep "SELinux status" 2> /dev/null)
if [ "$SELStat" == "SELinux status:                 enabled" ];
then
	echo -e "$BOLD$GREEN SELinux is active$COLOURRESET$BOLDRESET"
elif [ $DEB -eq 1 ];
then
	echo "Checking AppArmor"
	AAStat=$(sudo aa-status | grep "apparmor")
	if [ "$AAStat" == "apparmor module is loaded" ];
	then
		echo -e "$BOLD$GREEN AppArmor is enforcing$COLOURRESET$BOLDRESET"
	else
		echo -e "$BOLD$RED AppArmor checks failed$COLOURRESET$BOLDRESET"
	fi
else
	echo -e "$BOLD$RED SELinux Checks failed$COLOURRESET$BOLDRESET"
fi

echo "Checking Kernel Lockdown"

KrnlLockCheck=$(sudo cat /sys/kernel/security/lockdown)
if [ "$KrnlLockCheck" == "none [integrity] confidentiality" ];
then
	echo -e "$GREEN Kernel Lockdown is enabled $COLOURRESET"
else
	echo -e "$BOLD$RED Kernel Lockdown is not active$COLOURRESET$BOLDRESET"
fi

if [ $RED -eq 1 ];
then
	$(sudo rpm -Va > $rpmLogsPath 2>&1)
elif [ $DEB -eq 1 ];
then
	$(sudo dpkg --verify > $rpmLogsPath)
else
	$(sudo pacman -Qkk > $rpmLogsPath)
fi
$(sudo dmesg | grep -i 'module signature' > $dmesgLogsPath 2>&1)
$(sudo lsmod | sort  > $lsmodLogsPath 2>&1)
$(sudo journalctl -k -p err..alert --no-pager | tail -n 20 > $journalctlLogsPath 2>&1)
$(sudo ls /proc | grep -E '^[0-9]+$' | wc -l  > $hiddenprocesscheckerLogsPath 2>&1)

echo "Done And dusted"

