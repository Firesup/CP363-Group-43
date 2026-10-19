-- CP363 Assignment 3: database population script
-- All people, campaigns, and processor transaction references are fictional.
USE crowdfunding;
START TRANSACTION;

INSERT INTO USER_ACCOUNT (UserID, Email, PasswordHash, FullName, Country) VALUES
(1,'maya.chen@example.test','demo_hash_001','Maya Chen','CA'),
(2,'liam.patel@example.test','demo_hash_002','Liam Patel','CA'),
(3,'sofia.martin@example.test','demo_hash_003','Sofia Martin','US'),
(4,'noah.williams@example.test','demo_hash_004','Noah Williams','US'),
(5,'amelia.brown@example.test','demo_hash_005','Amelia Brown','GB'),
(6,'ethan.lee@example.test','demo_hash_006','Ethan Lee','CA'),
(7,'olivia.garcia@example.test','demo_hash_007','Olivia Garcia','US'),
(8,'lucas.wilson@example.test','demo_hash_008','Lucas Wilson','CA'),
(9,'ava.thompson@example.test','demo_hash_009','Ava Thompson','GB'),
(10,'mason.kim@example.test','demo_hash_010','Mason Kim','CA'),
(11,'isabella.rodriguez@example.test','demo_hash_011','Isabella Rodriguez','US'),
(12,'james.taylor@example.test','demo_hash_012','James Taylor','CA'),
(13,'charlotte.evans@example.test','demo_hash_013','Charlotte Evans','GB');

INSERT INTO CREATOR (UserID,DisplayName,Bio,VerificationStatus,PayoutAccountToken,VerifiedAt) VALUES
(1,'Northstar Studio','Toronto team building practical products.','Verified','tok_demo_001','2025-01-15 10:00:00'),
(2,'Patel Playworks','Independent tabletop game designers.','Verified','tok_demo_002','2025-02-20 12:30:00'),
(3,'GreenLoop Lab','Reusable and repairable products.','Verified','tok_demo_003','2025-03-11 09:15:00'),
(4,'BrightFrame Films','Independent documentary collective.','Pending',NULL,NULL),
(5,'SoundSprout Audio','Accessible audio tools for creators.','Verified','tok_demo_005','2025-04-07 14:00:00');

INSERT INTO BACKER (UserID,ShippingStreet,ShippingCity,ShippingPostalCode,DefaultCurrency,PledgeAnonymously,BackerSince) VALUES
(6,'120 King Street W','Toronto','M5H 1J9','CAD',FALSE,'2024-11-03'),
(7,'45 Market Street','San Francisco','94105','USD',FALSE,'2025-01-12'),
(8,'88 Queen Street','Waterloo','N2J 2W2','CAD',TRUE,'2025-02-01'),
(9,'16 Camden Road','London','NW1 9DP','GBP',FALSE,'2025-02-17'),
(10,'230 Bay Street','Toronto','M5J 2W4','CAD',FALSE,'2025-03-09'),
(11,'77 Pine Avenue','Seattle','98101','USD',TRUE,'2025-04-22'),
(12,'9 University Avenue','Ottawa','K1N 6N5','CAD',FALSE,'2025-06-05'),
(13,'31 Rose Lane','Bristol','BS1 4QA','GBP',FALSE,'2025-07-19');

INSERT INTO CATEGORY (CategoryID,Name,Slug,Description,IsActive,CreatedAt) VALUES
(1,'Technology','technology','Devices and practical inventions.',TRUE,'2024-01-01'),
(2,'Games','games','Board and tabletop games.',TRUE,'2024-01-01'),
(3,'Environment','environment','Sustainability-focused projects.',TRUE,'2024-01-01'),
(4,'Film','film','Independent film projects.',TRUE,'2024-01-01'),
(5,'Music','music','Music and audio equipment.',TRUE,'2024-01-01'),
(6,'Design','design','Product and industrial design.',TRUE,'2024-01-01');

INSERT INTO CAMPAIGN (CampaignID,CreatorID,CategoryID,Title,Description,FundingGoal,Currency,StartDate,EndDate,Status) VALUES
(1,1,1,'Orbit Desk Charger','A compact multi-device charger with replaceable cables.',12000.00,'CAD','2025-01-10 09:00:00','2025-03-10 23:59:59','Successful'),
(2,2,2,'Lanterns of Eldergrove','A cooperative tabletop adventure with modular maps.',8000.00,'CAD','2026-09-15 09:00:00','2026-11-15 23:59:59','Live'),
(3,3,3,'LoopCup Reusable Kit','Reusable cups with replaceable seals.',15000.00,'USD','2025-04-01 09:00:00','2025-05-31 23:59:59','Failed'),
(4,5,5,'SproutCast Mini Mixer','Portable mixer for podcasts and home studios.',10000.00,'CAD','2025-06-01 09:00:00','2025-08-01 23:59:59','Successful'),
(5,1,6,'Modular Everyday Backpack','Weather-resistant backpack with replaceable panels.',9000.00,'CAD','2026-08-20 09:00:00','2026-10-30 23:59:59','Live'),
(6,4,4,'The Last Streetcar','A short documentary about neighbourhood history.',6000.00,'USD','2025-07-01 09:00:00','2025-08-15 23:59:59','Cancelled');

