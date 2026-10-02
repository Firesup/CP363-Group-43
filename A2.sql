DROP TABLE IF EXISTS USER_ACCOUNT;
CREATE TABLE USER_ACCOUNT (
    UserID        INT          NOT NULL AUTO_INCREMENT,
    Email         VARCHAR(50)  NOT NULL,
    PasswordHash  VARCHAR(50)  NOT NULL,
    FullName      VARCHAR(50)  NOT NULL,
    Country       VARCHAR(2)   NOT NULL,

    CONSTRAINT pk_user_account          PRIMARY KEY (UserID),
    CONSTRAINT uq_user_account_email    UNIQUE (Email),
    CONSTRAINT chk_user_account_country CHECK (CHAR_LENGTH(Country) = 2)
) ENGINE = InnoDB;
DESCRIBE USER_ACCOUNT;
SHOW CREATE TABLE USER_ACCOUNT;

CREATE TABLE CREATOR (
    UserID              INT           NOT NULL,
    DisplayName         VARCHAR(60)   NOT NULL,
    Bio                 VARCHAR(1000) NULL,
    VerificationStatus  ENUM('Pending','Verified','Rejected')
                                      NOT NULL DEFAULT 'Pending',
    PayoutAccountToken  VARCHAR(100)  NULL,   -- processor token, no raw bank details
    VerifiedAt          DATETIME      NULL,   -- NULL until verified
 
    CONSTRAINT pk_creator              PRIMARY KEY (UserID),
    CONSTRAINT uq_creator_displayname  UNIQUE (DisplayName),
    CONSTRAINT uq_creator_payouttoken  UNIQUE (PayoutAccountToken),
    CONSTRAINT chk_creator_verifiedat  CHECK (VerificationStatus <> 'Verified'
                                              OR VerifiedAt IS NOT NULL),
    CONSTRAINT fk_creator_user_account FOREIGN KEY (UserID)
        REFERENCES USER_ACCOUNT (UserID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;
