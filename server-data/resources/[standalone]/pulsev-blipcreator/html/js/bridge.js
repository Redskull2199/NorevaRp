export function createBridge({ resourceName, fetchImpl = globalThis.fetch.bind(globalThis), timeoutMs = 10000, generation = () => 0 } = {}) {
  let closed = false;
  let pending = null;
  const failure = (code, message = code, details) => Object.assign(new Error(message), { code, ...details });
  return {
    pendingCount: () => pending ? 1 : 0,
    close() { closed = true; pending?.reject(failure('closed')); },
    call(callback, payload = {}) {
      if (closed) return Promise.reject(failure('closed'));
      if (pending) return Promise.reject(failure('request_limit'));
      if (!/^[A-Za-z][A-Za-z0-9]*$/.test(callback)) return Promise.reject(failure('invalid_request'));
      const resource = resourceName ?? globalThis.GetParentResourceName?.();
      if (typeof resource !== 'string' || !/^[A-Za-z0-9_-]+$/.test(resource)) return Promise.reject(failure('invalid_resource'));
      const captured = generation();
      const controller = new AbortController();
      return new Promise((resolve, reject) => {
        let settled = false;
        let timer;
        const finish = (error, value) => {
          if (settled) return;
          settled = true;
          clearTimeout(timer);
          pending = null;
          controller.abort();
          if (error) reject(error); else resolve(value);
        };
        pending = { reject: error => finish(error) };
        timer = setTimeout(() => finish(failure('timeout', 'İstek zaman aşımına uğradı.')), timeoutMs);
        Promise.resolve().then(() => {
          if (settled) throw failure('closed');
          return fetchImpl(`https://${resource}/${callback}`, {
          method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' },
          body: JSON.stringify({ generation: captured, payload }), signal: controller.signal
          });
        }).then(async response => {
          if (response.ok === false) throw failure('transport_error');
          let result;
          try { result = await response.json(); } catch { throw failure('malformed_json'); }
          if (closed || generation() !== captured) throw failure('closed_generation');
          if (!result || typeof result !== 'object' || result.generation !== captured || typeof result.ok !== 'boolean') throw failure('invalid_response');
          if (!result.ok) throw failure(result.error?.code ?? 'request_failed', result.error?.message ?? 'İstek başarısız.', result.error);
          finish(null, result.data);
        }).catch(error => finish(error));
      });
    }
  };
}
