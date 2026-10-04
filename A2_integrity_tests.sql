-- =====================================================================
-- CP363 A2 - Referential integrity demo (run AFTER A2.sql)
-- Inserts a few sample rows, then each statement in PART 2 is EXPECTED
-- to FAIL - screenshot the error messages as proof the constraints work.
-- Run PART 2 statements one at a time (Ctrl+Enter on each line).
-- =====================================================================

-- PART 1: valid sample data
USE Crowdfunding_db;
INSERT INTO USER_ACCOUNT (Email,PasswordHash,FullName,Country) VALUES ('a@x.com','h','Ann','CA'),('b@x.com','h','Bob','US');
INSERT INTO CREATOR (UserID,DisplayName) VALUES (1,'AnnMakes');
INSERT INTO BACKER (UserID,BackerSince) VALUES (2,'2026-01-01');
INSERT INTO CATEGORY (Name,Slug,CreatedAt) VALUES ('Games','games','2026-01-01');
INSERT INTO CAMPAIGN (CreatorID,CategoryID,Title,Description,FundingGoal,Currency,StartDate,EndDate) VALUES (1,1,'Board Game','d',5000,'CAD','2026-10-01','2026-11-01');
INSERT INTO REWARD_TIER (CampaignID,Title,MinPledgeAmount) VALUES (1,'No Reward',1);
INSERT INTO PLEDGE (BackerID,TierID,Amount) VALUES (2,1,25);
INSERT INTO CAMPAIGN_UPDATE (CampaignID,UpdateNo,Title,Body) VALUES (1,1,'Hi','b');
SELECT * FROM v_campaign_amount_raised;

-- PART 2: each of these should be REJECTED by the database
-- FK: BackerID 99 does not exist in BACKER
INSERT INTO PLEDGE (BackerID, TierID, Amount) VALUES (99, 1, 10);
-- CHECK chk_campaign_dates: EndDate before StartDate
INSERT INTO CAMPAIGN (CreatorID, CategoryID, Title, Description, FundingGoal, Currency, StartDate, EndDate)
VALUES (1, 1, 'Bad Dates', 'd', 10, 'CAD', '2026-12-01', '2026-11-01');
-- CHECK chk_payout_net: 100 - 5 is not 90
INSERT INTO PAYOUT (CampaignID, GrossAmount, PlatformFee, NetAmount) VALUES (1, 100, 5, 90);
-- UNIQUE uq_user_account_email: duplicate email
INSERT INTO USER_ACCOUNT (Email, PasswordHash, FullName, Country) VALUES ('a@x.com', 'h', 'Z', 'CA');
-- RESTRICT: campaign still has pledges, so it cannot be deleted
DELETE FROM CAMPAIGN WHERE CampaignID = 1;
-- CHECK chk_creator_verifiedat: Verified requires a VerifiedAt date
UPDATE CREATOR SET VerificationStatus = 'Verified' WHERE UserID = 1;