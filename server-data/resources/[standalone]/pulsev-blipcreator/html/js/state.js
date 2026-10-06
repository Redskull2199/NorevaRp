const clone = value => value == null ? value : structuredClone(value);
function immutable(value) {
  const copy = clone(value);
  function freeze(item) { if (item && typeof item === 'object') { Object.values(item).forEach(freeze); Object.freeze(item); } return item; }
  return freeze(copy);
}
const validSequence = value => Number.isSafeInteger(value) && value >= 0;
const validRecord = value => value && typeof value === 'object' && Number.isSafeInteger(value.id) && value.id > 0 && Number.isSafeInteger(value.version) && value.version > 0;
const lower = value => String(value ?? '').toLocaleLowerCase('tr-TR');
export function createStore() {
  let records = new Map(), epoch = null, sequence = 0, draft = null, conflict = null;
  let pending = null, serial = 0, buffer = new Map(), needsResync = false, overflow = false;
  function checkConflict() {
    if (!draft?.id) { conflict = null; return; }
    const current = records.get(draft.id);
    conflict = !current ? immutable({ code: 'deleted' }) : current.version !== draft.version ? immutable({ code: 'conflict', current }) : null;
  }
  function commitDelta(delta) {
    if (delta.op === 'upsert') records.set(delta.record.id, immutable(delta.record));
    if (delta.op === 'remove') records.delete(delta.id);
    sequence = delta.sequence;
    checkConflict();
  }
  function buffered(delta) {
    const key = `${delta.epoch}\0${delta.sequence}`;
    if (buffer.has(key)) return;
    if (buffer.size >= 500) { needsResync = true; overflow = true; return; }
    buffer.set(key, immutable(delta));
  }
  return {
    get draft() { return draft; }, get conflict() { return conflict; },
    get epoch() { return epoch; }, get sequence() { return sequence; }, get needsResync() { return needsResync; },
    requestResync() { needsResync = true; },
    beginSnapshot(requestId) { const ticket = requestId ?? ++serial; pending = ticket; return ticket; },
    cancelSnapshot(ticket) { if (pending === ticket) { pending = null; needsResync = true; } },
    applySnapshot(snapshot, ticket = snapshot?.requestId) {
      if (pending !== null && ticket !== pending) return false;
      if (overflow) { pending = null; buffer.clear(); overflow = false; needsResync = true; return false; }
      if (!snapshot || snapshot.error || typeof snapshot.epoch !== 'string' || !validSequence(snapshot.sequence) || !Array.isArray(snapshot.records) || !snapshot.records.every(validRecord)) { needsResync = true; return false; }
      if (epoch === snapshot.epoch && snapshot.sequence < sequence) { needsResync = true; return false; }
      // Explicit tickets remain correlated even after a newer capture has completed.
      if (pending === null && arguments.length > 1) return false;
      records = new Map(snapshot.records.map(record => [record.id, immutable(record)]));
      epoch = snapshot.epoch; sequence = snapshot.sequence; pending = null; needsResync = false;
      const deltas = [...buffer.values()].filter(delta => delta.epoch === epoch && delta.sequence > sequence).sort((a, b) => a.sequence - b.sequence);
      buffer.clear();
      for (const delta of deltas) { if (delta.sequence !== sequence + 1) { buffered(delta); needsResync = true; } else if (!needsResync) commitDelta(delta); else buffered(delta); }
      checkConflict(); return true;
    },
    applyDelta(delta) {
      if (!delta || typeof delta.epoch !== 'string' || !validSequence(delta.sequence) || !['upsert', 'remove', 'noop'].includes(delta.op) || (delta.op === 'upsert' && !validRecord(delta.record)) || (delta.op === 'remove' && (!Number.isSafeInteger(delta.id) || delta.id < 1))) { needsResync = true; return false; }
      if (epoch === delta.epoch && delta.sequence <= sequence) return false;
      if (pending !== null || epoch !== delta.epoch || delta.sequence !== sequence + 1 || needsResync) { buffered(delta); if (pending === null) needsResync = true; return false; }
      commitDelta(delta); return true;
    },
    setDraft(record) { draft = immutable(record); checkConflict(); },
    updateDraft(field, value) {
      if (!draft || !['name','note','sprite','color','scale','alpha','display','short_range','x','y','z','rotation','category','map_category','enabled'].includes(field)) return false;
      draft = immutable({ ...draft, [field]: value }); return true;
    },
    select({ query = '', category = '', status = 'all', page = 1, pageSize = 25 } = {}) {
      const needle = lower(query).trim();
      const items = [...records.values()].filter(record => (!needle || [record.name, record.category, record.note, record.id].some(value => lower(value).includes(needle))) && (!category || category === 'all' || record.category === category) && (status === 'all' || status === '' || status == null || record.enabled === (status === 'enabled' || status === 'active' || status === true))).sort((a, b) => a.id - b.id);
      pageSize = Number.isSafeInteger(pageSize) && pageSize > 0 ? pageSize : 25;
      const total = items.length, pageCount = Math.max(1, Math.ceil(total / pageSize));
      page = Math.max(1, Math.min(pageCount, Number.isSafeInteger(page) ? page : 1));
      return { items: items.slice((page - 1) * pageSize, page * pageSize), total, page, pageCount };
    },
    reset() { records = new Map(); epoch = null; sequence = 0; draft = null; conflict = null; pending = null; buffer.clear(); needsResync = false; overflow = false; serial++; }
  };
}
