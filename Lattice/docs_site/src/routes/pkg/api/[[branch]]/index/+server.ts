import { PACKAGE_REPOSITORY, DEFAULT_BRANCH } from '$lib/consts';
import type { RequestHandler } from './$types';
import TOML from '@iarna/toml';

/**
 * Helper to serialize JS objects into Lua-compatible table strings.
 * This handles the 'Lean' format with minimal overhead.
 */
function toLuaTable(obj: any): string {
	if (obj === null) return 'nil';
	if (typeof obj === 'number' || typeof obj === 'boolean') return obj.toString();
	if (typeof obj === 'string') return `"${obj.replace(/"/g, '\\"')}"`;

	if (Array.isArray(obj)) {
		const entries = obj.map((v) => toLuaTable(v)).join(',');
		return `{${entries}}`;
	}

	if (typeof obj === 'object') {
		const entries = Object.entries(obj)
			.map(([k, v]) => `["${k}"]=${toLuaTable(v)}`)
			.join(',');
		return `{${entries}}`;
	}

	return 'nil';
}

export const GET: RequestHandler = async ({ params, url: requestUrl }) => {
	const branch = params.branch || DEFAULT_BRANCH;
	const format = requestUrl.searchParams.get('format');
	const url = PACKAGE_REPOSITORY(branch) + 'index.toml';

	const res = await fetch(url, {
		cache: 'no-store',
		headers: {
			'User-Agent': 'CCT/Lattice',
			'Cache-Control': 'no-store',
			Pragma: 'no-cache'
		}
	});

	if (!res.ok) {
		return new Response(`-- Error: Failed to fetch index from GitHub (${res.status})`, {
			status: 502
		});
	}

	const content = await res.text();

	// If CC requests format=lua, parse TOML and return a Lua table string
	if (format === 'lua') {
		try {
			const data = TOML.parse(content);
			const luaTable = `return ${toLuaTable(data)}`;
			return new Response(luaTable, {
				headers: {
					'Content-Type': 'text/plain; charset=utf-8',
					'Cache-Control': 'no-store'
				}
			});
		} catch (err) {
			return new Response('-- Error: Server failed to parse TOML manifest', { status: 500 });
		}
	}

	// Default to raw TOML
	return new Response(content, {
		headers: {
			'Content-Type': 'text/plain; charset=utf-8',
			'Cache-Control': 'no-store'
		}
	});
};
