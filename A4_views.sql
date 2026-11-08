-- CP363 Assignment 4 | Group 43 - CrowdFunding DB | Reporting views
USE crowdfunding_a4;

CREATE OR REPLACE VIEW vw_campaign_funding_progress AS
SELECT c.CampaignID,
       c.Title AS Campaign,
       c.Status AS CampaignStatus,
       c.Currency,
       c.FundingGoal,
       COUNT(p.PledgeID) AS ValidPledges,
       COALESCE(SUM(p.Amount), 0) AS AmountRaised,
       ROUND(COALESCE(SUM(p.Amount), 0) * 100.0 / c.FundingGoal, 2) AS PercentFunded
FROM CAMPAIGN c
LEFT JOIN REWARD_TIER rt ON rt.CampaignID = c.CampaignID
LEFT JOIN PLEDGE p ON p.TierID = rt.TierID AND p.Status IN ('Active', 'Collected')
GROUP BY c.CampaignID, c.Title, c.Status, c.Currency, c.FundingGoal;

CREATE OR REPLACE VIEW vw_backer_activity AS
SELECT b.UserID AS BackerID,
       u.FullName AS Backer,
       u.Country,
       COUNT(p.PledgeID) AS TotalPledges,
       SUM(CASE WHEN p.Status IN ('Active', 'Collected') THEN 1 ELSE 0 END) AS ValidPledges,
       SUM(CASE WHEN p.Status IN ('Active', 'Collected') THEN p.Amount ELSE 0 END) AS ValidPledgeTotal,
       ROUND(100.0 * SUM(CASE WHEN p.Status IN ('Active', 'Collected') THEN 1 ELSE 0 END)
             / NULLIF(COUNT(p.PledgeID), 0), 1) AS ValidPledgePercent
FROM BACKER b
JOIN USER_ACCOUNT u ON u.UserID = b.UserID
LEFT JOIN PLEDGE p ON p.BackerID = b.UserID
GROUP BY b.UserID, u.FullName, u.Country;

CREATE OR REPLACE VIEW vw_creator_payout_summary AS
SELECT cr.UserID AS CreatorID,
       cr.DisplayName AS Creator,
       COUNT(po.PayoutID) AS PayoutsSent,
       SUM(po.GrossAmount) AS TotalGross,
       SUM(po.PlatformFee) AS TotalPlatformFees,
       SUM(po.GrossAmount - po.PlatformFee) AS TotalNetPaid,
       ROUND(SUM(po.PlatformFee) * 100.0 / NULLIF(SUM(po.GrossAmount), 0), 2) AS EffectiveFeePercent
FROM CREATOR cr
JOIN CAMPAIGN c ON c.CreatorID = cr.UserID
JOIN PAYOUT po ON po.CampaignID = c.CampaignID
WHERE po.Status = 'Sent'
GROUP BY cr.UserID, cr.DisplayName;
