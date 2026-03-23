const vscode = require('vscode');
const fs = require('fs');
const os = require('os');

// Machine config written by install.sh to ~/.claude/machine-config.json
function loadMachineConfig() {
  try {
    return JSON.parse(fs.readFileSync(os.homedir() + '/.claude/machine-config.json', 'utf8'));
  } catch (_) {
    return {};
  }
}

const MACHINE = loadMachineConfig();
const WORKLOG_PATH = MACHINE.worklog_path || '/srv/wiki-content/worklog.md';
const ASANA_TASKS_PATH = MACHINE.asana_tasks_path || '/srv/wiki-content/asana-tasks.json';

const SERVICES = [
  { name: 'Jellyseerr',  url: 'https://requests.fake-dom.com', desc: 'Media requests' },
  { name: 'Radarr',      url: 'http://192.168.1.100:7878',     desc: 'Movies' },
  { name: 'Sonarr',      url: 'http://192.168.1.100:8989',     desc: 'TV' },
  { name: 'Lidarr',      url: 'http://192.168.1.100:8686',     desc: 'Music' },
  { name: 'Prowlarr',    url: 'http://192.168.1.100:9696',     desc: 'Indexers' },
  { name: 'Stash',       url: 'http://192.168.1.100:9998',     desc: 'Adult media' },
  { name: 'Booklore',    url: 'http://192.168.1.100:6060',     desc: 'Books' },
  { name: 'Wiki',        url: 'http://192.168.1.100:3000',     desc: 'Documentation' },
];


const CLAUDE_SKILLS = [
  { name: '/wrap-up',       desc: 'Update worklog, complete Asana tasks, note outstanding items', file: '/home/scon/.claude/skills/wrap-up/SKILL.md' },
  { name: '/update-config', desc: 'Configure Claude Code settings, hooks, permissions, env vars' },
  { name: '/simplify',      desc: 'Review changed code for reuse, quality, and efficiency' },
  { name: '/loop',          desc: 'Run a prompt or command on a recurring interval' },
  { name: '/claude-api',    desc: 'Build apps with the Claude API / Anthropic SDK' },
];

function loadAsanaTasks() {
  try {
    const data = JSON.parse(fs.readFileSync(ASANA_TASKS_PATH, 'utf8'));
    return data.tasks || [];
  } catch (_) {
    return [];
  }
}

function findAsanaUrl(taskText, asanaTasks) {
  const normalize = s => s.toLowerCase().replace(/[^a-z0-9 ]/g, ' ').replace(/\s+/g, ' ').trim();
  const needle = normalize(taskText);

  // 1. Exact match
  for (const t of asanaTasks) {
    if (normalize(t.name) === needle) return t.url;
  }

  // 2. One contains the other
  for (const t of asanaTasks) {
    const name = normalize(t.name);
    if (name.includes(needle) || needle.includes(name)) return t.url;
  }

  // 3. Word overlap (≥60% of meaningful words match)
  const words = needle.split(' ').filter(w => w.length > 3);
  if (!words.length) return null;
  let best = null, bestScore = 0;
  for (const t of asanaTasks) {
    const name = normalize(t.name);
    const matches = words.filter(w => name.includes(w)).length;
    const score = matches / words.length;
    if (score > bestScore && score >= 0.6) { bestScore = score; best = t.url; }
  }
  return best;
}

