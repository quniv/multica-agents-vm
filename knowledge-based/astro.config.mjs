// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'Multica Agent Knowledge Base',
			sidebar: [
				{
					label: 'Operations & Security',
					items: [{ autogenerate: { directory: 'operations-security' } }],
				},
				{
					label: 'Skills',
					items: [{ autogenerate: { directory: 'skills' } }],
				},
				{
					label: 'Agents',
					items: [{ autogenerate: { directory: 'agents' } }],
				},
			],
		}),
	],
});
