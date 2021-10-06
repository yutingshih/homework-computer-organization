# Computer Organization

## Lab 1 - Environment Setup

Objective: setup the environment to compile RISC-V ISA using [RISC-V GNU toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) based on Ubuntu 20.04

### Build Image

At the root of the repository, build the docker image.

```shell
docker build -t tings0802/riscv-gnu-toolchain:0.1 .
```

This image is about 10.8 GB, and it may take more than an hour to build or pull.

### Run Container

Still at the root of the repository, type the command to startup the docker container with the image `tings0802/riscv-gnu-toolchain`.

```shell
docker run -it -v $(pwd)/lab1:/root/lab1 --rm --name lab1 tings0802/riscv-gnu-toolchain:0.1
```

The `-v` parameter mounts the `$(pwd)/lab1` directory on the host machine to the `/root/lab` directory in the container. It is required, or you cannot access the compiled files from the host machine after you exit the container. 

The `--rm` option reveals that the container will be deleted after exiting.

The `--name` parameter specifies the container a name, which must be unique if you have multiple containers.

### Compile Source Code

Inside the container, navigate into the `lab1` directory and compile the source files with [GNU Make](https://www.gnu.org/software/make/). The the build process is defined in `lab1/Makefile`.

```shell
cd lab1 && make
```

After the compilation, exit the container via the following command, and the container will be deleted.

```
exit
```
