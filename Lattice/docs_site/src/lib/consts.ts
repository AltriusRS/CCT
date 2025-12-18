export const REPOSITORY_ROOT = 'https://raw.githubusercontent.com/AltriusRS/CCT/refs/heads';
export const PACKAGE_REPOSITORY = (branch: string = DEFAULT_BRANCH) =>
	`${REPOSITORY_ROOT}/${branch}/Lattice/pkg/`;
export const DOCUMENTATION_ROOT = (branch: string = DEFAULT_BRANCH) =>
	`${REPOSITORY_ROOT}/${branch}/Lattice/docs/`;

export const DEFAULT_BRANCH = 'main';
