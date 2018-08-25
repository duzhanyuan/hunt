module hunt.security.cert.X509CRLEntry;

import hunt.security.cert.CRLReason;
import hunt.security.cert.X509Extension;
import hunt.security.x500.X500Principal;
import hunt.security.Principal;

import hunt.util.exception;

import std.datetime;
import std.bigint;

/**
 * <p>Abstract class for a revoked certificate in a CRL (Certificate
 * Revocation List).
 *
 * The ASN.1 definition for <em>revokedCertificates</em> is:
 * <pre>
 * revokedCertificates    SEQUENCE OF SEQUENCE  {
 *     userCertificate    CertificateSerialNumber,
 *     revocationDate     ChoiceOfTime,
 *     crlEntryExtensions Extensions OPTIONAL
 *                        -- if present, must be v2
 * }  OPTIONAL
 *
 * CertificateSerialNumber  ::=  INTEGER
 *
 * Extensions  ::=  SEQUENCE SIZE (1..MAX) OF Extension
 *
 * Extension  ::=  SEQUENCE  {
 *     extnId        OBJECT IDENTIFIER,
 *     critical      BOOLEAN DEFAULT FALSE,
 *     extnValue     OCTET STRING
 *                   -- contains a DER encoding of a value
 *                   -- of the type registered for use with
 *                   -- the extnId object identifier value
 * }
 * </pre>
 *
 * @see X509CRL
 * @see X509Extension
 *
 * @author Hemma Prafullchandra
 */

abstract class X509CRLEntry : X509Extension {

    /**
     * Compares this CRL entry for equality with the given
     * object. If the {@code other} object is an
     * {@code instanceof} {@code X509CRLEntry}, then
     * its encoded form (the inner SEQUENCE) is retrieved and compared
     * with the encoded form of this CRL entry.
     *
     * @param other the object to test for equality with this CRL entry.
     * @return true iff the encoded forms of the two CRL entries
     * match, false otherwise.
     */
    override bool opEquals(Object other) {
        if (this is other)
            return true;
        X509CRLEntry ot = cast(X509CRLEntry)other;
        if (ot is null)
            return false;
        try {
            byte[] thisCRLEntry = this.getEncoded();
            byte[] otherCRLEntry = ot.getEncoded();

            if (thisCRLEntry.length != otherCRLEntry.length)
                return false;
            for (size_t i = 0; i < thisCRLEntry.length; i++)
                 if (thisCRLEntry[i] != otherCRLEntry[i])
                     return false;
        } catch (CRLException ce) {
            return false;
        }
        return true;
    }

    /**
     * Returns a hashcode value for this CRL entry from its
     * encoded form.
     *
     * @return the hashcode value.
     */
    override size_t toHash() @trusted nothrow {
        size_t     retval = 0;
        try {
            byte[] entryData = this.getEncoded();
            for (size_t i = 1; i < entryData.length; i++)
                 retval += entryData[i] * i;

        } catch (CRLException ce) {
            return(retval);
        }
        return(retval);
    }

    /**
     * Returns the ASN.1 DER-encoded form of this CRL Entry,
     * that is the inner SEQUENCE.
     *
     * @return the encoded form of this certificate
     * @exception CRLException if an encoding error occurs.
     */
    abstract byte[] getEncoded() nothrow;

    /**
     * Gets the serial number from this X509CRLEntry,
     * the <em>userCertificate</em>.
     *
     * @return the serial number.
     */
    abstract BigInt getSerialNumber();

    /**
     * Get the issuer of the X509Certificate described by this entry. If
     * the certificate issuer is also the CRL issuer, this method returns
     * null.
     *
     * <p>This method is used with indirect CRLs. The default implementation
     * always returns null. Subclasses that wish to support indirect CRLs
     * should override it.
     *
     * @return the issuer of the X509Certificate described by this entry
     * or null if it is issued by the CRL issuer.
     *
     * @since 1.5
     */
    X500Principal getCertificateIssuer() {
        return null;
    }

    /**
     * Gets the revocation date from this X509CRLEntry,
     * the <em>revocationDate</em>.
     *
     * @return the revocation date.
     */
    abstract Date getRevocationDate();

    /**
     * Returns true if this CRL entry has extensions.
     *
     * @return true if this entry has extensions, false otherwise.
     */
    abstract bool hasExtensions();

    /**
     * Returns a string representation of this CRL entry.
     *
     * @return a string representation of this CRL entry.
     */
    override abstract string toString();

    /**
     * Returns the reason the certificate has been revoked, as specified
     * in the Reason Code extension of this CRL entry.
     *
     * @return the reason the certificate has been revoked, or
     *    {@code null} if this CRL entry does not have
     *    a Reason Code extension
     * @since 1.7
     */
    CRLReason getRevocationReason() {
        if (!hasExtensions()) {
            return CRLReason.UNSPECIFIED;
        }
        // return X509CRLEntryImpl.getRevocationReason(this);
        implementationMissing();
        return CRLReason.UNSPECIFIED;
    }
}