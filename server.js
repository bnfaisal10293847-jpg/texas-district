const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

const publicDir = path.join(__dirname, 'public');
const ADMIN_EMAIL = 'bnfaisal10293847@gmail.com';

// Serve static files
app.use(express.static(publicDir));

// Clean routes
app.get('/', (req, res) => res.sendFile(path.join(publicDir, 'index.html')));
app.get('/rules', (req, res) => res.sendFile(path.join(publicDir, 'rules.html')));
app.get('/creators', (req, res) => res.sendFile(path.join(publicDir, 'creators.html')));
app.get('/jobs', (req, res) => res.sendFile(path.join(publicDir, 'jobs.html')));
app.get('/store', (req, res) => res.sendFile(path.join(publicDir, 'store.html')));
app.get('/admin-login', (req, res) => res.sendFile(path.join(publicDir, 'admin-login.html')));

// Admin check route
app.get('/admin-check', (req, res) => {
    const email = (req.query.email || '').trim().toLowerCase();
    if (email === ADMIN_EMAIL) {
        res.sendFile(path.join(publicDir, 'admin-dashboard.html'));
    } else {
        res.sendFile(path.join(publicDir, 'admin-check.html'));
    }
});

app.listen(PORT, () => {
    console.log(`✅ Texas District server running at http://localhost:${PORT}`);
});

module.exports = app;
