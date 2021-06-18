# Docker image for Arkime Wise

See https://arkime.com/wise for info on Arkime Wise.

This repo builds a standalone (without the Arkime/Moloch stuff) docker image for it.

## Building the image

Just run:

```$ ./build.sh```

Or alternatively, if the script fails to detect moloch version number:

```$ ./build.sh latest```

## Usage

To run the image using the default example configuration file:

```
$ docker run -p 31001:8081 --rm --name arkime-wise arkime-wise
```

Once the container is up, you can access Wise web interface from http://localhost:31001.

You can verify that Wise is running correctly by performing a test threat intel query against IP 127.0.0.1:

```
$ curl localhost:31001/ip/127.0.0.1

[{field: "match", len: 12, value: "127.0.0.1/8"},
{field: "description", len: 38, value: "blacklisted localhost -- testing only"},
{field: "tags", len: 8, value: "testing"}]

```
The above result comes from a test Wise plugin generated inside the `Dockerfile`.

To actually use the image in a real environment, prepare a custom ```wise.ini``` config file (consult [Wise documentation](https://arkime.com/wise) on how to do so), and mount it like this to override the content of the default ```wise.ini``` file:

```
$ docker run -p 31001:8081 --rm --name arkime-wise \
   --mount type=bind,source=/path/to/your/custom/wise.ini,target=/wiseService/etc/wise.ini \
   arkime-wise 
```

## Troubleshooting

Use ```docker logs``` to examine Wise console output, or just get inside the container with:

```
$ docker exec -it moloch-wise sh
```
