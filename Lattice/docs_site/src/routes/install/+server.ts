import { REPOSITORY_ROOT } from '$lib/consts';

const URL = REPOSITORY_ROOT + 'install.lua';

export const GET = async () => {
	const response = await fetch(URL);
	return new Response(await response.text(), {
		headers: {
			'Content-Type': 'text/plain'
		}
	});
};
