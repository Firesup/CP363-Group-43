-- =====================================================================
-- CP363 Assignment 2 - Schema Design
-- Group 43: Abisan Vijayakaran (169044552), Richey Zhang (169093318)
-- Crowdfunding Platform - relational schema mapped from the A1 EER model
-- Target: MySQL 8.x (InnoDB, CHECK constraints enforced)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS crowdfunding;
USE crowdfunding;

-- ---------------------------------------------------------------------
-- Drop tables in reverse dependency order (children first) so the
-- script can be re-run from scratch without foreign key errors.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS REPORT;
DROP TABLE IF EXISTS CAMPAIGN_UPDATE;
DROP TABLE IF EXISTS PAYOUT;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS PLEDGE;
DROP TABLE IF EXISTS REWARD_TIER;
DROP TABLE IF EXISTS CAMPAIGN_MEDIA;
DROP TABLE IF EXISTS CAMPAIGN;
DROP TABLE IF EXISTS CATEGORY;
DROP TABLE IF EXISTS BACKER;
DROP TABLE IF EXISTS CREATOR;
DROP TABLE IF EXISTS USER_ACCOUNT;


-- =====================================================================
-- 1. USER_ACCOUNT  (superclass of CREATOR and BACKER)
-- =====================================================================
CREATE TABLE USER_ACCOUNT (
    UserID        INT          NOT NULL AUTO_INCREMENT,
    Email         VARCHAR(50)  NOT NULL,
    PasswordHash  VARCHAR(50)  NOT NULL,   -- hashed, never plain text
    FullName      VARCHAR(50)  NOT NULL,
    Country       VARCHAR(2)   NOT NULL,   -- ISO 2-letter code, e.g. 'CA'

    CONSTRAINT pk_user_account          PRIMARY KEY (UserID),
    CONSTRAINT uq_user_account_email    UNIQUE (Email),
    CONSTRAINT chk_user_account_country CHECK (CHAR_LENGTH(Country) = 2)
) ENGINE = InnoDB;


-- =====================================================================
-- 2. CREATOR  (subclass of USER_ACCOUNT - shares its primary key)
-- =====================================================================
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


