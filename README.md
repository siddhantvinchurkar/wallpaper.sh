# wallpaper.sh

wallpaper.sh is a rudimentary bash script that searches for and downloads photos from Unsplash and then sets them as your desktop wallpaper. Currently, it only supports desktop installations of Ubuntu.

## Warning

The Unsplash API explicitly prohibits the use of their API for wallpaper applications. wallpaper.sh is intended for personal use only and at your own peril.

## Installation

wallpaper.sh is super easy to install and use. The following command verifies that you're running a supported version of Ubuntu, then installs any required dependencies, and finally presents a _step-by-step_ setup wizard to configure and install wallpaper.sh. Just copy and paste the following command into your terminal to get started.

```bash
curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
```

During the installation process, you'll be prompted to enter an Unsplash API key. If you don't have one, you can create a free account on the Unsplash website and generate an API key from the developer section.

[Get your Unsplash API key](https://unsplash.com/developers "Get your Unsplash API key")

## Usage

wallpaper.sh configures an alias on your system during the installation process. You can use the `wp` command to bring up the wallpaper.sh interface.

```bash
wp
```

Since `wp` is just an alias for the installation command, you can also run the script directly with the following command.

```bash
curl -fsL "https://raw.githubusercontent.com/siddhantvinchurkar/wallpaper.sh/refs/heads/master/wallpaper.sh" | bash
```

If you want to quickly change your wallpaper without going through the entire interface, you can use the following command.

```bash
[ -f $HOME/.wallpaper.sh.profile ] && WFL=0 source $HOME/.wallpaper.sh.profile
```

## Features

During the installation process, wallpaper.sh writes a list of search terms to a configuration file. You can customize these search terms to find wallpapers that suit your taste.

Use any text editor of your choice to modify the configuration file.

```bash
nano $HOME/.wallpaper.sh.keywords
```

Each line should contain a single search term. For example:

```bash
nature
city
abstract
```

## Uninstallation

If you ever need to uninstall wallpaper.sh, just choose the "Uninstall wallpaper.sh" option from the main menu.
You can also manually uninstall it by removing the files and configurations created by wallpaper.sh if you no longer wish to use it. Use the following commands to uninstall wallpaper.sh manually.

```bash
rm -f $HOME/.wallpaper.sh.config
rm -f $HOME/.wallpaper.sh.profile
rm -f $HOME/.wallpaper.sh.keywords
rm -f /var/log/wallpaper.json
grep -q 'source $HOME/.wallpaper.sh.profile' $HOME/.profile; [ $? -eq 0 ] && sed -i '/source $HOME\/.wallpaper.sh.profile/d' $HOME/.profile
grep -q 'alias wp=' $HOME/.bash_aliases; [ $? -eq 0 ] && sed -i '/alias wp=/d' $HOME/.bash_aliases
```

## Logging

wallpaper.sh is designed to fail silently in order to avoid cluttering the user's terminal with error messages. I have not implemented any logging functionality yet and don't plan to either. You're welcome to submit a pull request if you'd like to add this feature though!

That being said, there is a file that stores information about the last wallpaper that was set. You can find it at `/var/log/wallpaper.json`.

To view the contents of this file, you can use the following command:

```bash
cat /var/log/wallpaper.json | jq -r
```

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.
