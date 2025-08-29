
const card = document.getElementById('card');
const titleEl = document.getElementById('title');
const msgEl = document.getElementById('message');
const closeBtn = document.getElementById('close');
const toasts = document.getElementById('toasts');

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.action === 'showUI') {
    titleEl.textContent = data.title || 'EvoAPI';
    msgEl.textContent = data.message || '';
    card.removeAttribute('hidden');
  }
  if (data.action === 'toast') {
    addToast(data.message || '', data.ntype || 'info');
  }
});

function addToast(text, type) {
  const el = document.createElement('div');
  el.className = 'toast ' + (type || 'info');
  el.textContent = text;
  toasts.appendChild(el);
  setTimeout(() => {
    el.style.opacity = '0';
    setTimeout(() => el.remove(), 250);
  }, 2500);
}

closeBtn.addEventListener('click', () => {
  card.setAttribute('hidden', '');
  fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' });
});
