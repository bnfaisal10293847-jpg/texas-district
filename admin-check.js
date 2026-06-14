export default function handler(req, res) {
    const email = (req.query.email || '').trim().toLowerCase();
    const ADMIN_EMAIL = 'bnfaisal10293847@gmail.com';

    if (email === ADMIN_EMAIL) {
        res.redirect(302, '/admin-dashboard.html');
    } else {
        res.redirect(302, '/admin-check.html');
    }
}
