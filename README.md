## Desktop PKI Management Tool

<br> <br> <br>

> **check out the file FYNE_CI_SETUP.md** if interested lint check workflows for fyne gui

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
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 7300 -out rootCA.crt # -x509 = self-signed , -nodes (or no DES) = key doesn't require pw (this is good for automation)
```
> 7300 days  ~= 20yrs

<p> One may then 'trust' their self-signed cert (.crt) by copying the key to the following places respective of OS: </p>
    

Linux: `rootCA.crt` -> `/usr/local/share/ca-certificates/` then update with `update-ca-certificates`

macOS: Import into `Keychain Access` -> `System Roots`

Windows: Import into `Trusted Root Certification Authorities`


## Creating an intermediate CA
