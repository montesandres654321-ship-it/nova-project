-- Critical indexes for auth v2, scans and analytics

CREATE INDEX IF NOT EXISTS idx_users_role_active ON users(role, is_active);
CREATE INDEX IF NOT EXISTS idx_users_place_id ON users(place_id);

CREATE INDEX IF NOT EXISTS idx_places_tipo_active ON places(tipo, is_active);
CREATE INDEX IF NOT EXISTS idx_places_owner_active ON places(owner_id, is_active);

CREATE INDEX IF NOT EXISTS idx_scans_user_created ON scans(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scans_place_created ON scans(place_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scans_created_brin ON scans USING BRIN(created_at);

CREATE INDEX IF NOT EXISTS idx_rewards_user_redeemed ON rewards(user_id, is_redeemed, earned_at DESC);
CREATE INDEX IF NOT EXISTS idx_rewards_place_redeemed ON rewards(place_id, is_redeemed, earned_at DESC);

-- Intentionally NOT UNIQUE by request
CREATE INDEX IF NOT EXISTS idx_sessions_refresh_hash ON sessions(refresh_token_hash);
CREATE INDEX IF NOT EXISTS idx_sessions_user_active ON sessions(user_id, revoked, expires_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);
