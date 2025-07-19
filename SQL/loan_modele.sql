SELECT * FROM loan_applications;


CREATE VIEW dim_customer AS
SELECT loan_id
		, education
        , self_employed
        , no_of_dependents
FROM loan_applications;


CREATE VIEW dim_credit_score AS
SELECT loan_id
		, cibil_score
        , risk_category
FROM loan_applications;



CREATE VIEW dim_assets AS
SELECT loan_id
		, residential_assets_value
		, commercial_assets_value
        , luxury_assets_value
        , bank_asset_value
        , total_asset_value
FROM loan_applications;
