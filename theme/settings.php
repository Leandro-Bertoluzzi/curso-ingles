<?php
/**
 * Theme settings
 * 
 * @package    theme_englishacademy
 * @copyright  2026 English Academy
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

if ($ADMIN->fulltree) {
    // Logo setting
    $name = 'theme_englishacademy/logo';
    $title = get_string('logo', 'theme_englishacademy', null, true);
    $description = get_string('logodesc', 'theme_englishacademy', null, true);
    $setting = new admin_setting_configstoredfile($name, $title, $description, 'logo');
    $setting->set_updatedcallback('theme_reset_all_caches');
    $page->add($setting);

    // Custom CSS setting
    $name = 'theme_englishacademy/customcss';
    $title = get_string('customcss', 'theme_englishacademy', null, true);
    $description = get_string('customcssdesc', 'theme_englishacademy', null, true);
    $default = '';
    $setting = new admin_setting_configtextarea($name, $title, $description, $default);
    $setting->set_updatedcallback('theme_reset_all_caches');
    $page->add($setting);
}
