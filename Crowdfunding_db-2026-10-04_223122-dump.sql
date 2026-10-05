-- MySQL dump 10.13  Distrib 26.7.0, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: Crowdfunding_db
-- ------------------------------------------------------
-- Server version	26.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'f064d86a-ba00-11f1-85ed-90f82df64a8f:1-69';

--
-- Table structure for table `BACKER`
--

DROP TABLE IF EXISTS `BACKER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `BACKER` (
  `UserID` int NOT NULL,
  `ShippingStreet` varchar(100) DEFAULT NULL,
  `ShippingCity` varchar(50) DEFAULT NULL,
  `ShippingPostalCode` varchar(10) DEFAULT NULL,
  `DefaultCurrency` char(3) NOT NULL DEFAULT 'CAD',
  `PledgeAnonymously` tinyint(1) NOT NULL DEFAULT '0',
  `BackerSince` date NOT NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_backer_user_account` FOREIGN KEY (`UserID`) REFERENCES `USER_ACCOUNT` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BACKER`
--

LOCK TABLES `BACKER` WRITE;
/*!40000 ALTER TABLE `BACKER` DISABLE KEYS */;
/*!40000 ALTER TABLE `BACKER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CAMPAIGN`
--

DROP TABLE IF EXISTS `CAMPAIGN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CAMPAIGN` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CAMPAIGN`
--

LOCK TABLES `CAMPAIGN` WRITE;
/*!40000 ALTER TABLE `CAMPAIGN` DISABLE KEYS */;
/*!40000 ALTER TABLE `CAMPAIGN` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CAMPAIGN_MEDIA`
--

DROP TABLE IF EXISTS `CAMPAIGN_MEDIA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CAMPAIGN_MEDIA` (
  `CampaignID` int NOT NULL,
  `MediaURL` varchar(255) NOT NULL,
  PRIMARY KEY (`CampaignID`,`MediaURL`),
  CONSTRAINT `fk_campaign_media_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CAMPAIGN_MEDIA`
--

LOCK TABLES `CAMPAIGN_MEDIA` WRITE;
/*!40000 ALTER TABLE `CAMPAIGN_MEDIA` DISABLE KEYS */;
/*!40000 ALTER TABLE `CAMPAIGN_MEDIA` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CAMPAIGN_UPDATE`
--

DROP TABLE IF EXISTS `CAMPAIGN_UPDATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CAMPAIGN_UPDATE` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CAMPAIGN_UPDATE`
--

LOCK TABLES `CAMPAIGN_UPDATE` WRITE;
/*!40000 ALTER TABLE `CAMPAIGN_UPDATE` DISABLE KEYS */;
/*!40000 ALTER TABLE `CAMPAIGN_UPDATE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CATEGORY`
--

DROP TABLE IF EXISTS `CATEGORY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CATEGORY` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `Slug` varchar(50) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT '1',
  `CreatedAt` date NOT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `uq_category_name` (`Name`),
  UNIQUE KEY `uq_category_slug` (`Slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CATEGORY`
--

LOCK TABLES `CATEGORY` WRITE;
/*!40000 ALTER TABLE `CATEGORY` DISABLE KEYS */;
/*!40000 ALTER TABLE `CATEGORY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CREATOR`
--

DROP TABLE IF EXISTS `CREATOR`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CREATOR` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CREATOR`
--

LOCK TABLES `CREATOR` WRITE;
/*!40000 ALTER TABLE `CREATOR` DISABLE KEYS */;
/*!40000 ALTER TABLE `CREATOR` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PAYMENT`
--

DROP TABLE IF EXISTS `PAYMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PAYMENT` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PAYMENT`
--

LOCK TABLES `PAYMENT` WRITE;
/*!40000 ALTER TABLE `PAYMENT` DISABLE KEYS */;
/*!40000 ALTER TABLE `PAYMENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PAYOUT`
--

DROP TABLE IF EXISTS `PAYOUT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PAYOUT` (
  `PayoutID` int NOT NULL AUTO_INCREMENT,
  `CampaignID` int NOT NULL,
  `GrossAmount` decimal(12,2) NOT NULL,
  `PlatformFee` decimal(10,2) NOT NULL,
  `NetAmount` decimal(12,2) NOT NULL,
  `Status` enum('Scheduled','Sent','Failed') NOT NULL DEFAULT 'Scheduled',
  `PaidAt` datetime DEFAULT NULL,
  PRIMARY KEY (`PayoutID`),
  UNIQUE KEY `uq_payout_campaign` (`CampaignID`),
  CONSTRAINT `fk_payout_campaign` FOREIGN KEY (`CampaignID`) REFERENCES `CAMPAIGN` (`CampaignID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_payout_fee` CHECK ((`PlatformFee` >= 0)),
  CONSTRAINT `chk_payout_gross` CHECK ((`GrossAmount` >= 0)),
  CONSTRAINT `chk_payout_net` CHECK ((`NetAmount` = (`GrossAmount` - `PlatformFee`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PAYOUT`
--

LOCK TABLES `PAYOUT` WRITE;
/*!40000 ALTER TABLE `PAYOUT` DISABLE KEYS */;
/*!40000 ALTER TABLE `PAYOUT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PLEDGE`
--

DROP TABLE IF EXISTS `PLEDGE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PLEDGE` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PLEDGE`
--

LOCK TABLES `PLEDGE` WRITE;
/*!40000 ALTER TABLE `PLEDGE` DISABLE KEYS */;
/*!40000 ALTER TABLE `PLEDGE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `REPORT`
--

DROP TABLE IF EXISTS `REPORT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `REPORT` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `REPORT`
--

LOCK TABLES `REPORT` WRITE;
/*!40000 ALTER TABLE `REPORT` DISABLE KEYS */;
/*!40000 ALTER TABLE `REPORT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `REWARD_TIER`
--

DROP TABLE IF EXISTS `REWARD_TIER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `REWARD_TIER` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `REWARD_TIER`
--

LOCK TABLES `REWARD_TIER` WRITE;
/*!40000 ALTER TABLE `REWARD_TIER` DISABLE KEYS */;
/*!40000 ALTER TABLE `REWARD_TIER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `USER_ACCOUNT`
--

DROP TABLE IF EXISTS `USER_ACCOUNT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `USER_ACCOUNT` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Email` varchar(50) NOT NULL,
  `PasswordHash` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `Country` varchar(2) NOT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `uq_user_account_email` (`Email`),
  CONSTRAINT `chk_user_account_country` CHECK ((char_length(`Country`) = 2))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `USER_ACCOUNT`
--

LOCK TABLES `USER_ACCOUNT` WRITE;
/*!40000 ALTER TABLE `USER_ACCOUNT` DISABLE KEYS */;
/*!40000 ALTER TABLE `USER_ACCOUNT` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-04 22:31:22
