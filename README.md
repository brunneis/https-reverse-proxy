# https-reverse-proxy
This project is packaged as a Docker image that will run a HAProxy reverse proxy with automated request and renewal of 
Let's Encrypt certificates. You only need to indicate your domains and endpoints in a simple YAML file.

## Usage
Clone this repository:
```
git clone https://github.com/brunneis/https-reverse-proxy
```

Edit the file `domains.yaml` with your domain names and endpoints. Each domain is represented with an object with a descriptive name for the key and two lists for the value: `domains` and `endpoints`. Add an item for each domain to the list `domains`. Add an endpoint with the structure `IP`:`PORT` for every listening endpoint to the list `endpoints`. The endpoints will be assigned following a Round-robin fashion.

```yaml
---
example1:
  domains:
    - example.com
    - www.example.com
  endpoints:
    - 10.0.0.10:10001
```

If your endpoint has SSL enabled, use the `ssl_endpoints` list instead of `endpoints`.
```yaml
---
example2:
  domains:
    - example.org
    - www.example.org
  ssl_endpoints:
    - 10.0.0.10:10002
```

Edit the file `env.sh` and change the value of the variable `LETSENCRYPT_EMAIL` to the email you want to be used for requesting the certificates.

Now, execute the `launch.sh` script. The script launches a Docker container. A `data` directory will be created containing the certificates once they are obtained. Every day, the container will renew the certificates if needed.
