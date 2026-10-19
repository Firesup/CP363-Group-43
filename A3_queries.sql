-- =====================================================================
-- CP363 Assignment 3 - SQL Queries
-- Group 43: Abisan Vijayakaran, Richey Zhang
-- =====================================================================
USE crowdfunding;

-- ---------------------------------------------------------------------
-- Q1. Live campaigns, soonest deadline first
--     Use case: homepage "ending soon" list.
--     Covers: WHERE selection, INNER JOIN (3 tables), ORDER BY
-- ---------------------------------------------------------------------
SELECT  c.CampaignID,
        c.Title        AS Campaign,
        cr.DisplayName AS Creator,
        cat.Name       AS Category,
        c.FundingGoal,
        c.Currency,
        c.EndDate
FROM    CAMPAIGN c
JOIN    CREATOR  cr  ON cr.UserID      = c.CreatorID
JOIN    CATEGORY cat ON cat.CategoryID = c.CategoryID
WHERE   c.Status = 'Live'
ORDER BY c.EndDate;


-- ---------------------------------------------------------------------
-- Q2. Funding raised per category (categories with no pledges still shown)
--     Use case: business report on which categories attract backers.
--     Covers: LEFT JOIN (4 tables), COUNT, SUM, GROUP BY, ORDER BY
-- ---------------------------------------------------------------------
SELECT  cat.Name                        AS Category,
        COUNT(DISTINCT c.CampaignID)    AS Campaigns,
        COUNT(p.PledgeID)               AS ValidPledges,
        COALESCE(SUM(p.Amount), 0)      AS TotalPledged
FROM    CATEGORY cat
LEFT JOIN CAMPAIGN    c  ON c.CategoryID = cat.CategoryID
LEFT JOIN REWARD_TIER rt ON rt.CampaignID = c.CampaignID
LEFT JOIN PLEDGE      p  ON p.TierID = rt.TierID
                        AND p.Status IN ('Active', 'Collected')
GROUP BY cat.CategoryID, cat.Name
ORDER BY TotalPledged DESC, cat.Name;


-- ---------------------------------------------------------------------
-- Q3. Creator leaderboard (creators with at least 2 valid pledges)
--     Use case: highlight creators with proven backer interest.
--     Covers: INNER JOIN (4 tables), WHERE, COUNT, SUM, AVG,
--             GROUP BY, HAVING, ORDER BY
-- ---------------------------------------------------------------------
SELECT  cr.DisplayName                  AS Creator,
        COUNT(DISTINCT c.CampaignID)    AS CampaignsWithPledges,
        COUNT(p.PledgeID)               AS ValidPledges,
        SUM(p.Amount)                   AS TotalPledged,
        ROUND(AVG(p.Amount), 2)         AS AvgPledge
FROM    CREATOR cr
JOIN    CAMPAIGN    c  ON c.CreatorID  = cr.UserID
JOIN    REWARD_TIER rt ON rt.CampaignID = c.CampaignID
JOIN    PLEDGE      p  ON p.TierID     = rt.TierID
WHERE   p.Status IN ('Active', 'Collected')
GROUP BY cr.UserID, cr.DisplayName
HAVING  COUNT(p.PledgeID) >= 2
ORDER BY TotalPledged DESC;


-- ---------------------------------------------------------------------
-- Q4. Payment outcomes by campaign currency and payment method
--     Use case: finance monitoring of processor success / failure / refunds.
--     Covers: INNER JOIN (4 tables), COUNT, SUM, GROUP BY, ORDER BY
-- ---------------------------------------------------------------------
SELECT  c.Currency                      AS CampaignCurrency,
        pay.Method                      AS PaymentMethod,
        pay.Status                      AS PaymentOutcome,
        COUNT(*)                        AS Attempts,
        SUM(pay.Amount)                 AS TotalAmount
