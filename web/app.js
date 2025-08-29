
const root = document.getElementById('root');
const toast = document.getElementById('toast');
const closeBtn = document.getElementById('close');
const playersEl = document.getElementById('players');
const refreshBtn = document.getElementById('refresh');

let state = { players: [], filtered: [], selectedId: null };

function showToast(msg) {
  toast.textContent = msg;
  toast.hidden = false;
  setTimeout(() => toast.hidden = true, 2500);
}

window.addEventListener('message', (e) => {
  const data = e.data || {};
  console.log('[EvoAPI NUI] Message:', data);
  if (data.action === 'openPanel') {
    root.hidden = false;
    root.style.display = 'flex';
    document.body.style.pointerEvents = 'auto';
    loadPlayers();
  } else if (data.action === 'closePanel') {
    root.hidden = true;
    document.body.style.pointerEvents = 'none';
  }
});

// ESC closes
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      body: JSON.stringify({ close: true })
    });
    root.hidden = true;
    document.body.style.pointerEvents = 'none';
  }
});

// Close button
closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    body: JSON.stringify({ close: true })
  });
  root.hidden = true;
  document.body.style.pointerEvents = 'none';
});

// Fetch NUI
async function nui(name, data) {
  const res = await fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {})
  });
  return await res.json();
}

// Load players
async function loadPlayers() {
  const res = await nui('fetchPlayers');
  if (!res.ok) return showToast('Failed to load players');
  state.players = res.players || [];
  renderPlayers();
}

// Render player list
function renderPlayers() {
  playersEl.innerHTML = state.players.map(p => `
    <div class="row" data-id="${p.id}">
      <div>${p.id}</div><div>${p.name}</div><div>${p.ping}</div><div>${p.group}</div><div>${p.identifier}</div>
    </div>
  `).join('');
}

// Reload button
if (refreshBtn) refreshBtn.addEventListener('click', loadPlayers);
