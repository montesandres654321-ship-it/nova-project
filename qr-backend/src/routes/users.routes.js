const express   = require('express');
const bcrypt    = require('bcryptjs');
const router    = express.Router();
const prisma    = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [key, value] of Object.entries(row)) {
      obj[key] = typeof value === 'bigint' ? Number(value) :
                 value instanceof Date ? value.toISOString() : value;
    }
    return obj;
  });
}

// ─── PATCH /users/me/profile ──────────────────────────────
router.patch('/users/me/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { first_name, last_name, phone } = req.body;

    if (first_name === undefined && last_name === undefined && phone === undefined) {
      return res.status(400).json({ success: false, error: 'Se requiere al menos un campo: first_name, last_name o phone' });
    }

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const newFirstName = first_name !== undefined ? first_name.trim() : user.first_name;
    const newLastName  = last_name  !== undefined ? last_name.trim()  : user.last_name;
    const newPhone     = phone      !== undefined ? (phone.trim() || null) : user.phone;

    if (first_name !== undefined && !first_name.trim()) {
      return res.status(400).json({ success: false, error: 'El nombre no puede estar vacío' });
    }

    await prisma.$executeRaw`UPDATE users SET first_name = ${newFirstName}, last_name = ${newLastName}, phone = ${newPhone} WHERE id = ${userId}`;

    const updated = (await prisma.$queryRaw`
      SELECT id, username, email, first_name, last_name, role, phone, place_id, is_active FROM users WHERE id = ${userId}
    `)[0];

    console.log(`✅ Perfil propio actualizado: ID:${userId} (${updated.email})`);
    return res.json({ success: true, message: 'Perfil actualizado correctamente', data: updated });
  } catch (error) {
    console.error('❌ Error en PATCH /users/me/profile:', error);
    return res.status(500).json({ success: false, error: 'Error al actualizar perfil' });
  }
});

// ─── POST /users/me/password ──────────────────────────────
router.post('/users/me/password', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res.status(400).json({ success: false, error: 'Se requiere contraseña actual y nueva contraseña' });
    }
    if (new_password.length < 6) {
      return res.status(400).json({ success: false, error: 'La nueva contraseña debe tener al menos 6 caracteres' });
    }

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const validPassword = bcrypt.compareSync(current_password, user.password);
    if (!validPassword) {
      return res.status(401).json({ success: false, error: 'La contraseña actual es incorrecta' });
    }

    const hashedPassword = await bcrypt.hash(new_password, 10);
    await prisma.$executeRaw`UPDATE users SET password = ${hashedPassword} WHERE id = ${userId}`;

    console.log(`✅ Contraseña cambiada: ID:${userId} (${user.email})`);
    return res.json({ success: true, message: 'Contraseña actualizada exitosamente' });
  } catch (error) {
    console.error('❌ Error en POST /users/me/password:', error);
    return res.status(500).json({ success: false, error: 'Error al cambiar contraseña' });
  }
});

// ─── GET /users ───────────────────────────────────────────
router.get('/users', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const users = await prisma.$queryRaw`
      SELECT id, username, email, first_name, last_name, role,
             is_active, created_at, last_login, phone, place_id
      FROM users ORDER BY created_at DESC
    `;
    return res.json({ success: true, data: users });
  } catch (error) {
    console.error('❌ Error en GET /users:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener usuarios' });
  }
});

// ─── GET /users/:id ───────────────────────────────────────
router.get('/users/:id', authenticateToken, async (req, res) => {
  try {
    const requestedId = parseInt(req.params.id);
    if (req.user.id !== requestedId &&
        req.user.role !== 'admin_general' &&
        req.user.role !== 'user_general') {
      return res.status(403).json({ success: false, error: 'Sin permiso para ver este usuario' });
    }

    const user = (await prisma.$queryRaw`
      SELECT id, username, email, first_name, last_name, role,
             is_active, created_at, last_login, phone, place_id
      FROM users WHERE id = ${requestedId}
    `)[0];

    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    return res.json({ success: true, data: user });
  } catch (error) {
    console.error('❌ Error en GET /users/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener usuario' });
  }
});

