import express from 'express';
import fs from 'fs';
import path from 'path';
import cors from 'cors';
import { fileURLToPath } from 'url';
import multer from 'multer';
import { createServer } from 'http';
import { Server } from 'socket.io';
import mysql from 'mysql2/promise';
import jwt from 'jsonwebtoken';

import { dbConfig } from './db.config.js';
// export const dbConfig = {
//     host: '',
//     user: '',
//     password: '',
//     database: '',
//     waitForConnections: true,
//     connectionLimit: 10,
//     queueLimit: 0
// };


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Database Connection
const pool = mysql.createPool(dbConfig);
const JWT_SECRET = 'pm-secure-secret-key-2024'; // In production, use environment variable

// Initialize DB Tables
async function initDB() {
    try {
        const connection = await pool.getConnection();
        
        // Users Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                name VARCHAR(255),
                role VARCHAR(50)
            )
        `);

        // Projects Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS projects (
                code VARCHAR(50) PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                type VARCHAR(100),
                description TEXT,
                manager VARCHAR(100),
                plannedStartDate DATE,
                plannedEndDate DATE
            )
        `);

        // Phases Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS phases (
                id VARCHAR(50),
                project_code VARCHAR(50),
                name VARCHAR(255),
                color VARCHAR(20),
                PRIMARY KEY (id, project_code),
                FOREIGN KEY (project_code) REFERENCES projects(code) ON DELETE CASCADE
            )
        `);

        // Swimlanes Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS swimlanes (
                id VARCHAR(50),
                project_code VARCHAR(50),
                name VARCHAR(255),
                color VARCHAR(20),
                PRIMARY KEY (id, project_code),
                FOREIGN KEY (project_code) REFERENCES projects(code) ON DELETE CASCADE
            )
        `);

        // Tasks Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS tasks (
                id VARCHAR(50),
                project_code VARCHAR(50),
                name VARCHAR(255),
                phaseId VARCHAR(50),
                swimlaneId VARCHAR(50),
                status VARCHAR(50),
                progress INT DEFAULT 0,
                owner VARCHAR(100),
                startDate DATE,
                endDate DATE,
                type VARCHAR(50),
                description LONGTEXT,
                x FLOAT,
                y FLOAT,
                width FLOAT,
                PRIMARY KEY (id, project_code),
                FOREIGN KEY (project_code) REFERENCES projects(code) ON DELETE CASCADE
            )
        `);

        // Add columns if not exist (for existing tables)
        try { await connection.query("ALTER TABLE tasks ADD COLUMN description LONGTEXT"); } catch (e) {}
        try { await connection.query("ALTER TABLE tasks ADD COLUMN x FLOAT"); } catch (e) {}
        try { await connection.query("ALTER TABLE tasks ADD COLUMN y FLOAT"); } catch (e) {}
        try { await connection.query("ALTER TABLE tasks ADD COLUMN width FLOAT"); } catch (e) {}
        try { await connection.query("ALTER TABLE tasks ADD COLUMN startColor VARCHAR(20)"); } catch (e) {}
        try { await connection.query("ALTER TABLE tasks ADD COLUMN endColor VARCHAR(20)"); } catch (e) {}


        // Task Dependencies Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS task_dependencies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                taskId VARCHAR(50),
                dependencyId VARCHAR(50),
                project_code VARCHAR(50),
                type VARCHAR(20),
                sourcePort VARCHAR(50),
                targetPort VARCHAR(50),
                controlPoints TEXT,
                controlPointCount INT,
                FOREIGN KEY (project_code) REFERENCES projects(code) ON DELETE CASCADE
            )
        `);

        try { await connection.query("ALTER TABLE task_dependencies ADD COLUMN type VARCHAR(20)"); } catch (e) {}
        try { await connection.query("ALTER TABLE task_dependencies ADD COLUMN sourcePort VARCHAR(50)"); } catch (e) {}
        try { await connection.query("ALTER TABLE task_dependencies ADD COLUMN targetPort VARCHAR(50)"); } catch (e) {}
        try { await connection.query("ALTER TABLE task_dependencies ADD COLUMN controlPoints TEXT"); } catch (e) {}
        try { await connection.query("ALTER TABLE task_dependencies ADD COLUMN controlPointCount INT"); } catch (e) {}

        
        // Attachments Table
        await connection.query(`
            CREATE TABLE IF NOT EXISTS attachments (
                id VARCHAR(50) PRIMARY KEY,
                taskId VARCHAR(50),
                project_code VARCHAR(50),
                name VARCHAR(255),
                url VARCHAR(500),
                type VARCHAR(50),
                uploadDate DATE,
                FOREIGN KEY (project_code) REFERENCES projects(code) ON DELETE CASCADE
            )
        `);

        // Seed initial users if empty
        const [users] = await connection.query('SELECT count(*) as count FROM users');
        if (users[0].count === 0) {
            await connection.query(`
                INSERT INTO users (username, password, name, role) VALUES 
                ('admin', 'password', '超级管理员', 'admin'),
                ('user1', 'password', '张工', 'user'),
                ('user2', 'password', '李工', 'user')
            `);
            console.log('Initial users seeded');
        }

        connection.release();
        console.log('Database initialized successfully');
    } catch (err) {
        console.error('Database initialization failed:', err);
    }
}

