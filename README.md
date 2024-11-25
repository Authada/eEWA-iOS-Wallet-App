# eEWA Wallet App for iOS

Based on EU reference implementation https://github.com/eu-digital-identity-wallet/eudi-app-ios-wallet-ui/commit/790b63df9c3e1e955f2fc14cbc96f852eb921b7d

AUTHADA eEWA Demo Issuer:
https://id.staging.authada.de/eudi/issuer/pid/

AUTHADA eEWA Demo Verifier:
https://id.staging.authada.de/eudi/verifier/

## Changelog:

Funke Stage 1
- new look & feel of the app
- removed / hide features that are not required by Funke stage 1
- support "on the fly" PID issuing in presentation PID flow
- support for authenticated channel
- support dpop for PID issuing
- support FaceID/TouchID
- support PID issuing process with external eID client
- support for wallet and app attestation
- support for SD-JWT PID presentations (EU reference implementation only supports mdoc)
- support for SD-JWT proxy (temporary) PID presentation (authenticated channel or signed credential)
- support for mdoc proxy (temporary) PID presentation (authenticated channel or signed credential)
- support for selective disclosure for PID issuing while presenting the PID
- support for selective disclosure for presenting SD-JWT PIDs

Funke Stage 2
- updated look & feel of the app
- support of handling the storage of different/multiple document formats (before only mdoc)
- support to issue/save/show/present/delete EAAs in SD-JWT format
- support for authentication flow for issuing EAAs in SD-JWT format
- support for pre-auth flow for issuing EAAs in SD-JWT and mdoc format
- support for multiple "on the fly" PID document formats:
   - eu.europa.ec.eudi.pid.1 (mdoc)
   - urn:eu.europa.ec.eudi:pid:1 (SD-JWT)
   - https://example.bmi.bund.de/credential/pid/1.0 (SD-JWT)
   - https://metadata-8c062a.usercontent.opencode.de/pid.json (SD-JWT)
- support to present multiple documents for the same document type
- support to present multiple EAAs for different document types and formats
- support to present multiple EAAs for different document types and formats including one "on the fly" PID
- support for EAA issuer authentication
- support for vct document filter in presentation flow
   - support for vct document filter for "on the fly" PID issuing
- support for issuing driver license (mdoc) and Verified Email (SD-JWT) directly from the app
