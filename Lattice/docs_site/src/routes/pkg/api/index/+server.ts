const INDEX_URL = 'https://raw.githubusercontent.com/AltriusRS/CCT/main/Lattice/pkg/index.toml';

export const GET = async () => {
	const manifest = await fetch(INDEX_URL, {
		cache: 'no-store',
		headers: {
			'User-Agent': 'CCT/Lattice',
			'Cache-Control': 'no-store',
			Pragma: 'no-cache'
		}
	});
	return new Response(await manifest.text(), {
		headers: {
			'Content-Type': 'text/plain; charset=utf-8',
			'Cache-Control': 'no-store',
			Pragma: 'no-cache'
		}
	});
};
