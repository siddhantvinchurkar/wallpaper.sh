#!/bin/bash
sudo -v
if [ $? -ne 0 ]; then
    echo "Installing wallpaper.sh requires sudo privileges. Please ensure you have the necessary permissions and try again."
    exit 1
fi
uname -v | grep -qoE 'Ubuntu'
if [ $? -ne 0 ]; then
    echo "wallpaper.sh is designed to work only with Ubuntu-based systems but you're running something else."
    exit 1
fi
if [ $(sudo apt list --installed 2>&1 | grep -coE '^(ubuntu-desktop|ubuntu-desktop-minimal|gsettings-ubuntu-schemas|gsettings-desktop-schemas)') -ne 4 ]; then
    echo "wallpaper.sh is designed to work only with Ubuntu Desktop environments."
    echo "Try running 'sudo apt install -y ubuntu-desktop'. It might help."
    exit 1
fi
required_dependencies=(curl jq dialog)
required_dependencies=($(printf "%s\n" "${required_dependencies[@]}" | sort))
installed_dependencies=($(sudo apt list --installed 2>&1 | grep -oE '^('"$(IFS='|'; echo "${required_dependencies[*]}")"')'))
installed_dependencies=($(printf "%s\n" "${installed_dependencies[@]}" | sort))
missing_dependencies=($(comm -13 <(printf "%s\n" "${installed_dependencies[@]}") <(printf "%s\n" "${required_dependencies[@]}")))
if [ ${#missing_dependencies[@]} -ne 0 ]; then
    echo "The following required dependencies are missing: ${missing_dependencies[*]}"
    echo "No worries, wallpaper.sh will attempt to install them for you..."
    sudo apt update -y
    sudo apt install -y "${missing_dependencies[@]}"
    installed_dependencies=($(sudo apt list --installed 2>&1 | grep -oE '^('"$(IFS='|'; echo "${required_dependencies[*]}")"')'))
    installed_dependencies=($(printf "%s\n" "${installed_dependencies[@]}" | sort))
    missing_dependencies=($(comm -13 <(printf "%s\n" "${installed_dependencies[@]}") <(printf "%s\n" "${required_dependencies[@]}")))
    if [ ${#missing_dependencies[@]} -ne 0 ]; then
        echo "The following required dependencies could not be installed: ${missing_dependencies[*]}"
        echo "Please install them manually and try again."
        exit 1
    fi
fi
if [ ! -f $HOME/.wallpaper.sh.profile ]; then
    clear
    dialog --title "wallpaper.sh setup wizard" --yes-label "Yes, please!" --no-label "No, go away!" --yesno "Welcome to the wallpaper.sh setup wizard. Would you like to install wallpaper.sh for this user ($USER)?" 0 -1
    install_prompt=$?
    clear
    if [ $install_prompt -ne 0 ]; then
        dialog --title "Installation Aborted" --ok-label "Quit" --msgbox "wallpaper.sh was not installed for user '$USER' because you cancelled the installation." 0 -1
        clear
        exit 1
    fi
    clear
    unsplash_api_key=$(dialog --title "Unsplash API Key" --ok-label "Proceed" --no-cancel --stdout --inputbox "wallpaper.sh uses the Unsplash API to fetch wallpapers. Please enter your Unsplash API key to proceed." 0 -1)
    clear
    wallpaper_fetch_interval=$(dialog --title "Wallpaper Fetch Interval" --no-cancel --ok-label "Proceed" --stdout --menu "wallpaper.sh can wait a set amount of time before it changes your wallpaper again since the last time it was changed. This ensures you don't exceed the free allowance of your Unsplash API key. How long should wallpaper.sh wait before changing the wallpaper again since the last time it was changed?" 0 0 4 1 "Don't wait - Change the wallpaper immediately (not recommended)" 2 "Wait for at least 5 minutes" 3 "Wait for at least 30 minutes" 4 "Wait for at least 1 hour")
    clear
    dialog --title "Installing wallpaper.sh" --yes-label "Proceed" --no-label "Abort Installation" --yesno "wallpaper.sh will be installed for this user ($USER). Continue?" 0 -1
    install_prompt=$?
    clear
    if [ $install_prompt -ne 0 ]; then
        dialog --title "Installation Aborted" --ok-label "Quit" --msgbox "wallpaper.sh was not installed for user '$USER' because you cancelled the installation." 0 -1
        clear
        exit 1
    fi
    dialog --title "Configuring wallpaper.sh" --gauge "Writing configuration to $HOME/.wallpaper.sh.config..." 0 -1 10 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    echo "CWUK=$unsplash_api_key" > $HOME/.wallpaper.sh.config
    case $wallpaper_fetch_interval in
        1)
            echo "CWFI=0" >> $HOME/.wallpaper.sh.config
            ;;
        2)
            echo "CWFI=300" >> $HOME/.wallpaper.sh.config
            ;;
        3)
            echo "CWFI=1800" >> $HOME/.wallpaper.sh.config
            ;;
        4)
            echo "CWFI=3600" >> $HOME/.wallpaper.sh.config
            ;;
        *)
            echo "CWFI=3600" >> $HOME/.wallpaper.sh.config
            ;;
    esac
    dialog --title "Configuring wallpaper.sh" --gauge "Writing a default set of keywords to $HOME/.wallpaper.sh.keywords..." 0 -1 20 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    echo -en "nature\ncars\nsummer\nabstract\nwildlife\nurban\nsea\nperspective\nwinter\nautumn\nspring\nmonsoon\nrain\nlandscape\nunhinged\nblur\naerial\nearth\npastel\ntravel\nminimalist\ntextures\ngirls\ncityscape\nbangalore\nblack\nspace\nuniverse\nnight\nsunrise\nsunset\ntrees\ndark\nlonely\ncolorful" > $HOME/.wallpaper.sh.keywords
    dialog --title "Configuring wallpaper.sh" --gauge "Creating log file /var/log/wallpaper.json..." 0 -1 30 &
    PID=$!
    sleep 1
    kill $PID
    [ ! -f /var/log/wallpaper.json ] && sudo touch /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Taking ownership of log file /var/log/wallpaper.json..." 0 -1 40 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    user=$USER
    [ -f /var/log/wallpaper.json ] && sudo chown -R $user:$user /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Adjusting permissions for log file /var/log/wallpaper.json..." 0 -1 50 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    [ -f /var/log/wallpaper.json ] && sudo chmod -R 777 /var/log/wallpaper.json
    [ -f /var/log/wallpaper.json ] && sudo chmod -R +x /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Creating personalized profile script $HOME/.wallpaper.sh.profile..." 0 -1 60 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    echo '#!/bin/bash' > $HOME/.wallpaper.sh.profile
    echo 'if [ -f $HOME/.wallpaper.sh.config ]; then' >> $HOME/.wallpaper.sh.profile
    echo '  while IFS= read -r line; do' >> $HOME/.wallpaper.sh.profile
    echo '    if [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" = "CWFI" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')"' >> $HOME/.wallpaper.sh.profile
    echo '    elif [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" = "CWUK" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')"' >> $HOME/.wallpaper.sh.profile
    echo '    else' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI=3600' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="dbcb74ec750aa178e2494a7d71d7aeb770ab31ee09fb52bbadd441a3c5dac888"' >> $HOME/.wallpaper.sh.profile
    echo '    fi' >> $HOME/.wallpaper.sh.profile
    echo '  done < $HOME/.wallpaper.sh.config' >> $HOME/.wallpaper.sh.profile
    echo 'fi' >> $HOME/.wallpaper.sh.profile
    echo '[ ! -z "${CWFI+x}" ] && export CWFI=$CWFI' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WFI+x}" ] && export WFI=$CWFI' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLF+x}" ] && export WLF=0' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLC+x}" ] && export WLC=$(gsettings get org.gnome.desktop.background picture-uri | cut -d "'\''" -f 2 | cut -c 8-)' >> $HOME/.wallpaper.sh.profile
    echo '[ ! -z "${CWUK+x}" ] && export CWUK=$CWUK' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WUK+x}" ] && export WUK=$CWUK' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WSQ+x}" ] && export WSQ=$(shuf -n 1 $HOME/.wallpaper.sh.keywords)' >> $HOME/.wallpaper.sh.profile
    echo '[ -f /tmp/wpj ] && rm /tmp/wpj' >> $HOME/.wallpaper.sh.profile
    echo '[ $(($(date +%s)-$WLF)) -gt $WFI ] && curl -fsL "https://api.unsplash.com/search/photos?query=$WSQ&client_id=$WUK&per_page=1&orientation=landscape&page="$(shuf -i 1-200 -n 1)"&order_by=latest" -o /tmp/wpj' >> $HOME/.wallpaper.sh.profile
    echo '[ -f /tmp/wpf ] && rm /tmp/wpf' >> $HOME/.wallpaper.sh.profile
    echo '[ $(($(date +%s)-$WLF)) -gt $WFI ] && curl -fsL $(jq -r '\''.results[0].urls.raw'\'' /tmp/wpj) -o /tmp/wpf' >> $HOME/.wallpaper.sh.profile
    echo '[ $(($(date +%s)-$WLF)) -gt $WFI ] && siz=$(curl -fsLI $(jq -r '\''.results[0].urls.raw'\'' /tmp/wpj) | grep -i "^Content-Length:" | awk -F '\'': '\'' '\''{print $2}'\'' | awk '\''{gsub(/\r|\n/, "", $0); print $0}'\'') typ=$(curl -fsLI $(jq -r '\''.results[0].urls.raw'\'' /tmp/wpj) | grep -i "^Content-Type:" | awk -F '\'': '\'' '\''{print $2}'\'' | awk '\''{gsub(/\r|\n/, "", $0); print $0}'\'') jq -r '\''.={description:(.results[0].description // ""),url:(.results[0].urls.raw),width:(.results[0].width),height:(.results[0].height),type:env.typ,size:(env.siz|tonumber)}'\'' /tmp/wpj | tee /var/log/wallpaper.json > /dev/null 2>&1' >> $HOME/.wallpaper.sh.profile
    echo '[ -f /tmp/wpj ] && rm /tmp/wpj' >> $HOME/.wallpaper.sh.profile
    echo '[ -f /tmp/wpf ] && mv /tmp/wpf $WLC' >> $HOME/.wallpaper.sh.profile
    echo '[ $(($(date +%s)-$WLF)) -gt $WFI ] && export WLF=$(date +%s)' >> $HOME/.wallpaper.sh.profile
    dialog --title "Installing wallpaper.sh" --gauge "Appending profile script to $HOME/.profile..." 0 -1 70 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    grep -q 'source $HOME/.wallpaper.sh.profile' $HOME/.profile
    [ $? -ne 0 ] && [ -f $HOME/.profile ] && echo '[ -f $HOME/.wallpaper.sh.profile ] && source $HOME/.wallpaper.sh.profile' >> $HOME/.profile
    dialog --title "Installing wallpaper.sh" --gauge "Creating alias 'wp' in $HOME/.bash_aliases..." 0 -1 80 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    [ ! -f $HOME/.bash_aliases ] && echo '#!/bin/bash' > $HOME/.bash_aliases
    [ -f $HOME/.bash_aliases ] && chmod +x $HOME/.bash_aliases
    alias wp > /dev/null 2>&1
    [ $? -ne 0 ] && [ -f $HOME/.bash_aliases ] && echo 'alias wp="curl -fsL \"https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh\" | bash"' >> $HOME/.bash_aliases
    alias wp="curl -fsL \"https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh\" | bash"
    [ -f $HOME/.bash_aliases ] && source $HOME/.bash_aliases
    dialog --title "Installing wallpaper.sh" --gauge "Adjusting permissions for $HOME/.wallpaper.sh.profile..." 0 -1 90 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    chmod +x $HOME/.wallpaper.sh.profile
    dialog --title "Verifying wallpaper.sh" --gauge "Attempting to fetch and set your first wallpaper..." 0 -1 95 &
    PID=$!
    WLF=0 source $HOME/.profile
    dialog --title "Verifying wallpaper.sh" --gauge "Verification successful!" 0 -1 100 &
    PID=$!
    sleep 1
    kill $PID > /dev/null 2>&1
    clear
    dialog --title "Installation Complete" --ok-label "Let's Go!" --msgbox "wallpaper.sh has been successfully installed for this user ($USER). To run wallpaper.sh, use the command 'wp'." 0 -1
    clear
    curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
else
    clear
    wp_menu_choice=$(dialog --title "wallpaper.sh" --no-cancel --stdout --menu "What would you like to do?" 0 -1 7 1 "Change wallpaper" 2 "Get details about the current wallpaper" 3 "Update the wallpaper fetch interval" 4 "Automation Settings" 5 "View the current configuration" 6 "Uninstall wallpaper.sh" 7 "Exit")
    clear
    case $wp_menu_choice in
        1)
            clear
            dialog --title "Changing Wallpaper" --gauge "Fetching a new wallpaper..." 0 -1 100 &
            PID=$!
            WLF=0 source $HOME/.wallpaper.sh.profile
            kill $PID > /dev/null 2>&1
            clear
            curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
            ;;
        2)
            clear
            dialog --title "Current Wallpaper Details" --ok-label "Go Back" --msgbox "$(cat /var/log/wallpaper.json | jq -r '.|to_entries|.[]|[.key,.value]|@tsv' | column -t -s$'\t')" 0 -1
            clear
            curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
            ;;
        3)
            clear
            wallpaper_fetch_interval=$(dialog --title "Wallpaper Fetch Interval" --no-cancel --stdout --menu "wallpaper.sh can wait a set amount of time before it changes your wallpaper again since the last time it was changed. This ensures you don't exceed the free allowance of your Unsplash API key. How long should wallpaper.sh wait before changing the wallpaper again since the last time it was changed?" 0 -1 4 1 "Don't wait - Change the wallpaper immediately (not recommended)" 2 "Wait for at least 5 minutes" 3 "Wait for at least 30 minutes" 4 "Wait for at least 1 hour")
            echo "CWUK=$WUK" > $HOME/.wallpaper.sh.config
            case $wallpaper_fetch_interval in
                1)
                    echo "CWFI=0" >> $HOME/.wallpaper.sh.config
                    ;;
                2)
                    echo "CWFI=300" >> $HOME/.wallpaper.sh.config
                    ;;
                3)
                    echo "CWFI=1800" >> $HOME/.wallpaper.sh.config
                    ;;
                4)
                    echo "CWFI=3600" >> $HOME/.wallpaper.sh.config
                    ;;
                *)
                    echo "CWFI=3600" >> $HOME/.wallpaper.sh.config
                    ;;
            esac
            WFL=0 source $HOME/.wallpaper.sh.profile
            clear
            dialog --title "Wallpaper Fetch Interval Updated" --ok-label "Cool" --msgbox "The wallpaper fetch interval has been updated." 0 -1
            clear
            curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
            ;;
        4)
            clear
            cron_interval_choice=$(dialog --title "Automation Settings" --no-cancel --stdout --menu "wallpaper.sh can install a cron job to automatically change your wallpaper after a set amount of time has elapsed since the last change. How often would you like wallpaper.sh to change your wallpaper automatically?" 0 -1 10 1 "Do not change my wallpaper automatically" 2 "Once every 5 minutes" 3 "Once every 10 minutes" 4 "Once every 20 minutes" 5 "Once every 30 minutes" 6 "Once every hour" 7 "Once every 3 hours" 8 "4 times a day (every 6 hours)" 9 "Twice a day (every 12 hours)" 10 "Every day (once every 24 hours)")
            cron_interval_choice_message=""
            case $cron_interval_choice in
                1)
                    cron_interval_choice="Done! wallpaper.sh will never change your wallpaper automatically."
                    ;;
                2)
                    cron_interval_choice="*/5 * * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every 5 minutes."
                    ;;
                3)
                    cron_interval_choice="*/10 * * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every 10 minutes."
                    ;;
                4)
                    cron_interval_choice="*/20 * * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every 20 minutes."
                    ;;
                5)
                    cron_interval_choice="*/30 * * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every 30 minutes."
                    ;;
                6)
                    cron_interval_choice="0 * * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every hour."
                    ;;
                7)
                    cron_interval_choice="0 */3 * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper once every 3 hours."
                    ;;
                8)
                    cron_interval_choice="0 */6 * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper 4 times a day (once every 6 hours)."
                    ;;
                9)
                    cron_interval_choice="0 */12 * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper twice a day (once every 12 hours)."
                    ;;
                10)
                    cron_interval_choice="0 0 * * * WLF=0 $HOME/.wallpaper.sh.profile"
                    cron_interval_choice_message="Done! wallpaper.sh will now automatically change your wallpaper every day (once every 24 hours)."
                    ;;
                *)
                    cron_interval_choice="Done! wallpaper.sh will never change your wallpaper automatically."
                    ;;
            esac
            clear
            crontab -l | grep -v -F "$cron_interval_choice" | crontab -
            clear
            dialog --title "Automation Setup" --gauge "Adding a new crontab entry..." 0 -1 50 &
            PID=$!
            crontab -l | { cat; echo "$cron_interval_choice"; } | crontab -
            kill $PID > /dev/null 2>&1
            clear
            dialog --title "Automation Setup" --gauge "$cron_interval_choice_message" 0 -1 100 &
            PID=$!
            sleep 1
            kill $PID > /dev/null 2>&1
            clear
            curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
            ;;
        5)
            clear
            config_table=$(while read -r line; do echo $line | awk -F '=' '{if($1 == "CWUK") print "Unsplash API Key,"$2","(length("Unsplash API Key")+length($2));if($1 == "CWFI") print "Wallpaper Fetch Interval,"$2","(length("Wallpaper Fetch Interval")+length($2));}';done < $HOME/.wallpaper.sh.config | awk -F ',' '{if($3 > prev)prev=$3;print $1","$2","prev;prev=$3}' | awk -F ',' '{printf "|";rem=($3%2);mid=($3-rem);mid=(mid/2);mid=(mid-rem);if(length($1)+length($2)==$3)len=$3+(mid/2)-rem;else len=$3+length($1)+length($2)-(mid/2)-rem;for(i=0;i<len;i++)if(i==mid)printf "|";else {if($1=="Unsplash API Key")printf "‾";else printf "-";};printf "|\\n";print"";printf "|"$1;for(i=0;i<(mid-length($1));i++)printf " ";printf "|"$2;if(length($1)+length($2)==$3)len2=0;else len2=length($1)+(mid/2)+rem;for(i=0;i<len2;i++)printf " ";printf "|\\n";print "";flen=($3+(mid/2)+rem-2);mid2=mid;} END {printf "|";for(i=0;i<flen;i++)if(i==mid2)printf "|";else printf "_";printf "|\\n";print "";}')
            dialog --title "Current Configuration" --ok-label "Go Back" --msgbox "$config_table" -1 -1
            clear
            curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
            ;;
        6)
            clear
            dialog --title "Uninstall wallpaper.sh" --yes-label "Yeah, uninstall it" --no-label "No, keep it" --yesno "Are you sure you want to uninstall wallpaper.sh?" 0 -1
            if [ $? -eq 0 ]; then
                rm -f $HOME/.wallpaper.sh.profile
                rm -f $HOME/.wallpaper.sh.config
                rm -f $HOME/.wallpaper.sh.keywords
                sudo rm -f /var/log/wallpaper.json
                grep -q 'source $HOME/.wallpaper.sh.profile' $HOME/.profile
                [ $? -eq 0 ] && sed -i '/source $HOME\/.wallpaper.sh.profile/d' $HOME/.profile
                grep -q 'alias wp=' $HOME/.bash_aliases
                [ $? -eq 0 ] && sed -i '/alias wp=/d' $HOME/.bash_aliases
                crontab -l | grep -v -F "WLF=0 $HOME/.wallpaper.sh.profile" | crontab -
                unset CWFI CWUK WFI WUK WSQ WLF WLC
                source $HOME/.profile
                clear
                dialog --title "Uninstall Complete" --ok-label "Okay, thanks!" --msgbox "wallpaper.sh has been uninstalled." 0 -1
            fi
            clear
            exit 0
            ;;
        7)
            clear
            exit 0
            ;;
        *)
            clear
            exit 0
            ;;
    esac
    clear
fi
exit 0