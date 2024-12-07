#!/bin/bash

# We'll use existing CA files (ca.crt and ca.key) to generate client certificates
# Create client key
openssl genrsa -out ssl/client.key 2048

# Create client certificate request
# Add more meaningful client identification
openssl req -new -key ssl/client.key -out ssl/client.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=client.nadiar.id"

# Create client certificate extensions file
cat > ssl/client.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = client.nadiar.id
DNS.2 = *.nadiar.id
DNS.3 = localhost
EOF

# Sign client certificate with our CA including extensions
openssl x509 -req \
  -in ssl/client.csr \
  -CA ssl/ca.crt \
  -CAkey ssl/ca.key \
  -CAcreateserial \
  -out ssl/client.crt \
  -days 825 \
  -sha256 \
  -extfile ssl/client.ext

# Set proper permissions
chmod 600 ssl/client.key
chmod 644 ssl/client.crt

echo "Client certificates generated and installed!"
echo "Certificates location: ssl/"
echo "  - Private key: ssl/client.key"
echo "  - Certificate: ssl/client.crt"
echo "  - CA Certificate: ssl/ca.crt"
