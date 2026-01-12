<?php
/**
 * CSS post-processing
 * 
 * @package    theme_englishacademy
 * @copyright  2026 English Academy
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

/**
 * Post process the CSS tree.
 *
 * @param string $tree The CSS tree.
 * @param theme_config $theme The theme config object.
 */
function theme_englishacademy_process_css($css, $theme) {
    // Add custom CSS from settings
    $customcss = $theme->settings->customcss ?? '';
    $css .= $customcss;

    return $css;
}