-- =====================================================================
-- 3. BACKER  (subclass of USER_ACCOUNT - shares its primary key)
--    ShippingAddress is a composite attribute -> Street, City, PostalCode
-- =====================================================================
CREATE TABLE BACKER (
    UserID              INT          NOT NULL,
    ShippingStreet      VARCHAR(100) NULL,
    ShippingCity        VARCHAR(50)  NULL,
    ShippingPostalCode  VARCHAR(10)  NULL,
    DefaultCurrency     CHAR(3)      NOT NULL DEFAULT 'CAD',
    PledgeAnonymously   BOOLEAN      NOT NULL DEFAULT FALSE,
    BackerSince         DATE         NOT NULL,

    CONSTRAINT pk_backer              PRIMARY KEY (UserID),
    CONSTRAINT fk_backer_user_account FOREIGN KEY (UserID)
        REFERENCES USER_ACCOUNT (UserID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 4. CATEGORY
-- =====================================================================
CREATE TABLE CATEGORY (
    CategoryID   INT          NOT NULL AUTO_INCREMENT,
    Name         VARCHAR(50)  NOT NULL,
    Slug         VARCHAR(50)  NOT NULL,   -- URL-friendly, e.g. 'tabletop-games'
    Description  VARCHAR(255) NULL,
    IsActive     BOOLEAN      NOT NULL DEFAULT TRUE,
    CreatedAt    DATE         NOT NULL,

    CONSTRAINT pk_category      PRIMARY KEY (CategoryID),
    CONSTRAINT uq_category_name UNIQUE (Name),
    CONSTRAINT uq_category_slug UNIQUE (Slug)
) ENGINE = InnoDB;


-- =====================================================================
-- 5. CAMPAIGN
--    R1 CREATOR creates CAMPAIGN   (1:N) -> CreatorID FK
--    R2 CATEGORY classifies CAMPAIGN (1:N) -> CategoryID FK
--    AmountRaised is a derived attribute -> computed, not stored
--    (see view v_campaign_amount_raised at the end of the script)
-- =====================================================================
CREATE TABLE CAMPAIGN (
    CampaignID   INT            NOT NULL AUTO_INCREMENT,
    CreatorID    INT            NOT NULL,
    CategoryID   INT            NOT NULL,
    Title        VARCHAR(100)   NOT NULL,
    Description  TEXT           NOT NULL,
    FundingGoal  DECIMAL(12,2)  NOT NULL,
    Currency     CHAR(3)        NOT NULL,
    StartDate    DATETIME       NOT NULL,
    EndDate      DATETIME       NOT NULL,
    Status       ENUM('Draft','Live','Successful','Failed','Cancelled','Suspended')
                                NOT NULL DEFAULT 'Draft',

    CONSTRAINT pk_campaign             PRIMARY KEY (CampaignID),
    CONSTRAINT chk_campaign_goal       CHECK (FundingGoal > 0),
    CONSTRAINT chk_campaign_dates      CHECK (EndDate > StartDate),
    CONSTRAINT fk_campaign_creator     FOREIGN KEY (CreatorID)
        REFERENCES CREATOR (UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_campaign_category    FOREIGN KEY (CategoryID)
        REFERENCES CATEGORY (CategoryID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 6. CAMPAIGN_MEDIA  (multivalued attribute CAMPAIGN.{MediaURL})
--    One row per image/video URL; (CampaignID, MediaURL) is the key.
-- =====================================================================
CREATE TABLE CAMPAIGN_MEDIA (
    CampaignID  INT          NOT NULL,
    MediaURL    VARCHAR(255) NOT NULL,

    CONSTRAINT pk_campaign_media          PRIMARY KEY (CampaignID, MediaURL),
    CONSTRAINT fk_campaign_media_campaign FOREIGN KEY (CampaignID)
        REFERENCES CAMPAIGN (CampaignID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 7. REWARD_TIER
--    R3 CAMPAIGN offers REWARD_TIER (1:N) -> CampaignID FK
-- =====================================================================
CREATE TABLE REWARD_TIER (
    TierID             INT           NOT NULL AUTO_INCREMENT,
    CampaignID         INT           NOT NULL,
    Title              VARCHAR(80)   NOT NULL,
    Description        VARCHAR(500)  NULL,
    MinPledgeAmount    DECIMAL(10,2) NOT NULL,
    QuantityLimit      INT           NULL,     -- NULL = unlimited
    EstimatedDelivery  DATE          NULL,     -- NULL for the 'No Reward' tier

    CONSTRAINT pk_reward_tier             PRIMARY KEY (TierID),
    CONSTRAINT uq_reward_tier_title       UNIQUE (CampaignID, Title),
    CONSTRAINT chk_reward_tier_minpledge  CHECK (MinPledgeAmount >= 1),
    CONSTRAINT chk_reward_tier_quantity   CHECK (QuantityLimit IS NULL OR QuantityLimit > 0),
    CONSTRAINT fk_reward_tier_campaign    FOREIGN KEY (CampaignID)
        REFERENCES CAMPAIGN (CampaignID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 8. PLEDGE
--    R4 BACKER submits PLEDGE          (1:N) -> BackerID FK
--    R5 REWARD_TIER selected by PLEDGE (1:N) -> TierID FK
-- =====================================================================
CREATE TABLE PLEDGE (
    PledgeID     INT           NOT NULL AUTO_INCREMENT,
    BackerID     INT           NOT NULL,
    TierID       INT           NOT NULL,
    Amount       DECIMAL(10,2) NOT NULL,
    PledgedAt    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status       ENUM('Active','Cancelled','Collected','PaymentFailed','Refunded')
                               NOT NULL DEFAULT 'Active',
    IsAnonymous  BOOLEAN       NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_pledge         PRIMARY KEY (PledgeID),
    CONSTRAINT chk_pledge_amount CHECK (Amount > 0),
    CONSTRAINT fk_pledge_backer  FOREIGN KEY (BackerID)
        REFERENCES BACKER (UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pledge_tier    FOREIGN KEY (TierID)
        REFERENCES REWARD_TIER (TierID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 9. PAYMENT
--    R6 PLEDGE generates PAYMENT -> PledgeID FK.
--    Implemented as 1:N (PledgeID NOT unique) because Business Rule 5
--    allows several payment attempts per pledge (e.g. Failed, then
--    Succeeded). See "Changes from A1" in the documentation.
-- =====================================================================
CREATE TABLE PAYMENT (
    PaymentID        INT           NOT NULL AUTO_INCREMENT,
    PledgeID         INT           NOT NULL,
    Amount           DECIMAL(10,2) NOT NULL,
    Method           ENUM('Card','PayPal','BankTransfer') NOT NULL,
    ProcessorTxnRef  VARCHAR(64)   NOT NULL,
    Status           ENUM('Succeeded','Failed','Refunded') NOT NULL,
    AttemptedAt      DATETIME      NOT NULL,

    CONSTRAINT pk_payment          PRIMARY KEY (PaymentID),
    CONSTRAINT uq_payment_txnref   UNIQUE (ProcessorTxnRef),
    CONSTRAINT chk_payment_amount  CHECK (Amount > 0),
    CONSTRAINT fk_payment_pledge   FOREIGN KEY (PledgeID)
        REFERENCES PLEDGE (PledgeID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 10. PAYOUT
--     R8 CAMPAIGN settles via PAYOUT (1:1) -> CampaignID FK + UNIQUE
-- =====================================================================
CREATE TABLE PAYOUT (
    PayoutID     INT           NOT NULL AUTO_INCREMENT,
    CampaignID   INT           NOT NULL,
    GrossAmount  DECIMAL(12,2) NOT NULL,
    PlatformFee  DECIMAL(10,2) NOT NULL,
    NetAmount    DECIMAL(12,2) NOT NULL,
    Status       ENUM('Scheduled','Sent','Failed') NOT NULL DEFAULT 'Scheduled',
    PaidAt       DATETIME      NULL,           -- NULL until sent

    CONSTRAINT pk_payout           PRIMARY KEY (PayoutID),
    CONSTRAINT uq_payout_campaign  UNIQUE (CampaignID),          -- enforces 1:1
    CONSTRAINT chk_payout_gross    CHECK (GrossAmount >= 0),
    CONSTRAINT chk_payout_fee      CHECK (PlatformFee >= 0),
    CONSTRAINT chk_payout_net      CHECK (NetAmount = GrossAmount - PlatformFee),
    CONSTRAINT chk_payout_paidat   CHECK (Status <> 'Sent' OR PaidAt IS NOT NULL),
    CONSTRAINT fk_payout_campaign  FOREIGN KEY (CampaignID)
        REFERENCES CAMPAIGN (CampaignID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 11. CAMPAIGN_UPDATE  (weak entity, owner = CAMPAIGN)
--     R7 CAMPAIGN posts CAMPAIGN_UPDATE (identifying, 1:N)
--     Key = owner key + partial key -> (CampaignID, UpdateNo)
-- =====================================================================
CREATE TABLE CAMPAIGN_UPDATE (
    CampaignID  INT          NOT NULL,
    UpdateNo    INT          NOT NULL,          -- partial key: 1, 2, 3 ... per campaign
    Title       VARCHAR(100) NOT NULL,
    Body        TEXT         NOT NULL,
    Visibility  ENUM('Public','BackersOnly') NOT NULL DEFAULT 'Public',
    PostedAt    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_campaign_update           PRIMARY KEY (CampaignID, UpdateNo),
    CONSTRAINT chk_campaign_update_no       CHECK (UpdateNo >= 1),
    CONSTRAINT fk_campaign_update_campaign  FOREIGN KEY (CampaignID)
        REFERENCES CAMPAIGN (CampaignID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- 12. REPORT  (Governance)
--     R9  USER_ACCOUNT files REPORT     (1:N) -> ReporterID FK
--     R10 CAMPAIGN is flagged by REPORT (1:N) -> CampaignID FK
--     UNIQUE (ReporterID, CampaignID): a user reports a campaign once.
-- =====================================================================
CREATE TABLE REPORT (
    ReportID    INT           NOT NULL AUTO_INCREMENT,
    ReporterID  INT           NOT NULL,
    CampaignID  INT           NOT NULL,
    RiskLevel   ENUM('Low','Medium','High','Critical') NOT NULL DEFAULT 'Low',
    Reason      VARCHAR(100)  NOT NULL,
    Details     VARCHAR(1000) NULL,
    Status      ENUM('Open','UnderReview','Resolved','Dismissed') NOT NULL DEFAULT 'Open',
    ReportedAt  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ResolvedAt  DATETIME      NULL,             -- NULL until resolved

    CONSTRAINT pk_report                PRIMARY KEY (ReportID),
    CONSTRAINT uq_report_reporter_camp  UNIQUE (ReporterID, CampaignID),
    CONSTRAINT chk_report_resolved      CHECK (ResolvedAt IS NULL OR ResolvedAt >= ReportedAt),
    CONSTRAINT fk_report_reporter       FOREIGN KEY (ReporterID)
        REFERENCES USER_ACCOUNT (UserID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_report_campaign       FOREIGN KEY (CampaignID)
        REFERENCES CAMPAIGN (CampaignID)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- =====================================================================
-- Derived attribute CAMPAIGN./AmountRaised
-- Computed on demand from pledges so it can never go out of sync.
-- =====================================================================
CREATE OR REPLACE VIEW v_campaign_amount_raised AS
SELECT  c.CampaignID,
        c.Title,
        COALESCE(SUM(p.Amount), 0) AS AmountRaised
FROM    CAMPAIGN c
LEFT JOIN REWARD_TIER rt ON rt.CampaignID = c.CampaignID
LEFT JOIN PLEDGE p       ON p.TierID = rt.TierID
                        AND p.Status IN ('Active','Collected')
GROUP BY c.CampaignID, c.Title;


-- =====================================================================
-- Verification queries (use these for the Workbench screenshots)
-- =====================================================================
SHOW TABLES;

-- All PK / FK / UNIQUE / CHECK constraints in the schema
SELECT  TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM    information_schema.TABLE_CONSTRAINTS
WHERE   TABLE_SCHEMA = 'crowdfunding'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;

-- Every foreign key, what it references, and its ON DELETE / ON UPDATE rule
SELECT  k.TABLE_NAME, k.COLUMN_NAME, k.CONSTRAINT_NAME,
        k.REFERENCED_TABLE_NAME, k.REFERENCED_COLUMN_NAME,
        r.DELETE_RULE, r.UPDATE_RULE
FROM    information_schema.KEY_COLUMN_USAGE k
JOIN    information_schema.REFERENTIAL_CONSTRAINTS r
          ON r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA
         AND r.CONSTRAINT_NAME   = k.CONSTRAINT_NAME
WHERE   k.TABLE_SCHEMA = 'crowdfunding'
ORDER BY k.TABLE_NAME;