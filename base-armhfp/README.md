# Sabayon base: a Docker Project #

Attention! It's under strong development

State: Alpha

The purpose of this project is to provide an image of Sabayon base.
It is just a gentoo stage3 + entropy

UPDATE: Images are also on Docker Hub [sabayon/base-armhfp](https://registry.hub.docker.com/u/sabayon/base-armhfp/) and the already squashed image, 
[sabayon/base-armhfp-squashed](https://registry.hub.docker.com/u/sabayon/base-armhfp-squashed/)

## First steps on docker

Ensure to have the daemon started and running:

    sudo systemctl start docker

## Building sabayon-base locally

    git clone https://github.com/mudler/docker-sabayon-base-armhfp.git docker-sabayon-base
    cd docker-sabayon-base
    sudo docker build -t sabayon/base-armhfp .

## Pulling sabayon-base from Docker Hub

    sudo docker pull sabayon/base-armhfp

## Converting the image from Docker to use it with [Molecules](https://github.com/Sabayon/molecules)

### Only with undocker, without squashing the layers

After pulling the docker image, install [undocker](https://github.com/larsks/undocker/) and then as root:

    docker save sabayon/base-armhfp:latest | undocker -i -o base sabayon/base-armhfp:latest

### Using [docker-squash](https://github.com/jwilder/docker-squash)
You can also squash the image with [docker-squash](https://github.com/jwilder/docker-squash) and then extract your layers.

    sudo docker save sabayon/base-armhfp:latest | sudo TMPDIR=/dev/shm docker-squash -t sabayon/base-armhfp:squashed > /your/prefered/path/base.tar

You can replace /dev/shm with your prefered tmpdir

### With undocker, but squashing the layers

The squash can also been accomplished creating a container from the image, exporting it and then importing it back.

    sudo docker run -t -i sabayon/base-armhfp:latest /bin/bash
    $ exit # You should drop in a shell, exit, you should see a container id, otherwise find it :
    sudo docker ps -l
    sudo docker export <CONTAINER ID> | docker import - sabayon/base-armhfp:squashed
    docker save sabayon/base-armhfp:squashed | undocker -i -o base sabayon/base-armhfp:squashed

Docker will loose the history revision and then you can estract the layer, using as base for chroot.

You now have the tree on the *base/* directory

If you are planning to use the resulting files as a chroot, don't forget to set a nameserver on resolv.conf file

    echo "nameserver 208.67.222.222" > base/etc/resolv.conf


## 2 tricks on crosscompiling/building from an alien architecture

### Enabling arm support

Copy ext/qemu-arm-static to /usr/bin/binfmt, then:

	echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-binfmt:' > /proc/sys/fs/binfmt_misc/register
	
On the stage3, qemu-arm is not exported by default:

	docker run -t -i -v /usr/bin/qemu-arm-binfmt:/usr/bin/qemu-arm-binfmt sabayon/gentoo-stage3-base-armhf uname -m

On the base it is
	
	docker run -t -i sabayon/base-armhf uname -m