INSERT INTO CAMPAIGN_MEDIA (CampaignID,MediaURL) VALUES
(1,'https://example.test/media/orbit-charger.jpg'),
(1,'https://example.test/media/orbit-demo.mp4'),
(2,'https://example.test/media/eldergrove-box.jpg'),
(2,'https://example.test/media/eldergrove-map.jpg'),
(3,'https://example.test/media/loopcup-kit.jpg'),
(4,'https://example.test/media/sproutcast-mixer.jpg'),
(5,'https://example.test/media/modular-backpack.jpg'),
(6,'https://example.test/media/last-streetcar-poster.jpg');

INSERT INTO REWARD_TIER (TierID,CampaignID,Title,Description,MinPledgeAmount,QuantityLimit,EstimatedDelivery) VALUES
(1,1,'Supporter','Thank-you email and updates.',15.00,NULL,NULL),
(2,1,'Early Charger','One Orbit Desk Charger.',65.00,200,'2025-06-15'),
(3,1,'Studio Bundle','Two chargers and cable set.',115.00,75,'2025-06-15'),
(4,2,'Digital Adventurer','Digital rulebook and maps.',20.00,NULL,'2026-12-01'),
(5,2,'Base Game','One boxed tabletop game.',55.00,500,'2027-02-01'),
(6,2,'Game Night Pack','Game plus two expansions.',90.00,150,'2027-02-01'),
(7,3,'Cup Backer','One reusable cup.',25.00,NULL,'2025-08-01'),
(8,3,'Household Kit','Four cups and spare seals.',80.00,100,'2025-08-01'),
(9,4,'Digital Thanks','Behind-the-scenes digital package.',20.00,NULL,'2025-09-01'),
(10,4,'Creator Mixer','One portable audio mixer.',125.00,120,'2025-10-01'),
(11,5,'Trail Supporter','Updates and packing guide.',10.00,NULL,NULL),
(12,5,'Modular Pack','One modular backpack.',95.00,250,'2027-01-15'),
(13,6,'Film Friend','Digital programme credit.',15.00,NULL,NULL);

INSERT INTO PLEDGE (PledgeID,BackerID,TierID,Amount,PledgedAt,Status,IsAnonymous) VALUES
(1,6,2,65.00,'2025-01-12 10:20:00','Collected',FALSE),
(2,7,3,115.00,'2025-01-15 13:45:00','Collected',FALSE),
(3,8,1,25.00,'2025-02-02 18:10:00','Collected',TRUE),
(4,9,2,65.00,'2025-02-10 09:30:00','Collected',FALSE),
(5,10,5,55.00,'2026-09-18 11:00:00','Active',FALSE),
(6,11,6,90.00,'2026-09-20 16:20:00','Active',TRUE),
(7,12,4,20.00,'2026-09-25 08:15:00','Active',FALSE),
(8,13,5,55.00,'2026-10-01 19:40:00','Active',FALSE),
(9,6,7,25.00,'2025-04-05 14:00:00','PaymentFailed',FALSE),
(10,7,8,80.00,'2025-04-10 17:25:00','Cancelled',FALSE),
(11,8,10,125.00,'2025-06-10 10:00:00','Collected',TRUE),
(12,9,9,30.00,'2025-06-15 12:00:00','Collected',FALSE),
(13,10,12,95.00,'2026-08-25 09:10:00','Active',FALSE),
(14,11,11,15.00,'2026-09-01 21:00:00','Active',TRUE),
(15,12,13,20.00,'2025-07-05 15:30:00','Cancelled',FALSE);

INSERT INTO PAYMENT (PaymentID,PledgeID,Amount,Method,ProcessorTxnRef,Status,AttemptedAt) VALUES
(1,1,65.00,'Card','demo_txn_0001','Succeeded','2025-01-12 10:21:00'),
(2,2,115.00,'PayPal','demo_txn_0002','Succeeded','2025-01-15 13:46:00'),
(3,3,25.00,'Card','demo_txn_0003','Succeeded','2025-02-02 18:11:00'),
(4,4,65.00,'BankTransfer','demo_txn_0004','Succeeded','2025-02-10 09:31:00'),
(5,5,55.00,'Card','demo_txn_0005','Succeeded','2026-09-18 11:01:00'),
(6,6,90.00,'PayPal','demo_txn_0006','Succeeded','2026-09-20 16:21:00'),
(7,7,20.00,'Card','demo_txn_0007','Succeeded','2026-09-25 08:16:00'),
(8,8,55.00,'Card','demo_txn_0008','Succeeded','2026-10-01 19:41:00'),
(9,9,25.00,'Card','demo_txn_0009','Failed','2025-04-05 14:01:00'),
(10,9,25.00,'PayPal','demo_txn_0010','Failed','2025-04-06 09:30:00'),
(11,10,80.00,'Card','demo_txn_0011','Refunded','2025-04-10 17:26:00'),
(12,11,125.00,'Card','demo_txn_0012','Succeeded','2025-06-10 10:01:00'),
(13,12,30.00,'PayPal','demo_txn_0013','Succeeded','2025-06-15 12:01:00'),
(14,13,95.00,'Card','demo_txn_0014','Succeeded','2026-08-25 09:11:00'),
(15,14,15.00,'Card','demo_txn_0015','Succeeded','2026-09-01 21:01:00'),
(16,15,20.00,'Card','demo_txn_0016','Refunded','2025-07-05 15:31:00');

