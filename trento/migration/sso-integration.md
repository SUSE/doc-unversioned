# Integrating Single Sign-On

Trento can be integrated with an identity provider (IDP) that uses different Single sign-on (SSO) protocols like OpenID Connect (OIDC) and Open Authorization 2.0 (OAuth 2).

```{=docbook}
<note>
  <para>Trento cannot start with multiple SSO options together, so only one can be chosen.</para>
</note>
```

Available protocols are:

- OpenID Connect (OIDC)

- Open Authorization 2.0 (OAuth 2)

- Security Assertion Markup Language (SAML)

## User Roles and Authentication

User authentication is entirely managed by the IDP, which is responsible for maintaining user accounts.
A user, who does not exist on the IDP, is unable to access the Trento web console.

During the installation process, a default admin user is defined using the `ADMIN_USER` variable, which defaults to `admin`. If the authenticated user’s IDP username matches this admin user's username, that user is automatically granted `all:all` permissions within Trento.

User permissions are entirely managed by Trento, they are not imported from the IDP. The abilities must be granted by some user with `all:all` or `all:users` abilities (admin user initially). This means that only basic user information is retrieved from the external IDP.


## Using OpenID Connect

Trento integrates with an IDP that uses the OIDC protocol to authenticate users accessing the Trento web console.

By default, OIDC is disabled. You can enable OIDC when using RPM packages or using Docker images.


### Enabling OpenID Connect when using RPM packages

To enable OIDC when using RPM packages, proceed as follows:

1. Open the file <filename>/etc/trento/trento-web</filename>.
1. Add the following environment variables to this file.
   Required variables are:

   ```
   ENABLE_OIDC=true
   OIDC_CLIENT_ID=<OIDC_CLIENT_ID>
   OIDC_CLIENT_SECRET=<OIDC_CLIENT_SECRET>
   OIDC_BASE_URL=<OIDC_BASE_URL>
   ```

1. Optionally, add the OIDC callback URL to the configuration. This can be useful if for some reason the default callback URL cannot be used, for example, if `http` is used instead of `https`. Use the next variable for that:

    ```
    OIDC_CALLBACK_URL=<OIDC_CALLBACK_URL>
    ```

1. Restart the application.


### Enabling OpenID Connect when using Docker images

To enable OIDC when using Docker images, proceed as follows:

1. Provide the following environment variables to the Docker container via
   the `-e` option:

   ```bash
   docker run -d \
   -p 4000:4000 \
   --name trento-web \
   --network trento-net \
   --add-host "host.docker.internal:host-gateway" \

   ...[other settings]...

   # Required:
   -e ENABLE_OIDC=true \
   -e OIDC_CLIENT_ID=<OIDC_CLIENT_ID> \
   -e OIDC_CLIENT_SECRET=<OIDC_CLIENT_SECRET> \
   -e OIDC_BASE_URL=<OIDC_BASE_URL> \

   # Optional:
   -e OIDC_CALLBACK_URL=<OIDC_CALLBACK_URL> \

   ...[other settings]...
   ```

1. Restart the application.


### Available variables for OpenID Connect

OIDC_CLIENT_ID

: OIDC client id

OIDC_CLIENT_SECRET

: OIDC client secret

OIDC_BASE_URL

: OIDC base url

OIDC_CALLBACK_URL