FROM    PAYMENT pay
JOIN    PLEDGE      p  ON p.PledgeID    = pay.PledgeID
JOIN    REWARD_TIER rt ON rt.TierID     = p.TierID
JOIN    CAMPAIGN    c  ON c.CampaignID  = rt.CampaignID
GROUP BY c.Currency, pay.Method, pay.Status
ORDER BY c.Currency, TotalAmount DESC, pay.Method;


-- ---------------------------------------------------------------------
-- Q5. Payout reconciliation: does each payout match the collected pledges?
--     Use case: audit that creator payouts equal money actually collected,
--               and show the effective platform fee rate.
--     Covers: INNER JOIN (4 tables), WHERE, SUM, calculated columns,
--             GROUP BY, ORDER BY
-- ---------------------------------------------------------------------
SELECT  c.Title                                              AS Campaign,
        po.GrossAmount,
        po.PlatformFee,
        po.NetAmount,
        ROUND(po.PlatformFee * 100.0 / po.GrossAmount, 2)    AS FeePercent,
        SUM(p.Amount)                                        AS CollectedPledges,
        po.GrossAmount - SUM(p.Amount)                       AS Difference,
        po.PaidAt
FROM    PAYOUT po
JOIN    CAMPAIGN    c  ON c.CampaignID  = po.CampaignID
JOIN    REWARD_TIER rt ON rt.CampaignID = c.CampaignID
JOIN    PLEDGE      p  ON p.TierID      = rt.TierID
WHERE   po.Status = 'Sent'
  AND   p.Status  = 'Collected'
GROUP BY po.PayoutID, c.Title, po.GrossAmount, po.PlatformFee, po.NetAmount, po.PaidAt
ORDER BY po.PaidAt;


-- ---------------------------------------------------------------------
-- Q6. Trust & safety moderation queue (unresolved reports)
--     Use case: moderators see open work, oldest report first.
--     Covers: WHERE with IN, INNER JOIN (4 tables, USER_ACCOUNT joined
--             as the reporter), ORDER BY
-- ---------------------------------------------------------------------
SELECT  r.ReportID,
        c.Title        AS Campaign,
        cr.DisplayName AS Creator,
        rep.FullName   AS ReportedBy,
        r.RiskLevel,
        r.Reason,
        r.Status       AS ReportStatus,
        r.ReportedAt
FROM    REPORT r
JOIN    CAMPAIGN     c   ON c.CampaignID = r.CampaignID
JOIN    CREATOR      cr  ON cr.UserID    = c.CreatorID
JOIN    USER_ACCOUNT rep ON rep.UserID   = r.ReporterID
WHERE   r.Status IN ('Open', 'UnderReview')
ORDER BY r.ReportedAt;


-- ---------------------------------------------------------------------
-- Q7. Reward tiers nobody has successfully backed (LEFT JOIN anti-join)
--     Use case: tell creators which tiers to rework or promote.
--     Covers: INNER JOIN + LEFT JOIN with IS NULL, WHERE, ORDER BY
-- ---------------------------------------------------------------------
SELECT  c.Title           AS Campaign,
        rt.Title          AS RewardTier,
        rt.MinPledgeAmount,
        c.Status          AS CampaignStatus
FROM    REWARD_TIER rt
JOIN    CAMPAIGN c ON c.CampaignID = rt.CampaignID
LEFT JOIN PLEDGE p  ON p.TierID = rt.TierID
                   AND p.Status IN ('Active', 'Collected')
WHERE   p.PledgeID IS NULL
ORDER BY c.Title, rt.MinPledgeAmount;


-- ---------------------------------------------------------------------
-- Q8. SUBQUERY (IN): backers currently supporting a Live campaign
--     Use case: audience for a "campaign ending soon" email.
-- ---------------------------------------------------------------------
SELECT  u.FullName AS Backer,
        b.ShippingCity,
        b.DefaultCurrency,
        b.BackerSince
FROM    BACKER b
JOIN    USER_ACCOUNT u ON u.UserID = b.UserID
WHERE   b.UserID IN (SELECT p.BackerID
                     FROM   PLEDGE p
                     JOIN   REWARD_TIER rt ON rt.TierID    = p.TierID
                     JOIN   CAMPAIGN    c  ON c.CampaignID = rt.CampaignID
                     WHERE  c.Status = 'Live'
                       AND  p.Status = 'Active')
