import { PACKAGE_REPOSITORY } from '$lib/consts.js';

export const GET = async ({ params }) => {
	const path = params.path;

	if (!path) {
		return new Response('Missing package path', { status: 400 });
	}

	const url = PACKAGE_REPOSITORY + path;
	console.log(url);
	const res = await fetch(url, { cache: 'no-store' });

	if (!res.ok) {
		return new Response('Package not found', { status: 404 });
	}

	const data = await res.arrayBuffer();

	return new Response(data, {
		headers: {
			'Content-Type': 'text/plain; charset=utf-8'
			// 'Cache-Control': 'public, max-age=31536000, immutable'
		}
	});
};
