FROM alfresco/alfresco-base-java:11

MAINTAINER "Angel Borroy" <angel.borroy@alfresco.com>

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.name="Alfresco Base SSL" \
    org.label-schema.vendor="Alfresco"

# Install openssl tool
RUN yum -y update && \
    yum -y install openssl openssl-devel && \
    yum clean all

# Copy OpenSSL configuration and generator script
COPY ["ssl-tool/openssl.cnf", "ssl-tool/run.sh", "./"]

# Allow script to be executed and make keytool program available in PATH
RUN chmod +x ./run.sh && \
    alternatives --install /usr/bin/keytool keytool /usr/java/default/bin/keytool 20000

# Default values for env variables
ENV ALFRESCO_VERSION=enterprise \
    KEY_SIZE=1024 \
    KEYSTORE_TYPE=JCEKS \
    TRUSTSTORE_TYPE=JCEKS \
    KEYSTORE_PASS=keystore \
    TRUSTSTORE_PASS=truststore \
    ENC_STORE_PASS=encryption \
    ENC_METADATA_PASS=metadata \
    CA_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco CA" \
    REPO_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco Repository" \
    SOLR_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Alfresco Repository Client" \
    BROWSER_CERT_DNAME="/C=GB/ST=UK/L=Maidenhead/O=Alfresco Software Ltd./OU=Unknown/CN=Custom Browser Client"

# Exposing working folders:
# - keystores folder, where generated keystores, truststores and password files are produced
# - ca is the OpenSSL CA folder, where CA internal files are produced
# - certificates folder, that includes private and public keys generated
VOLUME ["/keystores", "/ca", "/certificates"]

# Generating keystores, truststores and password files
CMD ["sh", "-c", "./run.sh \
-alfrescoversion $ALFRESCO_VERSION \
-keysize $KEY_SIZE \
-keystoretype $KEYSTORE_TYPE \
-truststoretype $TRUSTSTORE_TYPE \
-keystorepass $KEYSTORE_PASS \
-truststorepass $TRUSTSTORE_PASS \
-encstorepass $ENC_STORE_PASS \
-encmetadatapass $ENC_METADATA_PASS \
-cacertdname \"$CA_CERT_DNAME\" \
-repocertdname \"$REPO_CERT_DNAME\" \
-solrcertdname \"$SOLR_CERT_DNAME\" \
-browsercertdname \"$BROWSER_CERT_DNAME\" \
"]
