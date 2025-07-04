ALTER VIEW loan_applications_enriched AS
SELECT
    loan_id,
    no_of_dependents,
    education,
    self_employed,
    income_annum,
    loan_amount,
    loan_term,
    loan_term / 12.0 AS loan_term_years,

    cibil_score,
    CASE
        WHEN cibil_score < 600 THEN 'Low'
        WHEN cibil_score BETWEEN 600 AND 750 THEN 'Medium'
        ELSE 'High'
    END AS risk_category,

    residential_assets_value,
    commercial_assets_value,
    luxury_assets_value,
    bank_asset_value,

    -- Total des actifs
    (residential_assets_value + commercial_assets_value + luxury_assets_value + bank_asset_value) AS total_assets_value,

    -- Ratio dette/revenu
    loan_amount * 1.0 / NULLIF(income_annum, 0) AS debt_to_income_ratio,

    -- Ratio actif/prêt
    (residential_assets_value + commercial_assets_value + luxury_assets_value + bank_asset_value) * 1.0 / NULLIF(loan_amount, 0) AS asset_to_loan_ratio,

    -- Dépendants ?
    CASE
        WHEN no_of_dependents > 0 THEN 1
        ELSE 0
    END AS has_dependents,

    -- Revenu faible ?
    CASE
        WHEN income_annum < 300000 THEN 1
        ELSE 0
    END AS is_low_income,

    loan_status,
    CASE
        WHEN LOWER(TRIM(loan_status)) = 'approved' THEN 1
        ELSE 0
    END AS loan_status_code
FROM
    loan_applications;


SELECT * FROM loan_applications_enriched;
    

CREATE VIEW approval_rate AS
SELECT
    COUNT(*) AS total_demandes,
    SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'approved' THEN 1 ELSE 0 END) AS demandes_approvees,
    ROUND(
        SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
	 2
    ) AS taux_approbation
FROM
    loan_applications_enriched;


CREATE VIEW approval_by_risk AS
SELECT
	risk_category,
    COUNT(*) AS total,
    SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'Approved' THEN 1 ELSE 0 END) AS approved,
    ROUND(SUM(CASE WHEN LOWER(TRIM(loan_status)) = 'Approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS taux_approbation
FROM
    loan_applications_enriched
GROUP BY
    risk_category;


CREATE VIEW approval_by_education AS
SELECT
    education,
    COUNT(*) AS total,
    SUM(loan_status_code) AS approved,
    ROUND(SUM(loan_status_code) * 100.0 / COUNT(*), 2) AS taux_approbation
FROM
    loan_applications_enriched
GROUP BY
    education;
    

CREATE VIEW avg_ratios_by_status AS
SELECT
    loan_status,
    ROUND(AVG(debt_to_income_ratio), 2) AS avg_debt_ratio,
    ROUND(AVG(asset_to_loan_ratio), 2) AS avg_asset_ratio,
    ROUND(AVG(total_assets_value), 2) AS avg_assets
FROM
    loan_applications_enriched
GROUP BY
    loan_status;

