# 🐧 LinuxSetup

A personal repository containing all needed configuration files for any Linux distributions I have used previously or am currently using.

Feel free to take inspiration, reproduce my setup, or fork/clone and adjust it to your own needs.

## 📌 Currently Supported Distributions

-   Fedora Workstation.

## 📋 Usage Notes

### General Usage Notes

#### The `setup.sh` script automates a large portion of the post-install setup process for various Linux distributions by:

**1. Installing fonts listed in the `fonts` directory.**

Add any fonts desired for installation to this directory and `setup.sh` will register them with the specific distribution.

**2. Uninstalling a list of unwanted stock applications included with the specific distribution (`applications/example-distro/uninstall-list.txt`).**

Add unwanted stock applications' names to this file, one per line. Make sure the names are the _actual_ names instead of a GUI-only alias (e.g. GNOME Files is actually called nautilus).

**3. Adding any additional repositories needed for software installation for the specific distribution.**

(To do: split this logic from the main script)

**4. Installing any needed drivers for the specific distribution.**

(To do: split this logic from the main script)

**5. Installing a list of wanted native applications using the distribution's native package manager (`applications/example-distro/native-list.txt`).**

Add wanted native applications' names to this file, one per line. Make sure the names are the _actual_ names instead of a GUI-only alias (e.g. GNOME Files is actually called nautilus).

**6. Installing any wanted native applications using direct downloads for the specific distribution.**

(To do: split this logic from the main script)

**7. Applying system or application configurations which are able to be automated for the specific distribution.**

(To do: split this logic from the main script)

**8. Installing a list of wanted Flatpak applications from Flathub for the specific distribution (`applications/example-distro/flatpak-list.txt`).**

Add wanted Flatpak applications' names to this file, one per line. Make sure the names are the _actual_ names instead of a GUI-only alias (e.g. Firefox is actually called org.mozilla.firefox).

#### The `setup.sh` script does not:

1. Automatically apply all potentially desired system or application configurations (still need to manually apply most system/desktop environment/user application configurations).

#### The `setup.sh` script depends on:

1. The specific Linux distribution being accounted for in the script.
2. Various basic packages required for the correct functioning of the script.
3. Any fonts desired for installation being included uncompressed in the `fonts` directory.
4. If installing the Starship prompt, a Nerd Font installed and enabled in the terminal.
5. A text file containing a list of unwanted stock applications to uninstall for the specific distribution (`applications/example-distro/uninstall-list.txt`).
6. A text file containing a list of wanted native applications to install for use with the native package manager (`applications/example-distro/native-list.txt`).
7. A text file containing a list of wanted Flatpak applications to install from Flathub for the specific distribution (`applications/example-distro/flatpak-list.txt`).

### Fedora Workstation Usage Notes

#### firewalld and NetworkManager configuration:

The script currently assigns all connections to the restrictive `public` firewall zone by default. It then looks for a list of trusted connections (`configurations/fedora-workstation/trusted-connections-list.txt`) and assigns them to the `home` firewall zone instead, allowing access to some specified inbound services.

If those inbound services (specified in the script) are desired, make sure to create that file and include a list of trusted NetworkManager connection profile names there, one per line, prior to running the script.

The names of currently saved NetworkManager connection profiles can be found through running the following command in the terminal:

`nmcli connection show`
