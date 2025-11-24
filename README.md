## PKI Management Tool
> A GUI tool to help create and manage a local and remote PKI for development purposes. Built with Fyne GUI framework in Golang.

```yaml
[ Server Certificate ] 
        │
        ▼
[ Intermediate CA Certificate ]
        │
        ▼
[ Root CA Certificate (trusted in OS/browser) ]
```

<br> <br> <br>

> **check out the file FYNE_CI_SETUP.md** if interested in lint workflows for fyne gui

<br> <br> <br>

## How to create one's root certificate authority
> ##### ONE DOES NOT SHARE THIS EVER

```bash
openssl genrsa -out rootCA.key 4096 
```

<p> A root certificate authority KEY should not be seen. This is to stay on one's machine, and it is to be used to sign one's intermediate certificates. </p> 

<br> <br> <br>

<p> Here is how one would self-sign their root certificate that they just created using OpenSSL: </p>

```bash
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 7300 -out rootCA.crt # -x509 = crt (instead of csr) , -nodes (or no DES) = key doesn't require pw (this is good for automation)
```
> 7300 days  ~= 20yrs

<p> One may then 'trust' their self-signed cert (.crt) by copying the key to the following places respective of OS: </p>
    

Linux: `rootCA.crt` -> `/usr/local/share/ca-certificates/` then update with `update-ca-certificates`

macOS: Import into `Keychain Access` -> `System Roots`

Windows: Import into `Trusted Root Certification Authorities`


## Creating an intermediate CA
> ##### Same keygen syntax for Root CA

```bash
openssl genrsa -out intermediateCA.key 4096
```

<p> The main difference here is that the root CA signs itself since it is the root CA hence 'trust-anchor'. However, the the intermediate CA does create a CSR, which is essentially a public key plus some info that it shall use to ask the root CA for a signature.  </p>

> ##### CSR creation

```bash
openssl req -new -key intermediateCA.key -out intermediateCA.csr # notice no x509 (x.509 is for crt)
```

> ##### Sign CSR with Root CA

```bash
openssl x509 -req -in intermediateCA.csr -CA rootCA.crt -CAkey rootCA.key \
  -CAcreateserial -out intermediateCA.crt -days 1825 -sha256 
```
<p> # CAcreateserial will create a handy serial # file that will help keep track of certs in general but they will be purposeful in this gui </p>


> ##### Verify (optional)

```bash
openssl verify -CAfile rootCA.crt intermediateCA.crt
```

## Creating Server/TLS key 

```bash
openssl genrsa -out server.key 2048 # STAYS ON SERVER
openssl req -new -key server.key -out server.csr # CSR
openssl x509 -req -in server.csr -CA intermediateCA.crt -CAkey intermediateCA.key \
  -CAcreateserial -out server.crt -days 365 -sha256 # CRT
```

> ##### Verify chain

```bash
openssl verify -CAfile rootCA.crt -untrusted intermediateCA.crt server.crt
```

> `-untrusted` simply allows server.crt to be chained to root


## create chains

```bash
cat intermediateCA.crt rootCA.crt > ca-chain.crt # mainly for verification
cat server.crt intermediateCA.crt > server-full.crt 
```
> **order matters**


<p> So, if presented correctly, the client should trust the root CA, and the root CA is imported once. As long as the intermediate is chained to your server cert in server-full.crt, which should be held on the server with the server key, then the client should be able to build that full chain of trust and, while doing the TLS handshake, successfully validate the server.  </p>
