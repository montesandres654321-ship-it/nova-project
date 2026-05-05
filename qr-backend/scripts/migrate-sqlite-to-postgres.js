require('dotenv').config();

const Database = require('better-sqlite3');
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function migrate() {
  const sqlitePath = process.env.DB_PATH;
  const pgUrl = process.env.POSTGRES_URL;

  if (!pgUrl) {
    throw new Error('POSTGRES_URL no configurado');
  }

  const sqliteDb = new Database(sqlitePath, { readonly: true });

  const pgClient = new Client({
    connectionString: pgUrl,
  });

  await pgClient.connect();

  try {
    console.log('🔄 Iniciando migración...');

    // =========================
    // 1. Crear schema PostgreSQL
    // =========================
    const schemaSql = fs.readFileSync(
      path.join(__dirname, '../postgres/schema.sql'),
      'utf8'
    );

    await pgClient.query(schemaSql);
    console.log('✅ Schema cargado');

    // =========================
    // 2. Iniciar transacción
    // =========================
    await pgClient.query('BEGIN');

    // =========================
    // 3. MIGRAR PLACES PRIMERO
    // =========================
    const places = sqliteDb.prepare('SELECT * FROM places').all();

    for (const p of places) {
      await pgClient.query(
        `
        INSERT INTO places (
          id, name, tipo, lugar, description, image_url,
          rating, address, phone, price_range,
          amenities, is_active,
          has_reward, reward_name, reward_description,
          reward_icon, reward_stock,
          owner_id, created_at, updated_at
        )
        VALUES (
          $1,$2,$3,$4,$5,$6,
          $7,$8,$9,$10,
          $11,$12,
          $13,$14,$15,
          $16,$17,
          $18,$19,$20
        )
        ON CONFLICT (id) DO NOTHING
        `,
        [
          p.id,
          p.name,
          p.tipo,
          p.lugar,
          p.description,
          p.image_url,
          p.rating || 0,
          p.address,
          p.phone,
          p.price_range,
          JSON.stringify(p.amenities || []),
          p.is_active ? true : false,
          p.has_reward ? true : false,
          p.reward_name,
          p.reward_description,
          p.reward_icon,
          p.reward_stock,
          p.owner_id,
          p.created_at,
          p.updated_at,
        ]
      );
    }

    console.log('✅ Places migrados');

    // 🔥 mapa de places válidos
    const validPlaceIds = new Set(places.map(p => p.id));

    // =========================
    // 4. MIGRAR USERS (CON LIMPIEZA)
    // =========================
    const users = sqliteDb.prepare('SELECT * FROM users').all();

    for (const u of users) {
      let placeId = u.place_id;

      // 🔥 LIMPIEZA CRÍTICA
      if (placeId && !validPlaceIds.has(placeId)) {
        placeId = null;
      }

      await pgClient.query(
        `
        INSERT INTO users (
          id, first_name, last_name, username, email, password,
          phone, dob, gender, google_id,
          accepted_terms, is_active, created_at, last_login,
          role, place_id, token_version
        )
        VALUES (
          $1,$2,$3,$4,$5,$6,
          $7,$8,$9,$10,
          $11,$12,$13,$14,
          $15,$16,$17
        )
        ON CONFLICT (id) DO NOTHING
        `,
        [
          u.id,
          u.first_name,
          u.last_name,
          u.username,
          u.email,
          u.password,
          u.phone,
          u.dob,
          u.gender,
          u.google_id,
          u.accepted_terms ? true : false,
          u.is_active ? true : false,
          u.created_at,
          u.last_login,
          u.role,
          placeId,
          u.token_version || 1,
        ]
      );
    }

    console.log('✅ Users migrados');

    // 🔥 mapa de users válidos
    const validUserIds = new Set(users.map(u => u.id));

    // =========================
    // 5. MIGRAR SCANS
    // =========================
    const scans = sqliteDb.prepare('SELECT * FROM scans').all();
    let skippedScans = 0;

    for (const s of scans) {
      if (!validPlaceIds.has(s.place_id) || !validUserIds.has(s.user_id)) {
        skippedScans += 1;
        console.warn(`⚠️ Scan descartado por FK inválida: scan_id=${s.id}, user_id=${s.user_id}, place_id=${s.place_id}`);
        continue;
      }

      await pgClient.query(
        `
        INSERT INTO scans (
          id, user_id, place_id, qr_code, created_at
        )
        VALUES ($1,$2,$3,$4,$5)
        ON CONFLICT (id) DO NOTHING
        `,
        [s.id, s.user_id, s.place_id, s.qr_code, s.created_at]
      );
    }

    console.log('✅ Scans migrados');
    if (skippedScans > 0) {
      console.warn(`⚠️ Scans descartados: ${skippedScans}`);
    }

    // =========================
    // 6. MIGRAR REWARDS
    // =========================
    const rewards = sqliteDb.prepare('SELECT * FROM user_rewards').all();
    let skippedRewards = 0;

    for (const r of rewards) {
      if (!validPlaceIds.has(r.place_id) || !validUserIds.has(r.user_id)) {
        skippedRewards += 1;
        console.warn(`⚠️ Reward descartado por FK inválida: reward_id=${r.id}, user_id=${r.user_id}, place_id=${r.place_id}`);
        continue;
      }

      await pgClient.query(
        `
        INSERT INTO rewards (
          id, user_id, place_id,
          reward_name, reward_description, reward_icon,
          is_redeemed, earned_at, redeemed_at
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
        ON CONFLICT (id) DO NOTHING
        `,
        [
          r.id,
          r.user_id,
          r.place_id,
          r.reward_name,
          r.reward_description,
          r.reward_icon,
          r.is_redeemed ? true : false,
          r.earned_at,
          r.redeemed_at,
        ]
      );
    }

    console.log('✅ Rewards migrados');
    if (skippedRewards > 0) {
      console.warn(`⚠️ Rewards descartados: ${skippedRewards}`);
    }

    // =========================
    // 7. MIGRAR SESSIONS (si existe)
    // =========================
    const sessionsTable = sqliteDb.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='sessions'").get();
    if (sessionsTable) {
      const sessions = sqliteDb.prepare('SELECT * FROM sessions').all();
      let skippedSessions = 0;

      for (const s of sessions) {
        if (!validUserIds.has(s.user_id)) {
          skippedSessions += 1;
          console.warn(`⚠️ Session descartada por user_id inválido: session_id=${s.id}, user_id=${s.user_id}`);
          continue;
        }

        await pgClient.query(
          `
          INSERT INTO sessions (
            id, user_id, refresh_token_hash, user_agent, ip,
            created_at, expires_at, revoked, replaced_by_token
          )
          VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
          ON CONFLICT (id) DO NOTHING
          `,
          [
            s.id,
            s.user_id,
            s.refresh_token_hash,
            s.user_agent,
            s.ip,
            s.created_at,
            s.expires_at,
            s.revoked ? true : false,
            s.replaced_by_token,
          ]
        );
      }

      console.log('✅ Sessions migradas');
      if (skippedSessions > 0) {
        console.warn(`⚠️ Sessions descartadas: ${skippedSessions}`);
      }
    } else {
      console.log('ℹ️ Tabla sessions no existe en SQLite, se omite migración');
    }

    // =========================
    // 8. COMMIT
    // =========================
    await pgClient.query('COMMIT');

    console.log('🎉 Migración completada correctamente');
  } catch (err) {
    await pgClient.query('ROLLBACK');
    console.error('❌ Error en migración:', err.message);
  } finally {
    await pgClient.end();
    sqliteDb.close();
  }
}

migrate();