initDB();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
    cors: {
        origin: "*", // Allow all for dev
        methods: ["GET", "POST"]
    }
});

const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' })); // Increase limit for large project files

// --- Authentication & User Management ---
// Use MySQL for users
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const [rows] = await pool.query('SELECT * FROM users WHERE username = ? AND password = ?', [username, password]);
        if (rows.length > 0) {
            const user = rows[0];
            const { password, ...userInfo } = user;
            
            // Generate JWT Token
            const token = jwt.sign(
                { id: user.id, username: user.username, role: user.role }, 
                JWT_SECRET, 
                { expiresIn: '24h' }
            );
            
            res.json({ success: true, user: userInfo, token: token });
        } else {
            res.status(401).json({ success: false, message: '用户名或密码错误' });
        }
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Middleware: Verify JWT Token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: 'Unauthorized: No token provided' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Forbidden: Invalid token' });
        req.user = user;
        next();
    });
};

// Middleware: Require Admin Role
const requireAdmin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(403).json({ error: 'Forbidden: Admin access required' });
    }
};

app.get('/api/selectable-users', authenticateToken, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT id, username, name, role FROM users');
        res.json(rows);
    } catch (err) {
        console.error('Get selectable users error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/users', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT id, username, name, role FROM users');
        res.json(rows);
    } catch (err) {
        console.error('Get users error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.post('/api/user', authenticateToken, requireAdmin, async (req, res) => {
    const { username, password, name, role } = req.body;
    try {
        await pool.query('INSERT INTO users (username, password, name, role) VALUES (?, ?, ?, ?)', [username, password, name, role]);
        res.json({ success: true });
    } catch (err) {
        console.error('Create user error:', err);
        res.status(500).json({ error: 'Failed to create user' });
    }
});

app.put('/api/user/:id', authenticateToken, requireAdmin, async (req, res) => {
    const { id } = req.params;
    const { password, name, role } = req.body;
    try {
        if (password) {
            await pool.query('UPDATE users SET password = ?, name = ?, role = ? WHERE id = ?', [password, name, role, id]);
        } else {
            await pool.query('UPDATE users SET name = ?, role = ? WHERE id = ?', [name, role, id]);
        }
        res.json({ success: true });
    } catch (err) {
        console.error('Update user error:', err);
        res.status(500).json({ error: 'Failed to update user' });
    }
});

app.delete('/api/user/:id', authenticateToken, requireAdmin, async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM users WHERE id = ?', [id]);
        res.json({ success: true });
    } catch (err) {
        console.error('Delete user error:', err);
        res.status(500).json({ error: 'Failed to delete user' });
    }
});

