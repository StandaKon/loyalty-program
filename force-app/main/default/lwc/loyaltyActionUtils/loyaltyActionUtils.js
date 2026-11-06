const reduceError = (error) => {
    if (Array.isArray(error?.body)) {
        return error.body.map((item) => item.message).join(', ');
    }
    return error?.body?.message ?? error?.message ?? String(error);
};

const formatLabel = (label, ...values) =>
    values.reduce((text, value, index) => text.split(`{${index}}`).join(value), label);

// Request key for idempotent server writes; stays the same for retries of one dialog submission.
const generateRequestKey = () => {
    if (typeof crypto?.randomUUID === 'function') {
        return crypto.randomUUID();
    }
    const bytes = crypto.getRandomValues(new Uint8Array(16));
    bytes[6] = (bytes[6] % 16) + 64;
    bytes[8] = (bytes[8] % 64) + 128;
    const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, '0')).join('');
    return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`;
};

const formatNumber = (value) => new Intl.NumberFormat('cs-CZ').format(value ?? 0);

export { reduceError, formatLabel, generateRequestKey, formatNumber };
