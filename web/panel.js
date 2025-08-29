
const BASE = '/evoapi';
let TOKEN = localStorage.getItem('evoapi_token') || '';

document.getElementById('token').value = TOKEN;
document.getElementById('saveToken').onclick = () => {
  TOKEN = document.getElementById('token').value.trim();
  localStorage.setItem('evoapi_token', TOKEN);
  alert('Token saved.');
};

async function api(path) {
  const url = `${BASE}${path}${path.includes('?') ? '&' : '?'}token=${encodeURIComponent(TOKEN)}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error('Request failed');
  return await res.json();
}

async function refresh() {
  const data = await api('/api/players');
  const rows = document.getElementById('rows');
  rows.innerHTML = '';
  (data.players || []).forEach(p => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${p.id}</td>
      <td>${p.name}</td>
      <td>${p.group}</td>
      <td class="action">
        <select id="g-${p.id}">
          <option value="owner">owner</option>
          <option value="admin">admin</option>
          <option value="mod">mod</option>
          <option value="user" selected>user</option>
        </select>
        <button data-id="${p.id}">Apply</button>
      </td>`;
    rows.appendChild(tr);
    tr.querySelector('select').value = p.group || 'user';
    tr.querySelector('button').onclick = async (e) => {
      const id = e.target.getAttribute('data-id');
      const group = tr.querySelector('select').value;
      const r = await api(`/api/setgroup?id=${id}&group=${group}`);
      if (r.ok) alert('Group set.'); else alert('Failed: ' + (r.error || 'unknown'));
    };
  });
}

document.getElementById('refresh').onclick = refresh;
document.getElementById('setWatermark').onclick = async () => {
  const text = document.getElementById('watermark').value.trim();
  if (!text) return alert('Enter text first.');
  const r = await api(`/api/watermark?text=${encodeURIComponent(text)}`);
  if (r.ok) alert('Broadcasted!'); else alert('Failed.');
};
document.getElementById('reloadPerms').onclick = async () => {
  const r = await api('/api/reload');
  if (r.ok) alert('Reapplied.'); else alert('Failed.');
};

refresh().catch(() => {});