// ─── GET /admin/users ─────────────────────────────────────
router.get('/admin/users', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const users = serializeRaw(await prisma.$queryRaw`
      SELECT
        u.id, u.first_name, u.last_name, u.username, u.email, u.phone,
        u.created_at, u.last_login, u.is_active, u.google_id, u.role,
        COUNT(DISTINCT s.id)::int  as total_scans,
        COUNT(DISTINCT ur.id)::int as total_rewards,
        SUM(CASE WHEN ur.is_redeemed = TRUE THEN 1 ELSE 0 END)::int as redeemed_rewards
      FROM users u
      LEFT JOIN scans s         ON u.id = s.user_id
      LEFT JOIN user_rewards ur ON u.id = ur.user_id
      WHERE u.role IS NULL
      GROUP BY u.id
      ORDER BY u.created_at DESC
    `);
    return res.json({ success: true, data: users });
  } catch (error) {
    console.error('❌ Error en GET /admin/users:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener usuarios' });
  }
});

// ─── GET /admin/users/:id ─────────────────────────────────
router.get('/admin/users/:id', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const scans = await prisma.$queryRaw`
      SELECT s.*, p.name as place_name, p.tipo, p.lugar
      FROM scans s JOIN places p ON s.place_id = p.id
      WHERE s.user_id = ${id} ORDER BY s.created_at DESC
    `;

    const rewards = await prisma.$queryRaw`
      SELECT ur.*, p.name as place_name
      FROM user_rewards ur JOIN places p ON ur.place_id = p.id
      WHERE ur.user_id = ${id} ORDER BY ur.earned_at DESC
    `;

    const topPlaces = serializeRaw(await prisma.$queryRaw`
      SELECT p.name, p.tipo, p.lugar, COUNT(*)::int as visit_count
      FROM scans s JOIN places p ON s.place_id = p.id
      WHERE s.user_id = ${id} GROUP BY p.id, p.name, p.tipo, p.lugar
      ORDER BY visit_count DESC LIMIT 5
    `);

    const { password: _, ...userWithoutPassword } = user;

    return res.json({
      success: true,
      data: {
        user: userWithoutPassword,
        scans,
        rewards,
        topPlaces,
        stats: {
          totalScans:      scans.length,
          totalRewards:    rewards.length,
          redeemedRewards: rewards.filter(r => r.is_redeemed).length,
        },
      },
    });
  } catch (error) {
    console.error('❌ Error en GET /admin/users/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener detalle' });
  }
});

// ─── PATCH /admin/users/:id/toggle ───────────────────────
router.patch('/admin/users/:id/toggle', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const newStatus = !user.is_active;
    await prisma.$executeRaw`UPDATE users SET is_active = ${newStatus} WHERE id = ${id}`;

    return res.json({
      success: true,
      data: { message: `Usuario ${newStatus ? 'activado' : 'desactivado'}`, is_active: newStatus },
    });
  } catch (error) {
    console.error('❌ Error en toggle usuario:', error);
    return res.status(500).json({ success: false, error: 'Error al cambiar estado' });
  }
});

// ─── POST /admin/users/create ─────────────────────────────
router.post('/admin/users/create', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const { first_name, last_name, email, password, username, role, place_id } = req.body;

    if (!email || !password || !username || !role) {
      return res.status(400).json({ success: false, error: 'Email, contraseña, usuario y rol son requeridos' });
    }

    const validRoles = ['admin_general', 'user_general', 'user_place'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ success: false, error: 'Rol inválido' });
    }

    if (role === 'user_place' && !place_id) {
      return res.status(400).json({ success: false, error: 'place_id es requerido para user_place' });
    }

    const existing = (await prisma.$queryRaw`SELECT id FROM users WHERE email = ${email} OR username = ${username}`)[0];
    if (existing) {
      return res.status(409).json({ success: false, error: 'Email o usuario ya en uso' });
    }

    const hashed       = await bcrypt.hash(password, 10);
    const finalPlaceId = role === 'user_place' ? (place_id || null) : null;
    const fn           = first_name || '';
    const ln           = last_name  || '';

    const inserted = await prisma.$queryRaw`
      INSERT INTO users (first_name, last_name, username, email, password, role, place_id, is_active, accepted_terms)
      VALUES (${fn}, ${ln}, ${username}, ${email}, ${hashed}, ${role}, ${finalPlaceId}, TRUE, TRUE)
      RETURNING id
    `;

    const newUser = (await prisma.$queryRaw`
      SELECT id, username, email, first_name, last_name, role, place_id, is_active FROM users WHERE id = ${inserted[0].id}
    `)[0];

    console.log(`✅ Usuario del panel creado: ${email} (${role})`);
    return res.status(201).json({ success: true, data: newUser });

  } catch (error) {
    console.error('❌ Error en POST /admin/users/create:', error);
    return res.status(500).json({ success: false, error: 'Error al crear usuario' });
  }
});

