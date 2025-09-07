# LinuxSetup

A personal repository containing all needed configuration files for any Linux distributions I have used previously or am currently using.

Feel free to take inspiration, reproduce my setup, or fork/clone and adjust it to your own needs :)

## Currently Supported Distributions

-   Fedora Workstation.

## Usage Notes

**The `setup.sh` script automates a large portion of the post-install setup process for various Linux distributions by:**

1. Installing fonts listed in the `fonts` directory.
2. Uninstalling a list of unwanted stock applications included with the specific distribution (`applications/example-distro/uninstall-list.txt`).
3. Adding any additional repositories needed for software installation for the specific distribution.
4. Installing any needed drivers for the specific distribution.
5. Installing a list of wanted native applications using the distribution's native package manager (`applications/example-distro/native-list.txt`).
6. Installing any wanted native applications using direct downloads for the specific distribution.
7. Applying system or application configurations which are able to be automated for the specific distribution.
8. Installing a list of wanted Flatpak applications from Flathub for the specific distribution (`applications/example-distro/flatpak-list.txt`).

**The `setup.sh` script does not:**

1. Automatically apply all potentially desired system or application configurations.

## Dependencies

1. The specific Linux distribution being accounted for in the script and having any other required external files available.
2. Various packages required for the installation of the native/Flatpak applications.
3. An external folder containing the configuration files for all desired fonts.
4. A text file containing a list of unwanted stock applications to uninstall for the specific distribution (`applications/example-distro/uninstall-list.txt`).
5. A text file containing a list of wanted native applications to install for use with the native package manager (`applications/example-distro/native-list.txt`).
6. A text file containing a list of wanted Flatpak applications to install from Flathub for the specific distribution (`applications/example-distro/flatpak-list.txt`).
