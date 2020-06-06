# rust-rpi0-cross
[![Docker Build Status](https://img.shields.io/docker/cloud/build/mikaye/rust-rpi0-cross.svg)](https://hub.docker.com/r/mikaye/rust-rpi0-cross)
[![](https://images.microbadger.com/badges/image/mikaye/rust-rpi0-cross.svg)](https://microbadger.com/images/mikaye/rust-rpi0-cross "Get your own image badge on microbadger.com")

[Cross](https://github.com/rust-embedded/cross) docker image for RPi 1/RPi 0 rust development.

Beside default cross image, it contains :

- arm-unknown-linux-gnueabihf cross compiler for Raspberry Pi 1/Raspberry Pi Zero(W)
- [vc libraries](https://github.com/raspberrypi/firmware/tree/1.20190215/hardfp/opt/vc)
- `cross test` and `cross run` can optionally upload and run to target device

## How to use
In your `Cross.toml` (create it if needed) put :
```TOML
[target.arm-unknown-linux-gnueabihf]
image = "mikaye/rust-rpi0-cross"
```

Now you can do `cross test --target=arm-unknown-linux-gnueabihf` and it will build and run tests. Note that it is run locally with qemu. See next section for remote run.

### Remote run
To cross-build locally then run on the Pi itself add these lines to your `Cross.toml` :
```TOML
[target.arm-unknown-linux-gnueabihf.env]
passthrough = ["CROSS_REMOTE_HOST"]
```
Then put your connection in `CROSS_REMOTE_HOST` environment variable with the same format as you would in SSH command (`user@hostname:port`)