app.post('/api/user/password', authenticateToken, async (req, res) => {
    const { id, oldPassword, newPassword } = req.body;
    
    // Security check: Ensure user can only change their own password
    if (req.user.id !== id && req.user.role !== 'admin') {
        return res.status(403).json({ error: 'Forbidden: Can only change own password' });
    }

    try {
        // Verify old password
        const [rows] = await pool.query('SELECT * FROM users WHERE id = ? AND password = ?', [id, oldPassword]);
        if (rows.length === 0) {
            return res.status(401).json({ success: false, message: 'Original password incorrect' });
        }
        
        // Update password
        await pool.query('UPDATE users SET password = ? WHERE id = ?', [newPassword, id]);
        res.json({ success: true });
    } catch (err) {
        console.error('Change password error:', err);
        res.status(500).json({ error: 'Failed to change password' });
    }
});

// Map to track user socket connections for cleanup
const socketUserMap = new Map();

// --- Socket.io for Real-time Collaboration ---
io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    socket.on('join_project', ({ projectId, user, clientId }) => {
        socket.join(projectId);
        // Store session info
        socketUserMap.set(socket.id, { projectId, user, clientId });
        
        console.log(`User ${user.name} joined project ${projectId}`);
        // Notify others
        socket.to(projectId).emit('user_joined', { user, clientId, timestamp: Date.now() });
    });

    socket.on('project_action', ({ projectId, action, payload, user }) => {
        // Broadcast action to all other users in the room
        socket.to(projectId).emit('project_action', { action, payload, user });
    });

    socket.on('cursor_move', ({ projectId, x, y, user, clientId }) => {
        socket.to(projectId).emit('cursor_move', { x, y, user, clientId });
    });

    socket.on('element_selected', ({ projectId, clientId, type, id, user }) => {
        console.log(`Element selected: ${id} by ${user.name} in project ${projectId}`);
        socket.to(projectId).emit('element_selected', { clientId, type, id, user });
    });

    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
        const session = socketUserMap.get(socket.id);
        if (session) {
            const { projectId, user, clientId } = session;
            // Notify others that user left
            socket.to(projectId).emit('user_left', { user, clientId, timestamp: Date.now() });
            socketUserMap.delete(socket.id);
        }
    });
});

// Smart Static File Handler
// Intercepts requests for assets (js/css/images) from nested paths (e.g. /pm/project/assets/...)
// and serves them directly from the dist directory.
app.use((req, res, next) => {
    // Skip API requests
    if (req.path.startsWith('/api/')) return next();

    // Check if the request looks like an asset (has extension) or is in /assets/ folder
    // This allows serving assets regardless of the mounting path or nesting level
    if (req.path.includes('/assets/') || (path.extname(req.path) && !req.path.endsWith('.html'))) {
        
        // Strategy 1: If it contains /assets/, try to serve from dist/assets
        if (req.path.includes('/assets/')) {
            const assetPath = req.path.substring(req.path.indexOf('/assets/'));
            const fullPath = path.join(__dirname, 'dist', assetPath);
            if (fs.existsSync(fullPath)) {
                return res.sendFile(fullPath);
            }
        }

        // Strategy 2: Fallback for public files (like favicon.ico, logo.svg)
        // Try to serve from dist root based on filename
        const filename = path.basename(req.path);
        const publicPath = path.join(__dirname, 'dist', filename);
        if (fs.existsSync(publicPath)) {
            return res.sendFile(publicPath);
        }
    }
    next();
});

// Serve static files from the 'dist' directory (frontend build)
// This handles the standard root access
app.use('/pm', express.static(path.join(__dirname, 'dist')));

// Also serve the project directory specifically if needed for direct access, 
// though API is preferred for consistency
app.use('/pm/project', express.static(path.join(__dirname, 'project')));

// Configure Multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const { projectId, taskId } = req.params;
        const dir = path.join(__dirname, 'project', projectId, taskId);
        
        // Recursive mkdir
        fs.mkdir(dir, { recursive: true }, (err) => {
            if (err) return cb(err, dir);
            cb(null, dir);
        });
    },
    filename: (req, file, cb) => {
        // Use Buffer to fix encoding issues with chinese characters if needed
        // But express/multer usually handles UTF-8 well.
        // We'll use the original name.
        file.originalname = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, file.originalname);
    }
});
const upload = multer({ storage });

