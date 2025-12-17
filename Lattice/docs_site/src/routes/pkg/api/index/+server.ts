const INDEX_URL = 'https://raw.githubusercontent.com/AltriusRS/CCT/main/Lattice/pkg/index.toml';

export const GET = async () => {
	const manifest = await fetch(INDEX_URL);
	return new Response(await manifest.text(), {
		headers: {
			'Content-Type': 'text/plain'
		}
	});
};
