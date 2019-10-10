# Docker image for Moloch Wise

See https://github.com/aol/moloch/wiki/WISE for info on Moloch Wise.

This repo builds a standalone (without the Moloch stuff) docker image for it.

## Building the image

Just run:

```$ ./build.sh```

Or alternatively, if the script fails to detect moloch version number:

```$ ./build.sh latest```

## Usage

To run the image using the default example configuration file:

```
$ docker run -p 31001:8001 --rm --name moloch-wise moloch-wise
```

Once the container is up, you can verify that Wise is running correctly by performing a test threat intel query against IP 127.0.0.1:

```
$ curl localhost:31001/ip/127.0.0.1

[{field: "match", len: 12, value: "127.0.0.1/8"},
{field: "description", len: 38, value: "blacklisted localhost -- testing only"},
{field: "tags", len: 8, value: "testing"}]

```
The above result comes from a test Wise plugin generated inside the `Dockerfile`.

To actually use the image in a real environment, prepare a custom ```wise.ini``` config file (consult [Wise documentation](https://github.com/aol/moloch/wiki/WISE) on how to do so), and mount it like this to override the content of the default ```wise.ini``` file:

```
$ docker run -p 31001:8001 --rm --name moloch-wise \
   --mount type=bind,source=/path/to/your/custom/wise.ini,target=/wiseService/etc/wise.ini \
   moloch-wise 
```

## Troubleshooting

Use ```docker logs``` to examine Wise console output, or just get inside the container with:

```
$ docker exec -it moloch-wise sh
```
