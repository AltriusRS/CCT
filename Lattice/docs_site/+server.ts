export const GET = async () => {
	const response = await fetch(
		'https://raw.githubusercontent.com/AltriusRS/CCT/main/Lattice/install.lua'
	);
	const lua = await response.text();
	return new Response(lua, { headers: { 'Content-Type': 'text/plain' } });
};