function parseWorklog() {
  try {
    const raw = fs.readFileSync(WORKLOG_PATH, 'utf8');
    const body = raw.replace(/^---[\s\S]*?---\n/, '');
    const sections = body.split(/\n---\n/);
    const sessions = sections.filter(s => /##\s+\d{4}-\d{2}-\d{2}/.test(s));
    if (!sessions.length) return null;
    const latest = parseSession(sessions[sessions.length - 1]);
    const recent = sessions.slice(-5).reverse().map(s => {
      const titleLine = s.split('\n').find(l => /^##\s+/.test(l)) || '';
      return titleLine.replace(/^##\s+/, '').trim();
    });
    return { ...latest, recent };
  } catch (_) {
    return null;
  }
}

function parseSession(text) {
  const lines = text.split('\n');

  // Title from ## header
  const titleLine = lines.find(l => /^##\s+/.test(l)) || '';
  const title = titleLine.replace(/^##\s+/, '').trim();

  // Outstanding tasks table
  const outIdx = lines.findIndex(l => /outstanding|next session/i.test(l));
  const tasks = [];
  if (outIdx >= 0) {
    for (let i = outIdx + 1; i < lines.length; i++) {
      const line = lines[i];
      if (!line.startsWith('|')) continue;
      if (/---/.test(line) || /priority/i.test(line)) continue;
      const cols = line.split('|').map(c => c.trim()).filter(Boolean);
      if (cols.length >= 2) tasks.push({ priority: cols[0], task: cols[1] });
    }
  }

  // Work completed bullets (### headers + content)
  const completedIdx = lines.findIndex(l => /work completed/i.test(l));
  const highlights = [];
  if (completedIdx >= 0) {
    for (let i = completedIdx + 1; i < lines.length && i < completedIdx + 30; i++) {
      const line = lines[i];
      if (/^####\s+/.test(line)) highlights.push(line.replace(/^####\s+/, '').trim());
      if (/^### outstanding/i.test(line)) break;
    }
  }

  return { title, tasks, highlights };
}

function priorityColor(p) {
  if (/🔴/.test(p)) return '#f87171';
  if (/🔧/.test(p)) return '#fb923c';
  if (/📚/.test(p)) return '#60a5fa';
  return '#a3a3a3';
}

function buildHtml(session, asanaTasks) {
  const tasksHtml = session && session.tasks.length
    ? session.tasks.map(t => {
        const url = findAsanaUrl(t.task, asanaTasks);
        const taskContent = url
          ? `<a href="${url}" class="task-link">${escHtml(t.task)}</a>`
          : `<span class="task-text">${escHtml(t.task)}</span>`;
        return `
        <div class="task-row">
          <span class="task-priority" style="color:${priorityColor(t.priority)}">${escHtml(t.priority)}</span>
          ${taskContent}
        </div>`;
      }).join('')
    : '<p class="muted">No outstanding tasks found.</p>';

  const servicesHtml = SERVICES.map(s => `
    <a href="${s.url}" class="service-card">
      <div class="service-name">${s.name}</div>
      <div class="service-desc">${s.desc}</div>
    </a>`).join('');

  const WORKLOG_URL = MACHINE.worklog_url || '#';
  const recentSessionsHtml = session && session.recent && session.recent.length
    ? session.recent.map(title => `
        <a href="${WORKLOG_URL}" class="session-link">${escHtml(title)}</a>`).join('')
    : '<p class="muted">No sessions found.</p>';

  const claudeSkillsHtml = CLAUDE_SKILLS.map(s => {
    const nameHtml = s.file
      ? `<a href="command:vscode.open?${encodeURIComponent(JSON.stringify(['file://' + s.file]))}" class="claude-skill-name">${escHtml(s.name)}</a>`
      : `<span class="claude-skill-name">${escHtml(s.name)}</span>`;
    return `
    <div class="claude-skill-row">
      ${nameHtml}
      <span class="claude-skill-desc">${escHtml(s.desc)}</span>
    </div>`;
  }).join('');


  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${escHtml(MACHINE.machine_name || 'Homelab')} Dashboard</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: var(--vscode-font-family, 'Segoe UI', sans-serif);
    font-size: 13px;
    background: var(--vscode-editor-background, #1e1e1e);
    color: var(--vscode-editor-foreground, #d4d4d4);
    padding: 32px 40px;
    max-width: 1100px;
    margin: 0 auto;
  }

  /* Header */
  .header {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 36px;
    border-bottom: 1px solid var(--vscode-panel-border, #3e3e3e);
    padding-bottom: 24px;
  }
  .claude-logo {
    width: 52px;
    height: 52px;
    border-radius: 12px;
    background: linear-gradient(135deg, #CC785C 0%, #D4A27F 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 26px;
    flex-shrink: 0;
  }
  .header-text h1 {
    font-size: 22px;
    font-weight: 600;
    color: var(--vscode-editor-foreground, #d4d4d4);
  }
  .header-text p {
    color: var(--vscode-descriptionForeground, #858585);
    margin-top: 4px;
    font-size: 12px;
  }
  .refresh-btn {
    margin-left: auto;
    background: transparent;
    border: 1px solid var(--vscode-panel-border, #3e3e3e);
    color: var(--vscode-descriptionForeground, #858585);
    border-radius: 6px;
    padding: 6px 14px;
    font-size: 12px;
    cursor: pointer;
  }
  .refresh-btn:hover {
    border-color: var(--vscode-focusBorder, #007acc);
    color: var(--vscode-editor-foreground, #d4d4d4);
  }

  /* Layout */
  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    margin-bottom: 24px;
  }
  @media (max-width: 700px) { .grid-2 { grid-template-columns: 1fr; } }

  /* Cards */
  .card {
    background: var(--vscode-sideBar-background, #252526);
    border: 1px solid var(--vscode-panel-border, #3e3e3e);
    border-radius: 8px;
    padding: 20px;
  }
  .card h2 {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--vscode-descriptionForeground, #858585);
    margin-bottom: 14px;
  }
  .card-full { grid-column: 1 / -1; }

  /* Session info */
  .session-title {
    font-size: 15px;
    font-weight: 500;
    color: var(--vscode-editor-foreground, #d4d4d4);
    margin-bottom: 12px;
  }
  .badge-done {
    display: inline-block;
    background: var(--vscode-badge-background, #4d4d4d);
    color: var(--vscode-badge-foreground, #fff);
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 11px;
    margin: 3px 3px 3px 0;
  }

  /* Tasks */
  .task-row {
    display: flex;
    gap: 10px;
    padding: 6px 0;
    border-bottom: 1px solid var(--vscode-panel-border, #3e3e3e);
    align-items: baseline;
  }
  .task-row:last-child { border-bottom: none; }
  .task-priority { font-size: 11px; white-space: nowrap; min-width: 90px; }
  .task-text { color: var(--vscode-editor-foreground, #d4d4d4); }
  .task-link { color: var(--vscode-textLink-foreground, #3794ff); text-decoration: none; }
  .task-link:hover { text-decoration: underline; }
  .muted { color: var(--vscode-descriptionForeground, #858585); font-style: italic; }

  /* Services */
  .services-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 10px;
  }
  .service-card {
    display: block;
    text-decoration: none;
    background: var(--vscode-editor-background, #1e1e1e);
    border: 1px solid var(--vscode-panel-border, #3e3e3e);
    border-radius: 6px;
    padding: 10px 12px;
    transition: border-color 0.15s, background 0.15s;
    cursor: pointer;
  }
  .service-card:hover {
    border-color: var(--vscode-focusBorder, #007acc);
    background: var(--vscode-list-hoverBackground, #2a2d2e);
  }
  .service-name {
    font-weight: 600;
    font-size: 12px;
    color: var(--vscode-editor-foreground, #d4d4d4);
  }
  .service-desc {
    font-size: 11px;
    color: var(--vscode-descriptionForeground, #858585);
    margin-top: 2px;
  }

  /* Session links */
  .session-link {
    display: block;
    padding: 7px 0;
    border-bottom: 1px solid var(--vscode-panel-border, #3e3e3e);
    color: var(--vscode-textLink-foreground, #3794ff);
    text-decoration: none;
    font-size: 12px;
  }
  .session-link:last-child { border-bottom: none; }
  .session-link:hover { text-decoration: underline; }

  /* Claude skills */
  .claude-skill-row {
    display: flex;
    gap: 12px;
    padding: 6px 0;
    border-bottom: 1px solid var(--vscode-panel-border, #3e3e3e);
    align-items: baseline;
  }
  .claude-skill-row:last-child { border-bottom: none; }
  .claude-skill-name {
    font-family: var(--vscode-editor-font-family, monospace);
    font-size: 12px;
    color: #CC785C;
    white-space: nowrap;
    min-width: 120px;
    text-decoration: none;
  }
  a.claude-skill-name:hover {
    text-decoration: underline;
    color: #e0956e;
  }
  .claude-skill-desc {
    font-size: 12px;
    color: var(--vscode-descriptionForeground, #858585);
  }
</style>
</head>
<body>

<div class="header">
  <div class="claude-logo">⚡</div>
  <div class="header-text">
    <h1>${escHtml(MACHINE.machine_name || 'Homelab')} Dashboard</h1>
    <p>${escHtml(MACHINE.subtitle || '')}</p>
  </div>
  <button class="refresh-btn" id="refresh-btn">↻ Refresh</button>
</div>
<script>
  const vscode = acquireVsCodeApi();
  document.getElementById('refresh-btn').addEventListener('click', () => {
    vscode.postMessage({ command: 'refresh' });
  });
</script>

<div class="grid-2">

  <!-- Claude Skills -->
  <div class="card card-full">
    <h2>Claude Skills</h2>
    ${claudeSkillsHtml}
  </div>

  <!-- Latest sessions -->
  <div class="card">
    <h2>Recent Sessions</h2>
    ${recentSessionsHtml}
  </div>

  <!-- Outstanding tasks -->
  <div class="card">
    <h2>Outstanding Tasks</h2>
    ${tasksHtml}
  </div>

  <!-- Services -->
  <div class="card card-full">
    <h2>Services</h2>
    <div class="services-grid">${servicesHtml}</div>
  </div>

</div>

</body>
</html>`;
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function showWelcomePanel() {
  const panel = vscode.window.createWebviewPanel(
    'homelabWelcome',
    (MACHINE.machine_name || 'Homelab') + ' Dashboard',
    vscode.ViewColumn.One,
    { enableScripts: true, enableCommandUris: true }
  );

  function refresh() {
    panel.webview.html = buildHtml(parseWorklog(), loadAsanaTasks());
  }

  panel.webview.onDidReceiveMessage(msg => {
    if (msg.command === 'refresh') refresh();
  });

  refresh();
}

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('homelab-welcome.show', showWelcomePanel)
  );
  showWelcomePanel();
}

function deactivate() {}

module.exports = { activate, deactivate };
