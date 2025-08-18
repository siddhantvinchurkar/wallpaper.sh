#!/bin/bash
if [ ! -f $HOME/.wallpaper.sh.profile ]; then
    clear
    dialog --title "wallpaper.sh setup wizard" --yesno "Welcome to the wallpaper.sh setup wizard. Would you like to install wallpaper.sh for this user ($USER)?" 0 -1
    install_prompt=$?
    clear
    if [ $install_prompt -ne 0 ]; then
        echo "Installation cancelled."
        exit 1
    fi
    clear
    unsplash_api_key=$(dialog --title "Unsplash API Key" --stdout --inputbox "wallpaper.sh uses the Unsplash API to fetch wallpapers. Please enter your Unsplash API key to proceed." 0 -1)
    clear
    wallpaper_fetch_interval=$(dialog --title "Wallpaper Fetch Interval" --stdout --menu "wallpaper.sh can wait a set amount of time before it changes your wallpaper again since the last time it was changed. This ensures you don't exceed the free allowance of your Unsplash API key. How long should wallpaper.sh wait before changing the wallpaper again since the last time it was changed?" 0 0 4 1 "Don't wait - Change the wallpaper immediately (not recommended)" 2 "Wait for at least 5 minutes" 3 "Wait for at least 30 minutes" 4 "Wait for at least 1 hour")
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
    echo -en "nature\ncars\nsummer\nabstract\nwildlife\nurban\nsea\nperspective\nwinter\nautumn\nspring\nmonsoon\nrain\nlandscape\nunhinged\nblur\naerial\nearth\npastel\ntravel\nminimalist\ntextures\ngirls\ncityscape\nbangalore\nblack\nspace\nuniverse\nnight\nsunrise\nsunset\ntrees\ndark\nlonely\ncolorful" > $HOME/.wallpaper.sh.keywords
    clear
    dialog --title "Installing wallpaper.sh" --msgbox "wallpaper.sh will be installed for this user ($USER)." 0 -1
    clear
    echo '#!/bin/bash' > $HOME/.wallpaper.sh.profile
    echo 'if [ -f $HOME/.wallpaper.sh.config ]; then' >> $HOME/.wallpaper.sh.profile
    echo '  while IFS= read -r line; do' >> $HOME/.wallpaper.sh.profile
    echo '    if [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" == "CWFI" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')" ' >> $HOME/.wallpaper.sh.profile
    echo '    else' >> $HOME/.wallpaper.sh.profile
    echo '      export CWFI=3600' >> $HOME/.wallpaper.sh.profile
    echo '    fi' >> $HOME/.wallpaper.sh.profile
    echo '    if [ "$(echo "$line" | awk -F '\''='\'' '\''{print $1}'\'')" == "CWUK" ]; then' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="$(echo "$line" | awk -F '\''='\'' '\''{print $2}'\'')" ' >> $HOME/.wallpaper.sh.profile
    echo '    else' >> $HOME/.wallpaper.sh.profile
    echo '      export CWUK="dbcb74ec750aa178e2494a7d71d7aeb770ab31ee09fb52bbadd441a3c5dac888"' >> $HOME/.wallpaper.sh.profile
    echo '    fi' >> $HOME/.wallpaper.sh.profile
    echo '  done' >> $HOME/.wallpaper.sh.profile
    echo 'fi' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WFI+x}" ] && export WFI=$CWFI' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLF+x}" ] && export WLF=0' >> $HOME/.wallpaper.sh.profile
    echo '[ -z "${WLC+x}" ] && export WLC=$(gsettings get org.gnome.desktop.background picture-uri | cut -d "'\''" -f 2 | cut -c 8-)' >> $HOME/.wallpaper.sh.profile
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
    grep -q 'source $HOME/.wallpaper.sh.profile' $HOME/.profile
    [ $? -ne 0 ] && [ -f $HOME/.profile ] && echo '[ -f $HOME/.wallpaper.sh.profile ] && source $HOME/.wallpaper.sh.profile' >> $HOME/.profile
    [ ! -f $HOME/.bash_aliases ] && echo '#!/bin/bash' > $HOME/.bash_aliases
    [ -f $HOME/.bash_aliases ] && chmod +x $HOME/.bash_aliases
    alias wp
    [ -f $HOME/.bash_aliases ] && [ $? -ne 0 ] && echo 'alias wp="source $HOME/.wallpaper.sh.profile"' >> $HOME/.bash_aliases
    chmod +x $HOME/.wallpaper.sh.profile
    source $HOME/.profile
    clear
    dialog --title "Installation Complete" --msgbox "wallpaper.sh has been successfully installed for this user ($USER). To run wallpaper.sh, use the command 'wp'." 0 -1
    clear
else
    clear
    wp_menu_choice=$(dialog --title "wallpaper.sh" --stdout --menu "What would you like to do?" 0 -1 4 1 "Change wallpaper" 2 "Get details about the current wallpaper" 3 "Update the wallpaper fetch interval" 4 "Exit")
    clear
    case $wp_menu_choice in
        1)
            clear
            WFL=0 source $HOME/.wallpaper.sh.profile
            wp
            ;;
        2)
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
            wp
            ;;
        3)
            clear
            dialog --title "Current Wallpaper Details" --msgbox "$(cat /var/log/wallpaper.json)" 0 -1
            clear
            wp
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