ORDER BY u.FullName;


-- ---------------------------------------------------------------------
-- Q9. SUBQUERY (scalar, uncorrelated): pledges above the platform average
--     Use case: identify high-value backers for recognition.
-- ---------------------------------------------------------------------
SELECT  p.PledgeID,
        u.FullName AS Backer,
        c.Title    AS Campaign,
        rt.Title   AS RewardTier,
        p.Amount,
        p.Status   AS PledgeStatus
FROM    PLEDGE p
JOIN    USER_ACCOUNT u ON u.UserID    = p.BackerID
JOIN    REWARD_TIER  rt ON rt.TierID  = p.TierID
JOIN    CAMPAIGN     c  ON c.CampaignID = rt.CampaignID
WHERE   p.Status IN ('Active', 'Collected')
  AND   p.Amount > (SELECT AVG(Amount)
                    FROM   PLEDGE
                    WHERE  Status IN ('Active', 'Collected'))
ORDER BY p.Amount DESC, p.PledgeID;


-- ---------------------------------------------------------------------
-- Q10. CORRELATED SUBQUERY #1: premium tier(s) in each campaign
--      (tier priced above the average tier price of ITS OWN campaign)
--      Use case: show each campaign's top-end rewards.
-- ---------------------------------------------------------------------
SELECT  c.Title            AS Campaign,
        rt.Title           AS PremiumTier,
        rt.MinPledgeAmount
FROM    REWARD_TIER rt
JOIN    CAMPAIGN c ON c.CampaignID = rt.CampaignID
WHERE   rt.MinPledgeAmount > (SELECT AVG(rt2.MinPledgeAmount)
                              FROM   REWARD_TIER rt2
                              WHERE  rt2.CampaignID = rt.CampaignID)
ORDER BY c.Title, rt.MinPledgeAmount DESC;


-- ---------------------------------------------------------------------
-- Q11. CORRELATED SUBQUERY #2 (NOT EXISTS): pledges with no successful payment
--      Use case: follow-up list for failed, refunded or cancelled pledges.
-- ---------------------------------------------------------------------
SELECT  p.PledgeID,
        u.FullName AS Backer,
        c.Title    AS Campaign,
        p.Amount,
        p.Status   AS PledgeStatus
FROM    PLEDGE p
JOIN    USER_ACCOUNT u  ON u.UserID      = p.BackerID
JOIN    REWARD_TIER  rt ON rt.TierID     = p.TierID
JOIN    CAMPAIGN     c  ON c.CampaignID  = rt.CampaignID
WHERE   NOT EXISTS (SELECT 1
                    FROM   PAYMENT pay
                    WHERE  pay.PledgeID = p.PledgeID
                      AND  pay.Status   = 'Succeeded')
ORDER BY p.PledgeID;


-- ---------------------------------------------------------------------
-- Q12. CORRELATED SUBQUERY #3 (scalar counts per campaign):
--      campaigns reported at least as often as the creator posted updates
--      Use case: flag campaigns where creator communication may be lacking.
-- ---------------------------------------------------------------------
SELECT  c.Title  AS Campaign,
        c.Status AS CampaignStatus,
        (SELECT COUNT(*) FROM CAMPAIGN_UPDATE cu
          WHERE cu.CampaignID = c.CampaignID)  AS UpdatesPosted,
        (SELECT COUNT(*) FROM REPORT r
          WHERE r.CampaignID = c.CampaignID)   AS ReportsFiled
FROM    CAMPAIGN c
WHERE   (SELECT COUNT(*) FROM REPORT r
          WHERE r.CampaignID = c.CampaignID)
     >= (SELECT COUNT(*) FROM CAMPAIGN_UPDATE cu
          WHERE cu.CampaignID = c.CampaignID)
ORDER BY c.Title;