: OIDC callback url where the IDP is redirecting once the authentication is completed (default value: <uri>https://#{TRENTO_WEB_ORIGIN}/auth/oidc_callback</uri>)

## Using OAuth 2.0

Trento integrates with an IDP that uses the OAuth 2 protocol to authenticate users accessing the Trento web console.

By default, OAuth 2.0 is disabled. You can enable OIDC when using RPM packages or using Docker images.


### Enabling OAuth 2.0 when using RPM packages

To enable OAuth 2.0 when using RPM packages, proceed as follows:

1. Open the file <filename>/etc/trento/trento-web</filename>.
1. Add the following environment variables to this file.
   Required variables are:

   ```
   # Required:
   ENABLE_OAUTH2=true
   OAUTH2_CLIENT_ID=<OAUTH2_CLIENT_ID>
   OAUTH2_CLIENT_SECRET=<OAUTH2_CLIENT_SECRET>
   OAUTH2_BASE_URL=<OAUTH2_BASE_URL>
   OAUTH2_AUTHORIZE_URL=<OAUTH2_AUTHORIZE_URL>
   OAUTH2_TOKEN_URL=<OAUTH2_TOKEN_URL>
   OAUTH2_USER_URL=<OAUTH2_USER_URL>

   # Optional:
   OAUTH2_SCOPES=<OAUTH2_SCOPES>
   OAUTH2_CALLBACK_URL=<OAUTH2_CALLBACK_URL>
   ```

1. Restart the application.



### Enabling OAuth 2.0 when using Docker images

To enable OAuth 2.0 when using Docker images, proceed as follows:

1. Use the following environment variables to the Docker container via
   the `-e` option:

   ```bash
   docker run -d \
   -p 4000:4000 \
   --name trento-web \
   --network trento-net \
   --add-host "host.docker.internal:host-gateway" \

   ...[other settings]...

   -e ENABLE_OAUTH2=true \
   -e OAUTH2_CLIENT_ID=<OAUTH2_CLIENT_ID> \
   -e OAUTH2_CLIENT_SECRET=<OAUTH2_CLIENT_SECRET> \
   -e OAUTH2_BASE_URL=<OAUTH2_BASE_URL> \
   -e OAUTH2_AUTHORIZE_URL=<OAUTH2_AUTHORIZE_URL> \
   -e OAUTH2_TOKEN_URL=<OAUTH2_TOKEN_URL> \
   -e OAUTH2_USER_URL=<OAUTH2_USER_URL> \

   # Optional:
   -e OAUTH2_SCOPES=<OAUTH2_SCOPES> \
   -e OAUTH2_CALLBACK_URL=<OAUTH2_CALLBACK_URL> \

   ...[other settings]...
   ```

### Available variables for OAuth 2.0

OAUTH2_CLIENT_ID

: OAUTH2 client id

OAUTH2_CLIENT_SECRET

: OAUTH2 client secret

OAUTH2_BASE_URL

: OAUTH2 base url

OAUTH2_AUTHORIZE_URL

: OAUTH2 authorization url

OAUTH2_TOKEN_URL

: OAUTH2 token url

OAUTH2_USER_URL

: OAUTH2 token url

OAUTH2_SCOPES

: OAUTH2 scopes, used to define the user values sent to the SP. It must be adjusted depending on IDP provider requirements (default value: `openid profile email`)

OAUTH2_CALLBACK_URL

: OAUTH2 callback url where the IDP is redirecting once the authentication is completed (default value: `https://#{TRENTO_WEB_ORIGIN}/auth/oauth2_callback`)


## Using SAML

Trento integrates with an IDP that uses the SAML protocol to authenticate users accessing the Trento web console. Trento will behave as a Service Provider (SP) in this case.

Commonly, SAML protocol messages are signed with SSL. This is optional using Trento, and the signing is not required (even though it is recommended).
If the IDP signs the messages, and expect signed messages back, certificates used by the SP (Trento in this case) must be provided to the IDP, the public certificate file in this case.

To use an existing SAML IDP, follow the next instrunctions to met the specific requirements. You need:

* Configure SAML IDP and user profiles
* Start Trento to generate the certificates and download them
* Provide the generated certificate to the IDP
* Restart Trento

### Configuring SAML IDP setup

Configure the existing IDP with the next minimum options to be able to connect with Trento's Service Provider (SP).

#### SAML user profile

Users provided by the SAML installation must have some few mandatory attributes to login in Trento. All of them are mandatory, even though their name is configurable.
The user profile must include attributes for: username, email, first name and last name.
This attributes must be mapped for all users wanting to connect to Trento.

By default, Trento expects the `username`, `email`, `firstName` and `lastName` attribute names. All these 4 attribute names are configurable using the next environment variables, following the same order: `SAML_USERNAME_ATTR_NAME`, `SAML_EMAIL_ATTR_NAME`, `SAML_FIRSTNAME_ATTR_NAME` and `SAML_LASTNAME_ATTR_NAME`.
So for example, if the IDP user profile username is defined as `attr:username`, `SAML_USERNAME_ATTR_NAME=attr:username` should be used.

#### SAML redirect URI

Once the login is done succesfully, the IDP redirects the session back to Trento. This redirection is done to `https://trento.example.com/sso/sp/consume/saml`, so this URI must be set as valid in the IDP.

### Get certificates from Trento

Trento provides a certificates set created during the installation. When Trento is installed the first time (does not matter the installation mode) the certificates are created, and the public certificate file content is available in the <uri>http://localhost:4000/api/public_keys</uri> route. 

Use the following command to download the certificate:

```bash
curl http://localhost:4000/api/public_keys
```
    
Copy the content of the certificate from there, and provide it to the IDP. This way, the IDP will sign and verify the messages sent by both ends.

### Restart Trento

Once the certificate is provided to the IDP, the IDP recreates its own <filename>metadata.xml</filename> file. This file defines which certificate is used to sign the messages by both sides. At this point, Trento Web must be restarted to use the new <filename>metadata.xml</filename> content.

If the <option>SAML_METDATA_CONTENT</option> option is being used, the content of this variable must be updated with the new metadata. In the other hand, if <option>SAML_METADATA_URL</option> is used, the new metadata is automatically fetched. If neither of these steps are completed, communication will fail because the message signatures will not be recognized

```{=docbook}
<note>
  <para>This restart must be done manually, by the admin.</para>
</note>
```

Follow the next instrucionts to restart with the configured options:

1. Open the file <filename>/etc/trento/trento-web</filename>.
1. Add the following environment variables to this file.
   Required variables are:

   ```
   # Other SAML options
   SAML_METADATA_URL=<SAML_METADATA_URL>
   # Or
   SAML_METDATA_CONTENT=<SAML_METADATA_CONTENT>
   ```

1. Restart the application.


### Enabling SAML when using RPM packages

To enable SAML when using RPM packages, proceed as follows:

1. Open the file <filename>/etc/trento/trento-web</filename>.
1. Add the following environment variables to this file.
   Required variables are:

```
# Required:
ENABLE_SAML=true
SAML_IDP_ID=<SAML_IDP_ID>
SAML_SP_ID=<SAML_SP_ID>
# Only SAML_METADATA_URL or SAML_METADATA_CONTENT must by provided
SAML_METADATA_URL=<SAML_METADATA_URL>
SAML_METADATA_CONTENT=<SAML_METADATA_CONTENT>

# Optional:
SAML_IDP_NAMEID_FORMAT=<SAML_IDP_NAMEID_FORMAT>
SAML_SP_DIR=<SAML_SP_DIR>
SAML_SP_ENTITY_ID=<SAML_SP_ENTITY_ID>
SAML_SP_CONTACT_NAME=<SAML_SP_CONTACT_NAME>
SAML_SP_CONTACT_EMAIL=<SAML_SP_CONTACT_EMAIL>
SAML_SP_ORG_NAME=<SAML_SP_ORG_NAME>
SAML_SP_ORG_DISPLAYNAME=<SAML_SP_ORG_DISPLAYNAME>
SAML_SP_ORG_URL=<SAML_SP_ORG_URL>
SAML_USERNAME_ATTR_NAME=<SAML_USERNAME_ATTR_NAME>
SAML_EMAIL_ATTR_NAME=<SAML_EMAIL_ATTR_NAME>
SAML_FIRSTNAME_ATTR_NAME=<SAML_FIRSTNAME_ATTR_NAME>
SAML_LASTNAME_ATTR_NAME=<SAML_LASTNAME_ATTR_NAME>
SAML_SIGN_REQUESTS=<SAML_SIGN_REQUESTS>
SAML_SIGN_METADATA=<SAML_SIGN_METADATA>
SAML_SIGNED_ASSERTION=<SAML_SIGNED_ASSERTION>
SAML_SIGNED_ENVELOPES=<SAML_SIGNED_ENVELOPES>
```

1. Restart the application.

### Enabling SAML when using Docker images

To enable SAML when using Docker images, proceed as follows:

1. Use the following environment variables to the Docker container via the `-e` option:

```bash
docker run -d \
-p 4000:4000 \
--name trento-web \
--network trento-net \
--add-host "host.docker.internal:host-gateway" \

...[other settings]...

-e ENABLE_SAML=true
-e SAML_IDP_ID=<SAML_IDP_ID> \
-e SAML_SP_ID=<SAML_SP_ID> \
# Only SAML_METADATA_URL or SAML_METADATA_CONTENT must by provided
-e SAML_METADATA_URL=<SAML_METADATA_URL> \
-e SAML_METADATA_CONTENT=<SAML_METADATA_CONTENT> \

# Optional:
-e SAML_IDP_NAMEID_FORMAT=<SAML_IDP_NAMEID_FORMAT> \
-e SAML_SP_DIR=<SAML_SP_DIR> \
-e SAML_SP_ENTITY_ID=<SAML_SP_ENTITY_ID> \
-e SAML_SP_CONTACT_NAME=<SAML_SP_CONTACT_NAME> \
-e SAML_SP_CONTACT_EMAIL=<SAML_SP_CONTACT_EMAIL> \
-e SAML_SP_ORG_NAME=<SAML_SP_ORG_NAME> \
-e SAML_SP_ORG_DISPLAYNAME=<SAML_SP_ORG_DISPLAYNAME> \
-e SAML_SP_ORG_URL=<SAML_SP_ORG_URL> \
-e SAML_USERNAME_ATTR_NAME=<SAML_USERNAME_ATTR_NAME> \
-e SAML_EMAIL_ATTR_NAME=<SAML_EMAIL_ATTR_NAME> \
-e SAML_FIRSTNAME_ATTR_NAME=<SAML_FIRSTNAME_ATTR_NAME> \
-e SAML_LASTNAME_ATTR_NAME=<SAML_LASTNAME_ATTR_NAME> \
-e SAML_SIGN_REQUESTS=<SAML_SIGN_REQUESTS> \
-e SAML_SIGN_METADATA=<SAML_SIGN_METADATA> \
-e SAML_SIGNED_ASSERTION=<SAML_SIGNED_ASSERTION> \
-e SAML_SIGNED_ENVELOPES=<SAML_SIGNED_ENVELOPES> \

...[other settings]...
```

### Available variables for SAML

SAML_IDP_ID

: SAML IDP id

SAML_SP_ID

: SAML SP id

SAML_METADATA_URL

: URL to retrieve the SAML metadata xml file. One of `SAML_METADATA_URL` or `SAML_METADATA_CONTENT` is required

SAML_METADATA_CONTENT

: One line string containing the SAML metadata xml file content (`SAML_METADATA_URL` has precedence over this)

SAML_IDP_NAMEID_FORMAT

: SAML IDP name id format, used to interpret the attribute name. Whole urn string must be used (default value: `urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified`)

SAML_SP_DIR

: SAML SP directory, where SP specific required files (such as certificates and metadata file) are placed (default value: <filename>/etc/trento/trento-web/saml</filename>)

SAML_SP_ENTITY_ID

: SAML SP entity id. If it is not given, value from the metadata.xml file is used

SAML_SP_CONTACT_NAME

: SAML SP contact name (default value: `Trento SP Admin`)

SAML_SP_CONTACT_EMAIL

: SAML SP contact email (default value: `admin@trento.suse.com`) 

SAML_SP_ORG_NAME

: SAML SP organization name (default value: `Trento SP`)

SAML_SP_ORG_DISPLAYNAME

: SAML SP organization display name (default value: `SAML SP build with Trento`)

SAML_SP_ORG_URL

: SAML SP organization url (default value: `https://www.trento-project.io/`)

SAML_USERNAME_ATTR_NAME

: SAML user profile "username" attribute field name. This attribute must exist in the IDP user (default value: `username`)

SAML_EMAIL_ATTR_NAME

: SAML user profile "email" attribute field name. This attribute must exist in the IDP user (default value: `email`)

SAML_FIRSTNAME_ATTR_NAME

: SAML user profile "first name" attribute field name. This attribute must exist in the IDP user (default value: `firstName`)

SAML_LASTNAME_ATTR_NAME

: SAML user profile "last name" attribute field name. This attribute must exist in the IDP user (default value: `lastName`)

SAML_SIGN_REQUESTS

: Sign SAML requests in the SP side (default value: `true`)

SAML_SIGN_METADATA

: Sign SAML metadata documents in the SP side (default value: `true`)   

SAML_SIGNED_ASSERTION

: Require to receive SAML assertion signed from the IDP. Set to false if the IDP doesn't sign the assertion (default value: `true`)

SAML_SIGNED_ENVELOPES

: Require to receive SAML envelopes signed from the IDP. Set to false if the IDP doesn't sign the envelopes (default value: `true`)