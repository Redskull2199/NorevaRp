export const draftFields = Object.freeze(['name', 'note', 'sprite', 'color', 'scale', 'alpha', 'display', 'short_range', 'x', 'y', 'z', 'rotation', 'category', 'map_category', 'enabled']);
const finite = value => typeof value === 'number' && Number.isFinite(value);
const integer = (value, min, max) => finite(value) && Number.isInteger(value) && value >= min && value <= max;
function validText(value, limit, trim, allowLF, noFormat) {
  if (typeof value !== 'string' || !limit) return null;
  if (trim) value = value.replace(/^ +| +$/g, '');
  const characters = [...value];
  if (characters.length < limit.minChars || characters.length > limit.maxChars || new TextEncoder().encode(value).length > limit.maxBytes) return null;
  for (const character of characters) {
    const cp = character.codePointAt(0);
    if ((cp < 32 && !(allowLF && cp === 10)) || (cp >= 127 && cp <= 159) || (cp >= 0xD800 && cp <= 0xDFFF)) return null;
  }
  if (noFormat && /~[^~]*~/.test(value)) return null;
  return value;
}
function hasSprite(catalog, id) {
  if (catalog instanceof Set || catalog instanceof Map) return catalog.has(id);
  const entries = Array.isArray(catalog) ? catalog : catalog?.sprites;
  if (Array.isArray(entries)) return entries.some(entry => (typeof entry === 'number' ? entry : entry.id) === id);
  return catalog != null && Object.hasOwn(catalog, id) && Boolean(catalog[id]);
}
export function validateDraft(input, options, catalog) {
  const fields = {}, value = {};
  if (!input || typeof input !== 'object' || Array.isArray(input)) return { ok: false, value: null, fields: { draft: 'Nesne bekleniyor.' } };
  for (const key of Object.keys(input)) if (!draftFields.includes(key)) fields[key] = 'Bilinmeyen alan.';
  for (const key of ['name', 'note', 'category']) {
    value[key] = validText(input[key], options?.Limits?.[key], key !== 'note', key === 'note', key === 'name');
    if (value[key] === null) fields[key] = 'Geçerli metin ve uzunluk gerekli.';
  }
  for (const key of ['scale', 'x', 'y', 'z']) {
    const number = input[key], limit = options?.Limits?.[key];
    if (!finite(number) || !limit || number < limit.min || number > limit.max || (key === 'scale' && Math.abs(number * 100 - Math.floor(number * 100 + 0.5)) > 1e-8)) fields[key] = 'Sonlu ve sınırlar içinde sayı gerekli.';
    else value[key] = number;
  }
  for (const [key, min, max] of [['color', 0, 85], ['alpha', 0, 255], ['display', 0, 10], ['rotation', 0, 359]]) {
    if (!integer(input[key], min, max)) fields[key] = 'İzin verilen tam sayı gerekli.'; else value[key] = input[key];
  }
  if (!integer(input.sprite, 0, 65535) || !hasSprite(catalog, input.sprite)) fields.sprite = 'Desteklenmeyen sprite.'; else value.sprite = input.sprite;
  if (!integer(input.map_category, 1, 254) || !([1, 2, 7].includes(input.map_category) || input.map_category >= 10)) fields.map_category = 'Desteklenmeyen harita kategorisi.'; else value.map_category = input.map_category;
  for (const key of ['short_range', 'enabled']) {
    if (typeof input[key] !== 'boolean') fields[key] = 'Boolean gerekli.'; else value[key] = input[key];
  }
  return { ok: Object.keys(fields).length === 0, value: Object.keys(fields).length ? null : value, fields };
}
