# Sabayon ARM Images

## Supported Devices

  Hereinafter, list of supported devices:

    * Raspberry PI (only 32bit for now)
    * Bananapi (BPI-M1 and soon BPI-R1)
    * Odroid C2
    * Odroid X2-U2
    * Beaglebone

# Images Tree

```
gentoo-stage3
     |
     |
     +--> base-armhf ------> armhf  +---> generic-armhf
     |                              |
     |                              +---> builder-armhf
     |                              |
     |                              +---> distccd-armhf
     |                              |
     |                              +---> beaglebone-armhf
     |                              |
     |                              +---> odroid-c2-armhf
     |                              |
     |                              +---> odroid-x2-u2-armhf
     |                              |
     |                              +---> rpi-armhf ----> rpi-mc
     |                              |         |
     |                              |         \-----> rpi-mate-armhf
     |                              |
     |                              +---> udooneo-armhf
     |
     \
      \-> builder-scratch-armhf (image used for sabayon repository reboot)

```

