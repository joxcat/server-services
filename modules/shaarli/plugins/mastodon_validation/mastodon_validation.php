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
function hook_mastodon_validation_render_footer(array $data, ConfigManager $conf)
{
    $validation_url = trim($conf->get('plugins.MASTODON_VALIDATION_URL', ''));
    if (! empty($validation_url)) {
        $data['endofpage'][] = '<a rel="me" style="display:none" href="' . $validation_url . '"></a>';
    }

    return $data;
}
