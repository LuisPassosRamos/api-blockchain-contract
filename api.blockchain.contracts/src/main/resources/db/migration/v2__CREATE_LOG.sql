-- ========================
-- 2) AUDITORIA
-- ========================

CREATE TABLE IF NOT EXISTS service_agreement_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  agreement_id BIGINT UNSIGNED NOT NULL,
  changed_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  old_status ENUM('CREATED','UPDATED','COMPLETED','CANCELLED'),
  new_status ENUM('CREATED','UPDATED','COMPLETED','CANCELLED'),
  old_value_wei DECIMAL(38,0),
  new_value_wei DECIMAL(38,0),

  PRIMARY KEY (id),
  INDEX idx_log_agreement (agreement_id),
  CONSTRAINT fk_log_agreement FOREIGN KEY (agreement_id)
    REFERENCES service_agreements(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;