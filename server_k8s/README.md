https://wiki.debian.org/ManipulatingISOs#Remaster_an_Installation_Image
https://wiki.debian.org/RepackBootableISO

https://wiki.debian.org/DebianInstaller/Preseed/EditIso

txt.cfg

Here's a breakdown of the 4 parts of a preseed configuration entry:

```
d-i debian-installer/locale string en_US.UTF-8
```

## 1. **Owner** (`d-i`)
- Specifies which package/component "owns" this configuration question
- Common owners:
  - `d-i` = debian-installer (core installer)
  - `netcfg` = network configuration
  - `partman-auto` = automatic partitioning
  - `grub-installer` = GRUB bootloader
  - `tasksel` = task selection
  - `user-setup-udeb` = user setup

## 2. **Question/Template** (`debian-installer/locale`)
- The specific configuration question being answered
- Format: `component/question-name`
- This identifies what setting you're configuring
- Example: `debian-installer/locale` = the locale setting for the installer

## Finding Valid Questions

To see all available questions for a component:
```bash
debconf-get-selections | grep component-name
```

Or during installation with debug enabled:
```bash
debconf-get-selections --installer
```