INSERT INTO PAYOUT (PayoutID,CampaignID,GrossAmount,PlatformFee,NetAmount,Status,PaidAt) VALUES
(1,1,270.00,13.50,256.50,'Sent','2025-03-20 12:00:00'),
(2,4,155.00,7.75,147.25,'Sent','2025-08-10 12:00:00');

INSERT INTO CAMPAIGN_UPDATE (CampaignID,UpdateNo,Title,Body,Visibility,PostedAt) VALUES
(1,1,'Prototype complete','The charging layout passed initial bench tests.','Public','2025-02-01 10:00:00'),
(1,2,'Production started','Parts have been ordered and assembly is underway.','BackersOnly','2025-03-15 15:30:00'),
(2,1,'First week milestone','Thank you for helping us reach our first milestone.','Public','2026-09-22 12:00:00'),
(2,2,'Rulebook preview','Backers can review the first draft of the rulebook.','BackersOnly','2026-10-05 17:00:00'),
(3,1,'Campaign wrap-up','We did not reach the target and are reviewing feedback.','Public','2025-06-02 09:00:00'),
(4,1,'Mixer testing','The first production batch passed audio quality checks.','Public','2025-07-10 14:00:00'),
(5,1,'Material samples','Recycled fabric samples are undergoing durability testing.','Public','2026-09-12 11:00:00');

INSERT INTO REPORT (ReportID,ReporterID,CampaignID,RiskLevel,Reason,Details,Status,ReportedAt,ResolvedAt) VALUES
(1,6,3,'Medium','Unclear delivery plan','The page did not explain how delays would be communicated.','Resolved','2025-05-10 12:00:00','2025-05-18 16:00:00'),
(2,7,6,'Low','Campaign information','The page contained an outdated production schedule.','Dismissed','2025-07-10 10:00:00','2025-07-12 09:00:00'),
(3,8,5,'Low','Reward details','Clarify whether the backpack includes the optional organizer.','Open','2026-09-10 14:30:00',NULL),
(4,9,2,'Medium','Reward availability','The limited reward needs a clearer quantity statement.','UnderReview','2026-10-03 08:00:00',NULL),
(5,10,4,'Low','Shipping estimate','The delivery estimate may need international shipping details.','Resolved','2025-07-01 13:00:00','2025-07-04 11:00:00');

COMMIT;

-- Verify row counts in every table.
SELECT 'USER_ACCOUNT' AS TableName, COUNT(*) AS RowCount FROM USER_ACCOUNT
UNION ALL SELECT 'CREATOR', COUNT(*) FROM CREATOR
UNION ALL SELECT 'BACKER', COUNT(*) FROM BACKER
UNION ALL SELECT 'CATEGORY', COUNT(*) FROM CATEGORY
UNION ALL SELECT 'CAMPAIGN', COUNT(*) FROM CAMPAIGN
UNION ALL SELECT 'CAMPAIGN_MEDIA', COUNT(*) FROM CAMPAIGN_MEDIA
UNION ALL SELECT 'REWARD_TIER', COUNT(*) FROM REWARD_TIER
UNION ALL SELECT 'PLEDGE', COUNT(*) FROM PLEDGE
UNION ALL SELECT 'PAYMENT', COUNT(*) FROM PAYMENT
UNION ALL SELECT 'PAYOUT', COUNT(*) FROM PAYOUT
UNION ALL SELECT 'CAMPAIGN_UPDATE', COUNT(*) FROM CAMPAIGN_UPDATE
UNION ALL SELECT 'REPORT', COUNT(*) FROM REPORT
ORDER BY TableName;

-- Verify campaign-to-creator/category relationships.
SELECT c.CampaignID, c.Title, cr.DisplayName, cat.Name AS Category
FROM CAMPAIGN c
JOIN CREATOR cr ON cr.UserID = c.CreatorID
JOIN CATEGORY cat ON cat.CategoryID = c.CategoryID
ORDER BY c.CampaignID;
