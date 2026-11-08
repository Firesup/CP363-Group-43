-- CP363 Assignment 4 | Group 43 - CrowdFunding DB | Normalized MySQL schema 
-- Abisan Vijayakaran, vija4552@mylaurier.ca
-- Richey Zhang, zhan3318@mylaurier.ca
CREATE DATABASE IF NOT EXISTS crowdfunding_a4
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE crowdfunding_a4;

CREATE TABLE IF NOT EXISTS `USER_ACCOUNT` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Email` varchar(50) NOT NULL,
  `PasswordHash` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `Country` varchar(2) NOT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `uq_user_account_email` (`Email`),
  CONSTRAINT `chk_user_account_country` CHECK ((char_length(`Country`) = 2))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `CREATOR` (
  `UserID` int NOT NULL,
  `DisplayName` varchar(60) NOT NULL,
  `Bio` varchar(1000) DEFAULT NULL,
  `VerificationStatus` enum('Pending','Verified','Rejected') NOT NULL DEFAULT 'Pending',
  `PayoutAccountToken` varchar(100) DEFAULT NULL,
  `VerifiedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `uq_creator_displayname` (`DisplayName`),
  UNIQUE KEY `uq_creator_payouttoken` (`PayoutAccountToken`),
  CONSTRAINT `fk_creator_user_account` FOREIGN KEY (`UserID`) REFERENCES `USER_ACCOUNT` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_creator_verifiedat` CHECK (((`VerificationStatus` <> _utf8mb4'Verified') or (`VerifiedAt` is not null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `POSTAL_CODE` (
  `PostalCode` varchar(10) NOT NULL,
  `City` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`PostalCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `BACKER` (
  `UserID` int NOT NULL,
  `ShippingStreet` varchar(100) DEFAULT NULL,
  `ShippingPostalCode` varchar(10) DEFAULT NULL,
  `DefaultCurrency` char(3) NOT NULL DEFAULT 'CAD',
  `PledgeAnonymously` tinyint(1) NOT NULL DEFAULT '0',
  `BackerSince` date NOT NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_backer_user_account` FOREIGN KEY (`UserID`) REFERENCES `USER_ACCOUNT` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_backer_postal_code` FOREIGN KEY (`ShippingPostalCode`)
    REFERENCES `POSTAL_CODE` (`PostalCode`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `CATEGORY` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `Slug` varchar(50) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT '1',
  `CreatedAt` date NOT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `uq_category_name` (`Name`),
  UNIQUE KEY `uq_category_slug` (`Slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `CAMPAIGN` (
  `CampaignID` int NOT NULL AUTO_INCREMENT,
  `CreatorID` int NOT NULL,
  `CategoryID` int NOT NULL,
  `Title` varchar(100) NOT NULL,
  `Description` text NOT NULL,
  `FundingGoal` decimal(12,2) NOT NULL,
  `Currency` char(3) NOT NULL,
  `StartDate` datetime NOT NULL,
  `EndDate` datetime NOT NULL,
  `Status` enum('Draft','Live','Successful','Failed','Cancelled','Suspended') NOT NULL DEFAULT 'Draft',
  PRIMARY KEY (`CampaignID`),
  KEY `fk_campaign_creator` (`CreatorID`),
  KEY `fk_campaign_category` (`CategoryID`),
  CONSTRAINT `fk_campaign_category` FOREIGN KEY (`CategoryID`) REFERENCES `CATEGORY` (`CategoryID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_campaign_creator` FOREIGN KEY (`CreatorID`) REFERENCES `CREATOR` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_campaign_dates` CHECK ((`EndDate` > `StartDate`)),
  CONSTRAINT `chk_campaign_goal` CHECK ((`FundingGoal` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `CAMPAIGN_MEDIA` (
  `CampaignID` int NOT NULL,
  `MediaURL` varchar(255) NOT NULL,
  PRIMARY KEY (`CampaignID`,`MediaURL`),
  CONSTRAINT `fk_campaign_media_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `CAMPAIGN_UPDATE` (
  `CampaignID` int NOT NULL,
  `UpdateNo` int NOT NULL,
  `Title` varchar(100) NOT NULL,
  `Body` text NOT NULL,
  `Visibility` enum('Public','BackersOnly') NOT NULL DEFAULT 'Public',
  `PostedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`CampaignID`,`UpdateNo`),
  CONSTRAINT `fk_campaign_update_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_campaign_update_no` CHECK ((`UpdateNo` >= 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `REWARD_TIER` (
  `TierID` int NOT NULL AUTO_INCREMENT,
  `CampaignID` int NOT NULL,
  `Title` varchar(80) NOT NULL,
  `Description` varchar(500) DEFAULT NULL,
  `MinPledgeAmount` decimal(10,2) NOT NULL,
  `QuantityLimit` int DEFAULT NULL,
  `EstimatedDelivery` date DEFAULT NULL,
  PRIMARY KEY (`TierID`),
  UNIQUE KEY `uq_reward_tier_title` (`CampaignID`,`Title`),
  CONSTRAINT `fk_reward_tier_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_reward_tier_min` CHECK ((`MinPledgeAmount` >= 1)),
  CONSTRAINT `chk_reward_tier_quantity` CHECK (((`QuantityLimit` is null) or (`QuantityLimit` > 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `PLEDGE` (
  `PledgeID` int NOT NULL AUTO_INCREMENT,
  `BackerID` int NOT NULL,
  `TierID` int NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `PledgedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Status` enum('Active','Cancelled','Collected','PaymentFailed','Refunded') NOT NULL DEFAULT 'Active',
  `IsAnonymous` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`PledgeID`),
  KEY `fk_pledge_backer` (`BackerID`),
  KEY `fk_pledge_tier` (`TierID`),
  CONSTRAINT `fk_pledge_backer` FOREIGN KEY (`BackerID`) REFERENCES `BACKER` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pledge_tier` FOREIGN KEY (`TierID`) REFERENCES `REWARD_TIER` (`TierID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_pledge_amount` CHECK ((`Amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `PAYMENT` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `PledgeID` int NOT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `Method` enum('Card','PayPal','BankTransfer') NOT NULL,
  `ProcessorTxnRef` varchar(64) NOT NULL,
  `Status` enum('Succeeded','Failed','Refunded') NOT NULL,
  `AttemptedAt` datetime NOT NULL,
  PRIMARY KEY (`PaymentID`),
  UNIQUE KEY `uq_payment_txnref` (`ProcessorTxnRef`),
  KEY `fk_payment_pledge` (`PledgeID`),
  CONSTRAINT `fk_payment_pledge` FOREIGN KEY (`PledgeID`) REFERENCES `PLEDGE` (`PledgeID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_payment_amount` CHECK ((`Amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `PAYOUT` (
  `PayoutID` int NOT NULL AUTO_INCREMENT,
  `CampaignID` int NOT NULL,
  `GrossAmount` decimal(12,2) NOT NULL,
  `PlatformFee` decimal(10,2) NOT NULL,
  `Status` enum('Scheduled','Sent','Failed') NOT NULL DEFAULT 'Scheduled',
  `PaidAt` datetime DEFAULT NULL,
  PRIMARY KEY (`PayoutID`),
  UNIQUE KEY `uq_payout_campaign` (`CampaignID`),
  CONSTRAINT `fk_payout_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_payout_fee` CHECK ((`PlatformFee` >= 0)),
  CONSTRAINT `chk_payout_gross` CHECK ((`GrossAmount` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `REPORT` (
  `ReportID` int NOT NULL AUTO_INCREMENT,
  `ReporterID` int NOT NULL,
  `CampaignID` int NOT NULL,
  `Reason` varchar(100) NOT NULL,
  `Details` varchar(1000) DEFAULT NULL,
  `RiskLevel` enum('Low','Medium','High','Critical') NOT NULL DEFAULT 'Low',
  `Status` enum('Open','UnderReview','Resolved','Dismissed') NOT NULL DEFAULT 'Open',
  `ReportedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ResolvedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`ReportID`),
  UNIQUE KEY `uq_report_once` (`ReporterID`,`CampaignID`),
  KEY `fk_report_campaign` (`CampaignID`),
  CONSTRAINT `fk_report_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_report_reporter` FOREIGN KEY (`ReporterID`) REFERENCES `USER_ACCOUNT` (`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_report_resolved` CHECK (((`ResolvedAt` is null) or (`ResolvedAt` >= `ReportedAt`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
