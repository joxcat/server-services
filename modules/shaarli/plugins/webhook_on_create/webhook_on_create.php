<?php

/**
 * Plugin default_colors.
 *
 * Allow users to easily overrides colors of the default theme.
 */

use Shaarli\Config\ConfigManager;
use Shaarli\Plugin\PluginManager;

function make_request($data, string $url, string $tags)
{
	if (empty($url) or empty($tags)) {
		return;
	}

	
}

/**
 * Hook savelink.
 *
 * Triggered when a link is save (new or edit).
 * All new links now contain a 'stuff' value.
 *
 * @param array $data contains the new link data.
 *
 * @return array altered $data.
 */
function hook_webhook_on_create_save_link($data, ConfigManager $conf)
{
	make_request(trim($conf->get('plugins.WEBHOOK_1_URL', '')), trim($conf->get('plugins.WEBHOOK_1_TAGS', '')))
	make_request(trim($conf->get('plugins.WEBHOOK_2_URL', '')), trim($conf->get('plugins.WEBHOOK_2_TAGS', '')))
	make_request(trim($conf->get('plugins.WEBHOOK_3_URL', '')), trim($conf->get('plugins.WEBHOOK_3_TAGS', '')))

    return $data;
}