// ─── PATCH /admin/users/:id/role ─────────────────────────
router.patch('/admin/users/:id/role', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const { role, place_id } = req.body;
    const id = parseInt(req.params.id);

    const validRoles = ['admin_general', 'user_general', 'user_place'];
    if (!validRoles.includes(role)) {
      return res.status(400).json({ success: false, error: 'Rol inválido' });
    }
    if (role === 'user_place' && !place_id) {
      return res.status(400).json({ success: false, error: 'place_id requerido para user_place' });
    }

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const newPlaceId = role === 'user_place' ? (place_id || null) : null;
    await prisma.$executeRaw`UPDATE users SET role = ${role}, place_id = ${newPlaceId} WHERE id = ${id}`;

    return res.json({ success: true, message: `Rol actualizado a ${role}` });
  } catch (error) {
    console.error('❌ Error en PATCH /admin/users/:id/role:', error);
    return res.status(500).json({ success: false, error: 'Error al cambiar rol' });
  }
});

// ─── PATCH /admin/users/:id ───────────────────────────────
router.patch('/admin/users/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { first_name, last_name, phone } = req.body;

    if (first_name === undefined && last_name === undefined && phone === undefined) {
      return res.status(400).json({ success: false, error: 'Se requiere al menos un campo: first_name, last_name o phone' });
    }

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const newFirstName = first_name !== undefined ? first_name.trim() : user.first_name;
    const newLastName  = last_name  !== undefined ? last_name.trim()  : user.last_name;
    const newPhone     = phone      !== undefined ? (phone.trim() || null) : user.phone;

    if (first_name !== undefined && !first_name.trim()) {
      return res.status(400).json({ success: false, error: 'El nombre no puede estar vacío' });
    }
    if (last_name !== undefined && !last_name.trim()) {
      return res.status(400).json({ success: false, error: 'El apellido no puede estar vacío' });
    }

    await prisma.$executeRaw`UPDATE users SET first_name = ${newFirstName}, last_name = ${newLastName}, phone = ${newPhone} WHERE id = ${id}`;

    const updated = (await prisma.$queryRaw`
      SELECT id, username, email, first_name, last_name, role, phone, place_id, is_active FROM users WHERE id = ${id}
    `)[0];

    console.log(`✅ Usuario actualizado: ID:${id} (${updated.email})`);
    return res.json({ success: true, message: 'Usuario actualizado correctamente', data: updated });
  } catch (error) {
    console.error('❌ Error en PATCH /admin/users/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al actualizar usuario' });
  }
});

