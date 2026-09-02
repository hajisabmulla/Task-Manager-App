const { query } = require('../config/database');

class TaskRepository {
  async create({ title, description, status, assigneeId, createdById, dueDate }) {
    const result = await query(
      `INSERT INTO tasks (title, description, status, assignee_id, created_by_id, due_date)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [title, description || null, status || 'TODO', assigneeId || null, createdById, dueDate]
    );
    return this.findById(result.insertId);
  }

  async findById(id) {
    const rows = await query(
      `SELECT 
        t.id, t.title, t.description, t.status, t.due_date, t.created_at, t.updated_at,
        u_assignee.id as assignee_id, u_assignee.name as assignee_name, u_assignee.email as assignee_email,
        u_creator.id as creator_id, u_creator.name as creator_name, u_creator.email as creator_email
       FROM tasks t
       LEFT JOIN users u_assignee ON t.assignee_id = u_assignee.id
       LEFT JOIN users u_creator ON t.created_by_id = u_creator.id
       WHERE t.id = ?
       LIMIT 1`,
      [id]
    );

    if (!rows || rows.length === 0) return null;

    const row = rows[0];
    return this._mapRowToTask(row);
  }

  async findAll({ page = 1, limit = 10, status, search, sortBy = 'due_date', sortOrder = 'ASC' }) {
    const whereClauses = [];
    const params = [];

    if (status) {
      whereClauses.push('t.status = ?');
      params.push(status);
    }

    if (search && search.trim() !== '') {
      whereClauses.push('t.title LIKE ?');
      params.push(`%${search.trim()}%`);
    }

    const whereSql = whereClauses.length > 0 ? `WHERE ${whereClauses.join(' AND ')}` : '';

    // Allowed sort columns to prevent SQL injection
    const sortColumnMap = {
      dueDate: 't.due_date',
      due_date: 't.due_date',
      createdAt: 't.created_at',
      created_at: 't.created_at',
      title: 't.title',
      status: 't.status',
    };

    const actualSortCol = sortColumnMap[sortBy] || 't.due_date';
    const actualSortOrder = (sortOrder || 'ASC').toUpperCase() === 'DESC' ? 'DESC' : 'ASC';

    // Count total matching tasks
    const countRows = await query(
      `SELECT COUNT(*) as total FROM tasks t ${whereSql}`,
      params
    );
    const total = countRows[0].total;

    // Fetch paginated tasks
    const offset = (page - 1) * limit;
    const fetchParams = [...params, Number(limit), Number(offset)];

    const rows = await query(
      `SELECT 
        t.id, t.title, t.description, t.status, t.due_date, t.created_at, t.updated_at,
        u_assignee.id as assignee_id, u_assignee.name as assignee_name, u_assignee.email as assignee_email,
        u_creator.id as creator_id, u_creator.name as creator_name, u_creator.email as creator_email
       FROM tasks t
       LEFT JOIN users u_assignee ON t.assignee_id = u_assignee.id
       LEFT JOIN users u_creator ON t.created_by_id = u_creator.id
       ${whereSql}
       ORDER BY ${actualSortCol} ${actualSortOrder}, t.id DESC
       LIMIT ? OFFSET ?`,
      fetchParams
    );

    const tasks = rows.map((r) => this._mapRowToTask(r));
    const totalPages = Math.ceil(total / limit) || 1;

    return {
      tasks,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        totalPages,
      },
    };
  }

  async update(id, fields) {
    const setClauses = [];
    const params = [];

    if (fields.title !== undefined) {
      setClauses.push('title = ?');
      params.push(fields.title);
    }
    if (fields.description !== undefined) {
      setClauses.push('description = ?');
      params.push(fields.description);
    }
    if (fields.status !== undefined) {
      setClauses.push('status = ?');
      params.push(fields.status);
    }
    if (fields.assigneeId !== undefined) {
      setClauses.push('assignee_id = ?');
      params.push(fields.assigneeId);
    }
    if (fields.dueDate !== undefined) {
      setClauses.push('due_date = ?');
      params.push(fields.dueDate);
    }

    if (setClauses.length === 0) {
      return this.findById(id);
    }

    params.push(id);
    await query(`UPDATE tasks SET ${setClauses.join(', ')} WHERE id = ?`, params);
    return this.findById(id);
  }

  async delete(id) {
    const result = await query('DELETE FROM tasks WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }

  _mapRowToTask(row) {
    // Format date string as YYYY-MM-DD
    let formattedDueDate = row.due_date;
    if (row.due_date instanceof Date) {
      const d = row.due_date;
      const year = d.getFullYear();
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      formattedDueDate = `${year}-${month}-${day}`;
    } else if (typeof row.due_date === 'string') {
      formattedDueDate = row.due_date.substring(0, 10);
    }

    return {
      id: row.id,
      title: row.title,
      description: row.description,
      status: row.status,
      dueDate: formattedDueDate,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      assignee: row.assignee_id
        ? {
            id: row.assignee_id,
            name: row.assignee_name,
            email: row.assignee_email,
          }
        : null,
      createdBy: row.creator_id
        ? {
            id: row.creator_id,
            name: row.creator_name,
            email: row.creator_email,
          }
        : null,
    };
  }
}

module.exports = new TaskRepository();
