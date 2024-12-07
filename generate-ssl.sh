#!/bin/bash

# Generate root CA key
openssl genrsa -out ssl/ca.key 4096

# Generate root CA certificate
openssl req -x509 -new -nodes -key ssl/ca.key -sha256 -days 825 -out ssl/ca.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=PostgreSQL CA"

# Generate server key
openssl genrsa -out ssl/server.key 2048

# Create server CSR with the domain name
openssl req -new -key ssl/server.key -out ssl/server.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=nadiar.id"  # Use your domain here

# Add Subject Alternative Name (SAN)
cat > ssl/server.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = nadiar.id
DNS.2 = *.nadiar.id
DNS.3 = postgres
DNS.4 = localhost
IP.1 = 107.175.6.210
EOF

# Sign server certificate with CA including SAN
openssl x509 -req -in ssl/server.csr -CA ssl/ca.crt -CAkey ssl/ca.key \
  -CAcreateserial -out ssl/server.crt -days 825 -sha256 \
  -extfile ssl/server.ext

# Set proper permissions
chmod 600 ssl/server.key ssl/ca.key
chmod 644 ssl/server.crt ssl/ca.crt
