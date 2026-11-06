import { execFile } from 'node:child_process';
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);
const appDirectory = fileURLToPath(new URL('.', import.meta.url));
const publicDirectory = join(appDirectory, 'public');
const port = Number(process.env.POS_PORT || 4173);
const isDemoMode = process.env.POS_DEMO_MODE === '1';
const salesforcePath = '/services/apexrest/loyalty/v1/transactions';

const mimeTypes = {
    '.css': 'text/css; charset=utf-8',
    '.html': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.svg': 'image/svg+xml',
};

let cachedSalesforceAuth;

createServer(async (request, response) => {
    try {
        if (request.method === 'GET' && request.url === '/api/status') {
            return sendJson(response, 200, {
                mode: isDemoMode ? 'demo' : 'salesforce',
                connected: isDemoMode ? true : await canAuthenticate(),
            });
        }

        if (request.method === 'POST' && request.url === '/api/transactions') {
            const payload = await readJsonBody(request);
            const result = isDemoMode ? buildDemoResult(payload) : await createSalesforceTransaction(payload);
            return sendJson(response, result.httpStatus, result.body);
        }

        if (request.method === 'GET') {
            return serveStaticFile(request.url, response);
        }

        sendJson(response, 404, { message: 'Požadovaná cesta neexistuje.' });
    } catch (error) {
        const statusCode = error.statusCode || 500;
        sendJson(response, statusCode, {
            errorCode: error.errorCode || 'POS_SERVER_ERROR',
            message: error.publicMessage || 'Požadavek se nepodařilo zpracovat.',
        });
    }
}).listen(port, '127.0.0.1', () => {
    const mode = isDemoMode ? 'demo bez Salesforce' : 'Salesforce';
    process.stdout.write(`Pokladna běží na http://127.0.0.1:${port} (${mode})\n`);
});

async function createSalesforceTransaction(payload) {
    const auth = await getSalesforceAuth();
    const salesforceResponse = await fetch(`${auth.instanceUrl}${salesforcePath}`, {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${auth.accessToken}`,
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
    });
    const body = await salesforceResponse.json().catch(() => ({
        errorCode: 'INVALID_SALESFORCE_RESPONSE',
        message: 'Salesforce vrátil nečitelnou odpověď.',
    }));
    return { httpStatus: salesforceResponse.status, body };
}

async function getSalesforceAuth() {
    if (process.env.SF_INSTANCE_URL && process.env.SF_ACCESS_TOKEN) {
        return {
            instanceUrl: process.env.SF_INSTANCE_URL.replace(/\/$/, ''),
            accessToken: process.env.SF_ACCESS_TOKEN,
        };
    }

    if (cachedSalesforceAuth) {
        return cachedSalesforceAuth;
    }

    const [orgDisplay, tokenResult] = await Promise.all([
        runSalesforceCli(['org', 'display', '--json']),
        runSalesforceCli(['org', 'auth', 'show-access-token', '--json']),
    ]);
    cachedSalesforceAuth = {
        instanceUrl: orgDisplay.result.instanceUrl.replace(/\/$/, ''),
        accessToken: tokenResult.result.accessToken,
    };
    return cachedSalesforceAuth;
}

async function canAuthenticate() {
    try {
        await getSalesforceAuth();
        return true;
    } catch {
        return false;
    }
}

async function runSalesforceCli(argumentsList) {
    try {
        const { stdout } = await execFileAsync('sf', argumentsList, {
            cwd: appDirectory,
            maxBuffer: 1024 * 1024,
        });
        const result = JSON.parse(stdout);
        if (result.status !== 0) {
            throw new Error('Salesforce CLI returned an error.');
        }
        return result;
    } catch (cause) {
        const error = new Error('Salesforce authentication failed.', { cause });
        error.statusCode = 503;
        error.errorCode = 'SALESFORCE_AUTH_FAILED';
        error.publicMessage = 'Pokladna se nemůže přihlásit k výchozímu Salesforce orgu. Zkontroluj přihlášení v Salesforce CLI.';
        throw error;
    }
}

function buildDemoResult(payload) {
    const baseFuelPoints = Math.floor(Number(payload.liters || 0));
    const baseOtherPoints = Math.floor(Number(payload.otherAmount || 0) / 20);
    const basePoints = baseFuelPoints + baseOtherPoints;
    const fullTankBonus = Number(payload.liters || 0) >= 40 ? 50 : 0;
    const shopBonus = Number(payload.otherAmount || 0) >= 150 ? Math.floor(basePoints * 1.1) - basePoints : 0;
    const campaignPoints = fullTankBonus + shopBonus;
    return {
        httpStatus: 201,
        body: {
            transactionId: 'DEMO-TRANSACTION',
            posTransactionId: payload.posTransactionId,
            memberNumber: payload.memberNumber,
            status: 'Processed',
            processingError: null,
            baseFuelPoints,
            baseOtherPoints,
            campaignPoints,
            awardedPoints: basePoints + campaignPoints,
            memberBalance: basePoints + campaignPoints,
            isReplay: false,
            demoMode: true,
        },
    };
}

async function readJsonBody(request) {
    const chunks = [];
    let size = 0;
    for await (const chunk of request) {
        size += chunk.length;
        if (size > 64 * 1024) {
            const error = new Error('Request body is too large.');
            error.statusCode = 413;
            throw error;
        }
        chunks.push(chunk);
    }
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

async function serveStaticFile(requestUrl, response) {
    const urlPath = decodeURIComponent((requestUrl || '/').split('?')[0]);
    const relativePath = urlPath === '/' ? 'index.html' : urlPath.replace(/^\/+/, '');
    const normalizedPath = normalize(relativePath);
    if (normalizedPath.startsWith('..')) {
        return sendJson(response, 403, { message: 'Přístup byl odmítnut.' });
    }

    try {
        const content = await readFile(join(publicDirectory, normalizedPath));
        response.writeHead(200, {
            'Content-Type': mimeTypes[extname(normalizedPath)] || 'application/octet-stream',
            'Cache-Control': 'no-store',
        });
        response.end(content);
    } catch {
        sendJson(response, 404, { message: 'Soubor nebyl nalezen.' });
    }
}

function sendJson(response, statusCode, body) {
    response.writeHead(statusCode, {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-store',
    });
    response.end(JSON.stringify(body));
}
