#!/bin/bash
sudo -v
uname -v | grep -qoE 'Ubuntu'
if [ $? -ne 0 ]; then
    echo "wallpaper.sh is designed to work only with Ubuntu-based systems but you're running something else."
    exit 1
fi
if [ $(apt list --installed 2>&1 | grep -coE '^(ubuntu-desktop|ubuntu-desktop-minimal|gsettings-ubuntu-schemas|gsettings-desktop-schemas)') -ne 4 ]; then
    echo "wallpaper.sh is designed to work only with Ubuntu Desktop environments."
    echo "Try running 'sudo apt install -y ubuntu-desktop'. It might help."
    exit 1
fi
required_dependencies=(curl jq dialog)
required_dependencies=($(printf "%s\n" "${required_dependencies[@]}" | sort))
installed_dependencies=($(apt list --installed 2>&1 | grep -oE '^('"$(IFS='|'; echo "${required_dependencies[*]}")"')'))
installed_dependencies=($(printf "%s\n" "${installed_dependencies[@]}" | sort))
missing_dependencies=($(comm -13 <(printf "%s\n" "${installed_dependencies[@]}") <(printf "%s\n" "${required_dependencies[@]}")))
if [ ${#missing_dependencies[@]} -ne 0 ]; then
    echo "The following required dependencies are missing: ${missing_dependencies[*]}"
    echo "No worries, wallpaper.sh will attempt to install them for you..."
    sudo apt update -y
    sudo apt install -y "${missing_dependencies[@]}"
    installed_dependencies=($(apt list --installed 2>&1 | grep -oE '^('"$(IFS='|'; echo "${required_dependencies[*]}")"')'))
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
    dialog --title "wallpaper.sh setup wizard" --yes-label "Yes, please!" --no-label "No, go away!" --yesno "Welcome to the wallpaper.sh setup wizard. Would you like to install wallpaper.sh for this user ($USER)?" 0 0
    install_prompt=$?
    clear
    if [ $install_prompt -ne 0 ]; then
        dialog --title "Installation Aborted" --ok-label "Quit" --msgbox "wallpaper.sh was not installed for user '$USER' because you cancelled the installation." 0 0
        clear
        exit 1
    fi
    clear
    unsplash_api_key=$(dialog --title "Unsplash API Key" --ok-label "Proceed" --stdout --inputbox "wallpaper.sh uses the Unsplash API to fetch wallpapers. Please enter your Unsplash API key to proceed." 0 -1)
    clear
    wallpaper_fetch_interval=$(dialog --title "Wallpaper Fetch Interval" --ok-label "Proceed" --stdout --menu "wallpaper.sh can wait a set amount of time before it changes your wallpaper again since the last time it was changed. This ensures you don't exceed the free allowance of your Unsplash API key. How long should wallpaper.sh wait before changing the wallpaper again since the last time it was changed?" 0 0 4 1 "Don't wait - Change the wallpaper immediately (not recommended)" 2 "Wait for at least 5 minutes" 3 "Wait for at least 30 minutes" 4 "Wait for at least 1 hour")
    clear
    dialog --title "Installing wallpaper.sh" --yes-label "Proceed" --no-label "Abort Installation" --yesno "wallpaper.sh will be installed for this user ($USER). Continue?" 0 0
    install_prompt=$?
    clear
    if [ $install_prompt -ne 0 ]; then
        dialog --title "Installation Aborted" --ok-label "Quit" --msgbox "wallpaper.sh was not installed for user '$USER' because you cancelled the installation." 0 0
        clear
        exit 1
    fi
    dialog --title "Configuring wallpaper.sh" --gauge "Writing configuration to $HOME/.wallpaper.sh.config..." 0 -1 10 &
    PID=$!
    sleep 1
    kill $PID
    echo "CWUK=\"$unsplash_api_key\"" > $HOME/.wallpaper.sh.config
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
    kill $PID
    echo -en "nature\ncars\nsummer\nabstract\nwildlife\nurban\nsea\nperspective\nwinter\nautumn\nspring\nmonsoon\nrain\nlandscape\nunhinged\nblur\naerial\nearth\npastel\ntravel\nminimalist\ntextures\ngirls\ncityscape\nbangalore\nblack\nspace\nuniverse\nnight\nsunrise\nsunset\ntrees\ndark\nlonely\ncolorful" > $HOME/.wallpaper.sh.keywords
    dialog --title "Configuring wallpaper.sh" --gauge "Creating log file /var/log/wallpaper.json..." 0 -1 30 &
    PID=$!
    sleep 1
    kill $PID
    [ ! -f /var/log/wallpaper.json ] && sudo touch /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Taking ownership of log file /var/log/wallpaper.json..." 0 -1 40 &
    PID=$!
    sleep 1
    kill $PID
    [ ! -f /var/log/wallpaper.json ] && sudo chown -R $USER:$USER /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Adjusting permissions for log file /var/log/wallpaper.json..." 0 -1 50 &
    PID=$!
    sleep 1
    kill $PID
    [ ! -f /var/log/wallpaper.json ] && sudo chmod -R 777 /var/log/wallpaper.json
    [ ! -f /var/log/wallpaper.json ] && sudo chmod -R +x /var/log/wallpaper.json
    dialog --title "Configuring wallpaper.sh" --gauge "Creating personalized profile script $HOME/.wallpaper.sh.profile..." 0 -1 60 &
    PID=$!
    sleep 1
    kill $PID
    echo '#!/bin/bash' > $HOME/.wallpaper.sh.profile
    echo 'if [ -f $HOME/.wallpaper.sh.config ]; then' >> $HOME/.wallpaper.sh.profile
    echo '  while IFS= read -r line; do' >> $HOME/.wallpaper.sh.profile
    echo '    if [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" == "CWFI" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')"' >> $HOME/.wallpaper.sh.profile
    echo '    else' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI=3600' >> $HOME/.wallpaper.sh.profile
    echo '    fi' >> $HOME/.wallpaper.sh.profile
    echo '    if [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" == "CWUK" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')" ' >> $HOME/.wallpaper.sh.profile
    echo '    else' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="dbcb74ec750aa178e2494a7d71d7aeb770ab31ee09fb52bbadd441a3c5dac888"' >> $HOME/.wallpaper.sh.profile
    echo '    fi' >> $HOME/.wallpaper.sh.profile
    echo '  done < $HOME/.wallpaper.sh.config' >> $HOME/.wallpaper.sh.profile
    echo 'fi' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WFI+x}" ] && export WFI="$CWFI"' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLF+x}" ] && export WLF=0' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLC+x}" ] && export WLC=$(gsettings get org.gnome.desktop.background picture-uri | cut -d "'\''" -f 2 | cut -c 8-)' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WUK+x}" ] && export WUK="$CWUK"' >> $HOME/.wallpaper.sh.profile
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
    kill $PID
    grep -q 'source $HOME/.wallpaper.sh.profile' $HOME/.profile
    [ $? -ne 0 ] && [ -f $HOME/.profile ] && echo '[ -f $HOME/.wallpaper.sh.profile ] && source $HOME/.wallpaper.sh.profile' >> $HOME/.profile
    dialog --title "Installing wallpaper.sh" --gauge "Creating alias 'wp' in $HOME/.bash_aliases..." 0 -1 80 &
    PID=$!
    sleep 1
    kill $PID
    [ ! -f $HOME/.bash_aliases ] && echo '#!/bin/bash' > $HOME/.bash_aliases
    [ -f $HOME/.bash_aliases ] && chmod +x $HOME/.bash_aliases
    alias wp > /dev/null 2>&1
    [ $? -ne 0 ] && [ -f $HOME/.bash_aliases ] && echo 'alias wp="bash <(curl -fsL https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh)"' >> $HOME/.bash_aliases
    dialog --title "Installing wallpaper.sh" --gauge "Adjusting permissions for $HOME/.wallpaper.sh.profile..." 0 -1 90 &
    PID=$!
    sleep 1
    kill $PID
    chmod +x $HOME/.wallpaper.sh.profile
    dialog --title "Verifying wallpaper.sh" --gauge "Attempting to fetch and set your first wallpaper..." 0 -1 95 &
    PID=$!
    source $HOME/.profile
    dialog --title "Verifying wallpaper.sh" --gauge "Verification successful!" 0 -1 100 &
    PID=$!
    sleep 1
    kill $PID
    clear
    dialog --title "Installation Complete" --ok-label "Let's Go!" --msgbox "wallpaper.sh has been successfully installed for this user ($USER). To run wallpaper.sh, use the command 'wp'." 0 -1
    clear
    bash <(curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh")
else
    clear
    wp_menu_choice=$(dialog --title "wallpaper.sh" --stdout --menu "What would you like to do?" 0 -1 4 1 "Change wallpaper" 2 "Get details about the current wallpaper" 3 "Update the wallpaper fetch interval" 4 "Exit")
    clear
    case $wp_menu_choice in
        1)
            clear
            WFL=0 source $HOME/.wallpaper.sh.profile
            bash <(curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh")
            ;;
        2)
            clear
            dialog --title "Current Wallpaper Details" --msgbox "$(cat /var/log/wallpaper.json | jq -r '.|to_entries|.[]|[.key,.value]|@tsv' | column -t -s$'\t')" 0 -1
            clear
            bash <(curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh")
            ;;
        3)
            clear
            wallpaper_fetch_interval=$(dialog --title "Wallpaper Fetch Interval" --stdout --menu "wallpaper.sh can wait a set amount of time before it changes your wallpaper again since the last time it was changed. This ensures you don't exceed the free allowance of your Unsplash API key. How long should wallpaper.sh wait before changing the wallpaper again since the last time it was changed?" 0 0 4 1 "Don't wait - Change the wallpaper immediately (not recommended)" 2 "Wait for at least 5 minutes" 3 "Wait for at least 30 minutes" 4 "Wait for at least 1 hour")
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
            dialog --title "Wallpaper Fetch Interval Updated" --msgbox "The wallpaper fetch interval has been updated." 0 -1
            clear
            bash <(curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh")
            ;;
        4)
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