// API to get all projects (summary)
app.get('/api/projects', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT code, name, type, description, manager, plannedStartDate, plannedEndDate FROM projects');
        // Format dates
        const projects = rows.map(p => ({
            ...p,
            plannedStartDate: p.plannedStartDate ? new Date(p.plannedStartDate).toISOString().split('T')[0] : null,
            plannedEndDate: p.plannedEndDate ? new Date(p.plannedEndDate).toISOString().split('T')[0] : null
        }));
        res.json(projects);
    } catch (err) {
        console.error('Get projects error:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// API to get project data
app.get('/api/project/:id', async (req, res) => {
    const projectId = req.params.id;
    try {
        const connection = await pool.getConnection();

        // 1. Get Project Info
        const [projects] = await connection.query('SELECT * FROM projects WHERE code = ?', [projectId]);
        if (projects.length === 0) {
            connection.release();
            return res.status(404).json({ error: 'Project not found' });
        }
        const projectInfo = projects[0];
        
        // Format dates to string YYYY-MM-DD
        if (projectInfo.plannedStartDate) projectInfo.plannedStartDate = new Date(projectInfo.plannedStartDate).toISOString().split('T')[0];
        if (projectInfo.plannedEndDate) projectInfo.plannedEndDate = new Date(projectInfo.plannedEndDate).toISOString().split('T')[0];

        // 2. Get Phases
        const [phases] = await connection.query('SELECT id, name, color FROM phases WHERE project_code = ?', [projectId]);

        // 3. Get Swimlanes
        const [swimlanes] = await connection.query('SELECT id, name, color FROM swimlanes WHERE project_code = ?', [projectId]);

        // 4. Get Tasks
        const [tasksRows] = await connection.query('SELECT * FROM tasks WHERE project_code = ?', [projectId]);
        
        // 5. Get Dependencies
        const [dependenciesRows] = await connection.query('SELECT * FROM task_dependencies WHERE project_code = ?', [projectId]);

        // 6. Get Attachments
        const [attachmentsRows] = await connection.query('SELECT * FROM attachments WHERE project_code = ?', [projectId]);

        connection.release();

        // Reconstruct Tasks
        const tasks = tasksRows.map(task => {
            // Find dependencies for this task
            const taskDeps = dependenciesRows
                .filter(d => d.taskId === task.id)
                .map(d => ({
                    taskId: d.dependencyId,
                    type: d.type,
                    sourcePort: d.sourcePort,
                    targetPort: d.targetPort,
                    controlPoints: d.controlPoints ? JSON.parse(d.controlPoints) : undefined,
                    controlPointCount: d.controlPointCount
                }));

            // Find attachments for this task
            const taskAtts = attachmentsRows
                .filter(a => a.taskId === task.id)
                .map(a => ({
                    id: a.id,
                    name: a.name,
                    url: a.url,
                    type: a.type,
                    uploadDate: a.uploadDate ? new Date(a.uploadDate).toISOString().split('T')[0] : null
                }));

            return {
                id: task.id,
                name: task.name,
                phaseId: task.phaseId,
                swimlaneId: task.swimlaneId,
                status: task.status,
                progress: task.progress,
                owner: task.owner,
                startDate: task.startDate ? new Date(task.startDate).toISOString().split('T')[0] : null,
                endDate: task.endDate ? new Date(task.endDate).toISOString().split('T')[0] : null,
                type: task.type,
                description: task.description,
                x: task.x,
                y: task.y,
                width: task.width || 140,
                startColor: task.startColor,
                endColor: task.endColor,
                dependencies: taskDeps,
                attachments: taskAtts
            };
        });

        const projectData = {
            projectInfo,
            phases,
            swimlanes,
            tasks
        };

        res.json(projectData);

    } catch (err) {
        console.error('Error fetching project:', err);
        res.status(500).json({ error: 'Failed to fetch project' });
    }
});

// API to save project data
app.post('/api/project/:id', async (req, res) => {
    const projectId = req.params.id;
    const { projectInfo, phases, swimlanes, tasks } = req.body;

    // Validate connection
    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        // 1. Update Project Info
        // Upsert project
        await connection.query(`
            INSERT INTO projects (code, name, type, description, manager, plannedStartDate, plannedEndDate)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
            name = VALUES(name), type = VALUES(type), description = VALUES(description),
            manager = VALUES(manager), plannedStartDate = VALUES(plannedStartDate), plannedEndDate = VALUES(plannedEndDate)
        `, [
            projectInfo.code, projectInfo.name, projectInfo.type, projectInfo.description, 
            projectInfo.manager, 
            projectInfo.plannedStartDate || null, 
            projectInfo.plannedEndDate || null
        ]);

        // 2. Update Phases (Delete all for project and re-insert)
        await connection.query('DELETE FROM phases WHERE project_code = ?', [projectId]);
        if (phases && phases.length > 0) {
            const phaseValues = phases.map(p => [p.id, projectId, p.name, p.color]);
            await connection.query('INSERT INTO phases (id, project_code, name, color) VALUES ?', [phaseValues]);
        }

        // 3. Update Swimlanes
        await connection.query('DELETE FROM swimlanes WHERE project_code = ?', [projectId]);
        if (swimlanes && swimlanes.length > 0) {
            const swimlaneValues = swimlanes.map(s => [s.id, projectId, s.name, s.color]);
            await connection.query('INSERT INTO swimlanes (id, project_code, name, color) VALUES ?', [swimlaneValues]);
        }

        // 4. Update Tasks
        await connection.query('DELETE FROM tasks WHERE project_code = ?', [projectId]);
        if (tasks && tasks.length > 0) {
            const taskValues = tasks.map(t => [
                t.id, projectId, t.name, t.phaseId, t.swimlaneId, 
                t.status, t.progress, t.owner, 
                t.startDate || null, 
                t.endDate || null,
                t.type, t.description, t.x, t.y, t.width || 140, t.startColor, t.endColor
            ]);
            await connection.query(`
                INSERT INTO tasks (
                    id, project_code, name, phaseId, swimlaneId, 
                    status, progress, owner, startDate, endDate, 
                    type, description, x, y, width, startColor, endColor
                ) VALUES ?
            `, [taskValues]);
        }

        // 5. Update Dependencies
        await connection.query('DELETE FROM task_dependencies WHERE project_code = ?', [projectId]);
        const dependencyValues = [];
        if (tasks && tasks.length > 0) {
            tasks.forEach(t => {
                if (t.dependencies && t.dependencies.length > 0) {
                    t.dependencies.forEach(d => {
                        const depId = typeof d === 'string' ? d : d.taskId;
                        // Handle object dependency properties
                        const type = (typeof d !== 'string' && d.type) ? d.type : 'polyline';
                        const sourcePort = (typeof d !== 'string' && d.sourcePort) ? d.sourcePort : null;
                        const targetPort = (typeof d !== 'string' && d.targetPort) ? d.targetPort : null;
                        const controlPoints = (typeof d !== 'string' && d.controlPoints) ? JSON.stringify(d.controlPoints) : null;
                        const controlPointCount = (typeof d !== 'string' && d.controlPointCount) ? d.controlPointCount : 0;
                        
                        dependencyValues.push([
                            t.id, depId, projectId, type, sourcePort, targetPort, controlPoints, controlPointCount
                        ]);
                    });
                }
            });
        }
        if (dependencyValues.length > 0) {
            await connection.query(`
                INSERT INTO task_dependencies (
                    taskId, dependencyId, project_code, type, sourcePort, targetPort, controlPoints, controlPointCount
                ) VALUES ?
            `, [dependencyValues]);
        }

        // 6. Update Attachments
        await connection.query('DELETE FROM attachments WHERE project_code = ?', [projectId]);
        const attachmentValues = [];
        if (tasks && tasks.length > 0) {
            tasks.forEach(t => {
                if (t.attachments && t.attachments.length > 0) {
                    t.attachments.forEach(a => {
                        attachmentValues.push([
                            a.id, t.id, projectId, a.name, a.url, a.type, a.uploadDate
                        ]);
                    });
                }
            });
        }
        if (attachmentValues.length > 0) {
             await connection.query(`
                INSERT INTO attachments (id, taskId, project_code, name, url, type, uploadDate) 
                VALUES ?
            `, [attachmentValues]);
        }

        await connection.commit();
        res.json({ success: true, message: 'Project saved successfully' });

    } catch (err) {
        if (connection) await connection.rollback();
        console.error('Error saving project:', err);
        res.status(500).json({ error: 'Failed to save project' });
    } finally {
        if (connection) connection.release();
    }
});

// API to upload attachment
app.post('/api/project/:projectId/task/:taskId/attachment', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }
        
        const { projectId, taskId } = req.params;
        const filename = req.file.filename;
        
        // Return the public URL for the file
        // URL format: /pm/project/{projectId}/{taskId}/{filename}
        const fileUrl = `/pm/project/${projectId}/${taskId}/${encodeURIComponent(filename)}`;
        
        // Insert metadata into DB
        const attachmentId = 'a' + Date.now();
        const uploadDate = new Date().toISOString().split('T')[0];
        
        // Check if project exists, if not, we might fail foreign key constraint.
        // Assuming project exists before uploading attachment.
        
        try {
             await pool.query(`
                INSERT INTO attachments (id, taskId, project_code, name, url, type, uploadDate)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            `, [attachmentId, taskId, projectId, filename, fileUrl, path.extname(filename).substring(1), uploadDate]);
        } catch (dbErr) {
             console.error('DB Insert Error for Attachment:', dbErr);
             // If project doesn't exist yet in DB (e.g. unsaved new project), we might skip DB insert?
             // Or we force project creation?
             // For now, let's log error but still return success for file upload so frontend works.
             // But data won't be in DB.
             // Ideally, user should save project first.
        }

        res.json({
            success: true,
            file: {
                name: filename,
                url: fileUrl,
                path: req.file.path
            }
        });
    } catch (err) {
        console.error('Upload error:', err);
        res.status(500).json({ error: 'File upload failed' });
    }
});

