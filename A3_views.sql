-- =====================================================================
-- CP363 Assignment 3 - Views (3)
-- Group 43: Abisan Vijayakaran, Richey Zhang
-- Run after A3_population.sql. Each view uses GROUP BY, ORDER BY and
-- at least one calculated field.
-- =====================================================================
USE crowdfunding;


-- ---------------------------------------------------------------------
-- View 1: campaign funding progress
--   Calculated fields: AmountRaised, PercentFunded
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_campaign_funding_progress AS
SELECT  c.CampaignID,
        c.Title                                        AS Campaign,
        c.Status                                       AS CampaignStatus,
        c.Currency,
        c.FundingGoal,
        COUNT(p.PledgeID)                              AS ValidPledges,
        COALESCE(SUM(p.Amount), 0)                     AS AmountRaised,
        ROUND(COALESCE(SUM(p.Amount), 0) * 100.0 / c.FundingGoal, 2) AS PercentFunded
FROM    CAMPAIGN c
LEFT JOIN REWARD_TIER rt ON rt.CampaignID = c.CampaignID
LEFT JOIN PLEDGE      p  ON p.TierID = rt.TierID
                        AND p.Status IN ('Active', 'Collected')
GROUP BY c.CampaignID, c.Title, c.Status, c.Currency, c.FundingGoal
ORDER BY PercentFunded DESC, c.CampaignID;


-- ---------------------------------------------------------------------
-- View 2: backer activity
--   Calculated fields: ValidPledges, ValidPledgeTotal, ValidPledgePercent
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_backer_activity AS
SELECT  b.UserID                                       AS BackerID,
        u.FullName                                     AS Backer,
        u.Country,
        COUNT(p.PledgeID)                              AS TotalPledges,
        SUM(CASE WHEN p.Status IN ('Active', 'Collected')
                 THEN 1 ELSE 0 END)                    AS ValidPledges,
        SUM(CASE WHEN p.Status IN ('Active', 'Collected')
                 THEN p.Amount ELSE 0 END)             AS ValidPledgeTotal,
        ROUND(100.0 * SUM(CASE WHEN p.Status IN ('Active', 'Collected')
                             THEN 1 ELSE 0 END)
              / COUNT(p.PledgeID), 1)                  AS ValidPledgePercent
FROM    BACKER b
JOIN    USER_ACCOUNT u ON u.UserID = b.UserID
LEFT JOIN PLEDGE p     ON p.BackerID = b.UserID
GROUP BY b.UserID, u.FullName, u.Country
ORDER BY ValidPledgeTotal DESC, u.FullName;


-- ---------------------------------------------------------------------
-- View 3: creator payout summary (platform revenue per creator)
--   Calculated field: EffectiveFeePercent
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_creator_payout_summary AS
SELECT  cr.UserID                                      AS CreatorID,
        cr.DisplayName                                 AS Creator,
        COUNT(po.PayoutID)                             AS PayoutsSent,
        SUM(po.GrossAmount)                            AS TotalGross,
        SUM(po.PlatformFee)                            AS TotalPlatformFees,
        SUM(po.NetAmount)                              AS TotalNetPaid,
        ROUND(SUM(po.PlatformFee) * 100.0 / SUM(po.GrossAmount), 2) AS EffectiveFeePercent
FROM    CREATOR cr
JOIN    CAMPAIGN c ON c.CreatorID  = cr.UserID
JOIN    PAYOUT  po ON po.CampaignID = c.CampaignID
WHERE   po.Status = 'Sent'
GROUP BY cr.UserID, cr.DisplayName
ORDER BY TotalNetPaid DESC;


-- ---------------------------------------------------------------------
-- Screenshots: list the views, then query each one
-- ---------------------------------------------------------------------
SHOW FULL TABLES IN crowdfunding WHERE Table_type = 'VIEW';

SELECT * FROM vw_campaign_funding_progress;

SELECT * FROM vw_backer_activity;

SELECT * FROM vw_creator_payout_summary;
