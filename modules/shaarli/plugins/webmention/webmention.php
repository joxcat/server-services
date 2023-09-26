<?php

/**
 * Plugin default_colors.
 *
 * Allow users to easily overrides colors of the default theme.
 */

use Shaarli\Config\ConfigManager;
use Shaarli\Plugin\PluginManager;

/**
 * When linklist is displayed, include default_colors CSS file.
 *
 * @param array $data - header data.
 *
 * @return mixed - header data with default_colors CSS file added.
 */
function hook_webmention_render_footer(array $data, ConfigManager $conf)
{
    $ownership_url = trim($conf->get('plugins.INDIE_WEB_AUTH', ''));
    if (! empty($ownership_url)) {
        $data['endofpage'][] = '<a rel="me" style="display:none" href="' . $ownership_url . '"></a>';
    }

	$webmention = trim($conf->get('plugins.WEBMENTION_OWNERSHIP', ''));
    if (! empty($webmention)) {
        $data['endofpage'][] = '<link rel="webmention" href="https://webmention.io/' . $webmention . '/webmention" />';
    }

    return $data;
}
