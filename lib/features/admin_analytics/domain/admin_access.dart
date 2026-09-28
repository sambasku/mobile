/// Akses halaman Analitik mobile - lebih ketat dari console
/// (console juga mengizinkan reviewer).
bool canAccessAdminAnalytics(String? role) =>
    role == 'admin' || role == 'root';