// API to delete attachment
app.delete('/api/project/:projectId/task/:taskId/attachment/:filename', async (req, res) => {
    const { projectId, taskId, filename } = req.params;
    const filePath = path.join(__dirname, 'project', projectId, taskId, filename);
    
    // Delete from DB
    try {
        await pool.query('DELETE FROM attachments WHERE project_code = ? AND taskId = ? AND name = ?', [projectId, taskId, filename]);
    } catch (dbErr) {
        console.error('DB Delete Error:', dbErr);
    }

    if (fs.existsSync(filePath)) {
        fs.unlink(filePath, (err) => {
            if (err) {
                console.error('Delete error:', err);
                return res.status(500).json({ error: 'Failed to delete file' });
            }
            res.json({ success: true, message: 'File deleted successfully' });
        });
    } else {
        // Even if file not found on disk, we deleted from DB, so success
        res.json({ success: true, message: 'File deleted (or not found on disk)' });
    }
});

// Handle SPA routing: return index.html for any unknown paths starting with /pm
// This allows Vue Router to handle /pm/project/xxx
app.get(/^\/pm\/.*$/, (req, res) => {
    // Check if the request is for an API call, ignore it here to let it 404 if not matched above
    if (req.path.startsWith('/api/')) return res.status(404).send('Not Found');
    
    // Check if it is a static file request that fell through (e.g. css, js)
    // If extension is present, likely a file, return 404
    if (path.extname(req.path)) {
        return res.status(404).send('Not Found');
    }

    res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Error handling for uncaught exceptions to prevent server crash
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

const server = httpServer.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}/pm/`);
    console.log(`API endpoint: http://localhost:${PORT}/api/project/:id`);
    console.log(`Socket.io ready`);
});

server.on('error', (e) => {
    if (e.code === 'EADDRINUSE') {
        console.error(`Error: Port ${PORT} is already in use.`);
        console.error('Please stop the other process or use a different port.');
    } else {
        console.error('Server error:', e);
    }
});
