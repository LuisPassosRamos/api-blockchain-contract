-- ========================
-- 1) TABELAS PRINCIPAIS
-- ========================

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  wallet CHAR(42) CHARACTER SET ascii NOT NULL,
  name VARCHAR(120) NOT NULL,
  sensitive_info VARCHAR(512),
  on_chain_created_at DATETIME(6),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

  CONSTRAINT pk_users PRIMARY KEY (id),
  CONSTRAINT ux_users_wallet UNIQUE (wallet),
  CONSTRAINT ck_users_wallet_format CHECK (REGEXP_LIKE(wallet, '^0x[0-9a-fA-F]{40}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_agreements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  -- Endereços / hashes on-chain
  contract_address CHAR(42) CHARACTER SET ascii NOT NULL,
  factory_address  CHAR(42) CHARACTER SET ascii,
  contract_hash    CHAR(66) CHARACTER SET ascii NOT NULL,
  tx_hash_create   CHAR(66) CHARACTER SET ascii,

  -- Relacionamentos com usuários (normalizados por ID)
  provider_id BIGINT UNSIGNED NULL,
  client_id   BIGINT UNSIGNED NULL,

  -- Dados do acordo
  agreed_value_wei DECIMAL(38,0) NOT NULL,
  start_date       DATETIME(6)   NOT NULL,
  delivery_date    DATETIME(6)   NULL,
  service_description TEXT,

  status ENUM('CREATED','UPDATED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'CREATED',
  is_completed TINYINT(1) NOT NULL DEFAULT 0,

  on_chain_created_at DATETIME(6),

  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

  CONSTRAINT pk_service_agreements PRIMARY KEY (id),

  CONSTRAINT ux_agreement_contract_address UNIQUE (contract_address),
  CONSTRAINT ux_agreement_contract_hash    UNIQUE (contract_hash),
  CONSTRAINT ux_agreement_txhash           UNIQUE (tx_hash_create),

  CONSTRAINT fk_sa_provider_id FOREIGN KEY (provider_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_sa_client_id   FOREIGN KEY (client_id)   REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,

  -- Regras de integridade
  CONSTRAINT ck_agreed_value_nonneg CHECK (agreed_value_wei >= 0),
  CONSTRAINT ck_dates CHECK (delivery_date IS NULL OR delivery_date >= start_date),

  CONSTRAINT ck_contract_address CHECK (REGEXP_LIKE(contract_address, '^0x[0-9a-fA-F]{40}$')),
  CONSTRAINT ck_factory_address  CHECK (factory_address IS NULL OR REGEXP_LIKE(factory_address, '^0x[0-9a-fA-F]{40}$')),
  CONSTRAINT ck_tx_hash          CHECK (tx_hash_create IS NULL OR REGEXP_LIKE(tx_hash_create, '^0x[0-9a-fA-F]{64}$')),
  CONSTRAINT ck_contract_hash    CHECK (REGEXP_LIKE(contract_hash, '^0x[0-9a-fA-F]{64}$'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Índices para padrão de acesso comum
CREATE INDEX idx_sa_provider_id     ON service_agreements (provider_id);
CREATE INDEX idx_sa_client_id       ON service_agreements (client_id);
CREATE INDEX idx_sa_status_created  ON service_agreements (status, created_at);
CREATE INDEX idx_sa_factory_address ON service_agreements (factory_address);
CREATE INDEX idx_sa_onchain_created ON service_agreements (on_chain_created_at);
CREATE INDEX idx_sa_start_date      ON service_agreements (start_date);
CREATE INDEX idx_sa_delivery_date   ON service_agreements (delivery_date);

-- Busca textual
CREATE FULLTEXT INDEX ftx_sa_description ON service_agreements (service_description);
