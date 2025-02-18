FROM ubuntu:latest

RUN apt-get update && apt-get install -y gnupg2

RUN gpg --batch --generate-key <<EOF
    %no-protection
    Key-Type: RSA
    Key-Length: 4096
    Name-Real: Ubuntu GPG Key
    Name-Comment: GitHub Actions GPG Key
    Name-Email: ubuntu-gpg@example.com
    Expire-Date: 0
EOF

RUN gpg --armor --export ubuntu-gpg@example.com > /root/ubuntu-gpg-public.key

RUN cat /root/ubuntu-gpg-public.key

WORKDIR /workspace

CMD ["bash"]