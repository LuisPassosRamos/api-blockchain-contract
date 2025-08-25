-- ========================
-- 3) VIEWS
-- ========================

CREATE OR REPLACE VIEW view_contracts_summary AS
SELECT
  sa.status,
  sa.provider_id,
  sa.client_id,
  COUNT(*) AS total,
  SUM(sa.is_completed = 1) AS completed
FROM service_agreements sa
GROUP BY sa.status, sa.provider_id, sa.client_id;

CREATE OR REPLACE VIEW view_contract_deadlines AS
SELECT
  sa.id,
  sa.provider_id,
  sa.client_id,
  sa.start_date,
  sa.delivery_date,
  DATEDIFF(sa.delivery_date, NOW()) AS days_to_deadline,
  sa.status
FROM service_agreements sa
WHERE sa.delivery_date IS NOT NULL;