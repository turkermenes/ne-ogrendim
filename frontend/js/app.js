// ============================================
// Bugün Ne Öğrendim? — Frontend Application
// ============================================

const API_URL = '/api';

// ---------- DOM Elements ----------
const postForm = document.getElementById('postForm');
const authorInput = document.getElementById('authorInput');
const contentInput = document.getElementById('contentInput');
const charCount = document.getElementById('charCount');
const submitBtn = document.getElementById('submitBtn');
const timeline = document.getElementById('timeline');
const toastContainer = document.getElementById('toastContainer');

// ---------- Constants ----------
const MAX_CHARS = 140;
const REFRESH_INTERVAL = 30000; // 30 seconds

// ---------- Init ----------
document.addEventListener('DOMContentLoaded', () => {
    fetchPosts();
    setupFormHandler();
    setupCharCounter();

    // Auto-refresh posts
    setInterval(fetchPosts, REFRESH_INTERVAL);

    // Restore author name from localStorage
    const savedAuthor = localStorage.getItem('gunluk_author');
    if (savedAuthor) {
        authorInput.value = savedAuthor;
    }
});

// ---------- Form Handler ----------
function setupFormHandler() {
    postForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const content = contentInput.value.trim();
        const author = authorInput.value.trim();

        if (!content || !author) {
            showToast('Lütfen tüm alanları doldurun.', 'error');
            return;
        }

        if (content.length > MAX_CHARS) {
            showToast('İçerik çok uzun!', 'error');
            return;
        }

        submitBtn.disabled = true;

        try {
            await createPost(content, author);
            localStorage.setItem('gunluk_author', author);
            contentInput.value = '';
            updateCharCounter();
            showToast('Paylaşımın yayınlandı! ✨', 'success');
            await fetchPosts();
        } catch (err) {
            showToast('Bir hata oluştu. Tekrar dene.', 'error');
            console.error('Create post error:', err);
        } finally {
            submitBtn.disabled = false;
        }
    });
}

// ---------- Character Counter ----------
function setupCharCounter() {
    contentInput.addEventListener('input', updateCharCounter);
    updateCharCounter();
}

function updateCharCounter() {
    const remaining = MAX_CHARS - contentInput.value.length;
    charCount.textContent = remaining;

    charCount.classList.remove('warning', 'danger');

    if (remaining <= 10) {
        charCount.classList.add('danger');
    } else if (remaining <= 20) {
        charCount.classList.add('warning');
    }
}

// ---------- API Functions ----------
async function fetchPosts() {
    try {
        const res = await fetch(`${API_URL}/posts`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const posts = await res.json();
        renderPosts(posts);
    } catch (err) {
        console.error('Fetch posts error:', err);
        // Don't show toast on auto-refresh failures — only show empty state
        if (timeline.children.length === 0) {
            renderPosts([]);
        }
    }
}

async function createPost(content, author) {
    const res = await fetch(`${API_URL}/posts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content, author }),
    });

    if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.error || `HTTP ${res.status}`);
    }

    return res.json();
}

async function deletePost(id) {
    try {
        const res = await fetch(`${API_URL}/posts/${id}`, {
            method: 'DELETE',
        });

        if (!res.ok) throw new Error(`HTTP ${res.status}`);

        showToast('Paylaşım silindi.', 'success');
        await fetchPosts();
    } catch (err) {
        showToast('Silme işlemi başarısız oldu.', 'error');
        console.error('Delete post error:', err);
    }
}

// ---------- Render ----------
function renderPosts(posts) {
    if (!posts || posts.length === 0) {
        timeline.innerHTML = `
            <div class="empty-state">
                <span class="empty-state__icon">🚀</span>
                <p class="empty-state__title">Henüz bir paylaşım yok.</p>
                <p class="empty-state__text">İlk sen paylaş!</p>
            </div>
        `;
        return;
    }

    timeline.innerHTML = posts
        .map((post, index) => {
            const delay = Math.min(index * 0.06, 0.6); // stagger, cap at 600ms
            const authorName = escapeHtml(post.author || 'Anonim');
            const content = escapeHtml(post.content);
            const time = formatDate(post.created_at || post.createdAt);
            const postId = post.id || post._id;

            return `
                <article class="post-card" style="animation-delay: ${delay}s">
                    <p class="post-card__content">${content}</p>
                    <div class="post-card__meta">
                        <div class="post-card__info">
                            <span class="post-card__author">${authorName}</span>
                            <span class="post-card__dot">●</span>
                            <span class="post-card__time">${time}</span>
                        </div>
                        <button class="btn-delete" onclick="deletePost('${postId}')" title="Sil">
                            Sil ✕
                        </button>
                    </div>
                </article>
            `;
        })
        .join('');
}

// ---------- Date Formatting (Turkish) ----------
function formatDate(dateString) {
    if (!dateString) return '';

    const now = new Date();
    const date = new Date(dateString);
    const diffMs = now - date;
    const diffSec = Math.floor(diffMs / 1000);
    const diffMin = Math.floor(diffSec / 60);
    const diffHour = Math.floor(diffMin / 60);
    const diffDay = Math.floor(diffHour / 24);

    if (diffSec < 60) return 'az önce';
    if (diffMin < 60) return `${diffMin} dakika önce`;
    if (diffHour < 24) return `${diffHour} saat önce`;
    if (diffDay === 1) return 'dün';
    if (diffDay < 7) return `${diffDay} gün önce`;

    // Full date for older posts
    return date.toLocaleDateString('tr-TR', {
        day: 'numeric',
        month: 'long',
        year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
    });
}

// ---------- Toast Notifications ----------
function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast toast--${type}`;
    toast.innerHTML = `
        <span>${type === 'success' ? '✓' : '✕'}</span>
        <span>${escapeHtml(message)}</span>
    `;

    toastContainer.appendChild(toast);

    // Auto-remove after 3.5 seconds
    setTimeout(() => {
        toast.classList.add('toast--exit');
        toast.addEventListener('animationend', () => toast.remove());
    }, 3500);
}

// ---------- Utility ----------
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