// ─── DELETE /admin/users/:id ──────────────────────────────
router.delete('/admin/users/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const targetId = parseInt(req.params.id);

    if (req.user.id === targetId) {
      return res.status(400).json({ success: false, error: 'No puedes desactivar tu propia cuenta' });
    }

    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${targetId}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    if (!user.is_active) {
      return res.status(400).json({ success: false, error: 'El usuario ya está desactivado' });
    }

    if (user.role === 'admin_general') {
      const [{ c }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM users WHERE role = 'admin_general' AND is_active = TRUE`);
      if (c <= 1) {
        return res.status(400).json({ success: false, error: 'No se puede desactivar el único administrador general activo del sistema' });
      }
    }

    await prisma.$executeRaw`UPDATE users SET is_active = FALSE WHERE id = ${targetId}`;

    const displayName = [user.first_name, user.last_name].filter(Boolean).join(' ') || user.username;
    console.log(`⚠️  Usuario desactivado: ID:${targetId} (${user.email}) por admin ID:${req.user.id}`);

    return res.json({
      success: true,
      message: `Usuario "${displayName}" desactivado. Su historial se conserva.`,
      data: { id: targetId, is_active: false },
    });
  } catch (error) {
    console.error('❌ Error en DELETE /admin/users/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al desactivar usuario' });
  }
});

// ─── GET /api/admins/owners ───────────────────────────────
router.get('/api/admins/owners', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const owners = await prisma.$queryRaw`
      SELECT u.id, u.first_name, u.last_name, u.username, u.email,
             u.phone, u.role, u.place_id, u.is_active, u.created_at, u.last_login,
             p.name as place_name, p.tipo as place_tipo, p.lugar as place_lugar
      FROM users u
      LEFT JOIN places p ON u.place_id = p.id
      WHERE u.role IN ('admin_general', 'user_general', 'user_place')
      ORDER BY
        CASE u.role
          WHEN 'admin_general' THEN 1
          WHEN 'user_general'  THEN 2
          WHEN 'user_place'    THEN 3
        END, u.created_at DESC
    `;
    return res.json({ success: true, data: owners });
  } catch (error) {
    console.error('❌ Error en GET /api/admins/owners:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener propietarios' });
  }
});

// ─── PATCH /api/admins/:id/toggle ────────────────────────
router.patch('/api/admins/:id/toggle', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const user = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`)[0];
    if (!user) return res.status(404).json({ success: false, error: 'Usuario no encontrado' });

    const newStatus = !user.is_active;
    await prisma.$executeRaw`UPDATE users SET is_active = ${newStatus} WHERE id = ${id}`;

    return res.json({
      success: true,
      data: { message: `Usuario ${newStatus ? 'activado' : 'desactivado'}`, is_active: newStatus },
    });
  } catch (error) {
    console.error('❌ Error en toggle admin:', error);
    return res.status(500).json({ success: false, error: 'Error al cambiar estado' });
  }
});

// ─── GET /api/admins/owners/without-place ────────────────
router.get('/api/admins/owners/without-place', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const owners = await prisma.$queryRaw`
      SELECT u.id, u.first_name, u.last_name, u.username, u.email, u.phone, u.created_at
      FROM users u
      WHERE u.role = 'user_place'
        AND (u.place_id IS NULL OR u.place_id NOT IN (SELECT id FROM places WHERE is_active = TRUE))
        AND u.is_active = TRUE
      ORDER BY u.created_at DESC
    `;
    return res.json({ success: true, data: owners, total: owners.length });
  } catch (error) {
    console.error('❌ Error en /api/admins/owners/without-place:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener propietarios sin lugar' });
  }
});

// ─── GET /stats/dashboard ─────────────────────────────────
router.get('/stats/dashboard', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const [{ c: totalUsers }]   = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM users WHERE role IS NULL`);
    const [{ c: totalPlaces }]  = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM places WHERE is_active = TRUE`);
    const [{ c: totalScans }]   = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans`);
    const [{ c: totalRewards }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards`);

    const placesByType = serializeRaw(await prisma.$queryRaw`SELECT tipo, COUNT(*)::int as count FROM places WHERE is_active = TRUE GROUP BY tipo`);
    const scansByDay   = serializeRaw(await prisma.$queryRaw`SELECT created_at::date AS date, COUNT(*)::int as count FROM scans GROUP BY created_at::date ORDER BY date ASC`);
    const topPlaces    = serializeRaw(await prisma.$queryRaw`
      SELECT p.id, p.name, p.tipo, p.lugar, COUNT(s.id)::int as total_scans
      FROM places p LEFT JOIN scans s ON p.id = s.place_id
      WHERE p.is_active = TRUE
      GROUP BY p.id ORDER BY total_scans DESC LIMIT 10
    `);

    return res.json({
      success: true,
      data: {
        stats: { users: totalUsers, places: totalPlaces, scans: totalScans, rewards: totalRewards },
        scansByDay,
        topPlaces,
        placesByType: placesByType.reduce((acc, item) => { acc[item.tipo] = item.count; return acc; }, {}),
      },
    });
  } catch (error) {
    console.error('❌ Error en /stats/dashboard:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener estadísticas' });
  }
});

module.exports = router;
