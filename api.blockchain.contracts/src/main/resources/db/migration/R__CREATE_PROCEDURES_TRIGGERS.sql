-- ========================
-- 4) PROCEDURES & TRIGGERS
-- ========================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_create_contract_by_wallet $$
CREATE PROCEDURE sp_create_contract_by_wallet(
  IN p_contract_address CHAR(42),
  IN p_factory_address  CHAR(42),
  IN p_provider_wallet  CHAR(42),
  IN p_client_wallet    CHAR(42),
  IN p_agreed_value_wei DECIMAL(38,0),
  IN p_start_date       DATETIME(6),
  IN p_delivery_date    DATETIME(6),
  IN p_service_description TEXT,
  IN p_contract_hash    CHAR(66),
  IN p_tx_hash_create   CHAR(66)
)
BEGIN
  DECLARE v_provider_id BIGINT UNSIGNED;
  DECLARE v_client_id   BIGINT UNSIGNED;

  SELECT id INTO v_provider_id FROM users WHERE wallet = p_provider_wallet;
  SELECT id INTO v_client_id   FROM users WHERE wallet = p_client_wallet;

  INSERT INTO service_agreements(
    contract_address, factory_address,
    provider_id, client_id,
    agreed_value_wei, start_date, delivery_date,
    service_description, is_completed, contract_hash, status, tx_hash_create
  )
  VALUES (
    p_contract_address, p_factory_address,
    v_provider_id, v_client_id,
    p_agreed_value_wei, p_start_date, p_delivery_date,
    p_service_description, 0, p_contract_hash, 'CREATED', p_tx_hash_create
  );
END $$

DROP TRIGGER IF EXISTS trg_sa_is_completed_bi $$
CREATE TRIGGER trg_sa_is_completed_bi
BEFORE INSERT ON service_agreements
FOR EACH ROW
BEGIN
  SET NEW.is_completed = (NEW.status = 'COMPLETED');
END $$

DROP TRIGGER IF EXISTS trg_sa_is_completed_bu $$
CREATE TRIGGER trg_sa_is_completed_bu
BEFORE UPDATE ON service_agreements
FOR EACH ROW
BEGIN
  IF NEW.status <> OLD.status THEN
    SET NEW.is_completed = (NEW.status = 'COMPLETED');
  END IF;
END $$

DROP TRIGGER IF EXISTS trg_sa_audit_au $$
CREATE TRIGGER trg_sa_audit_au
AFTER UPDATE ON service_agreements
FOR EACH ROW
BEGIN
  IF (OLD.status <> NEW.status) OR (OLD.agreed_value_wei <> NEW.agreed_value_wei) THEN
    INSERT INTO service_agreement_log(
      agreement_id, old_status, new_status, old_value_wei, new_value_wei
    ) VALUES (
      OLD.id, OLD.status, NEW.status, OLD.agreed_value_wei, NEW.agreed_value_wei
    );
  END IF;
END $$

DELIMITER ;
