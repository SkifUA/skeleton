<?php
/**
 * Example of DB Query builder usage
 *
 * @author   Anton Shevchuk
 * @created  07.06.13 18:28
 */
namespace Application;

use Bluz\Controller\Controller;
use Bluz\Proxy\Layout;

return
/**
 * @return void
 */
function () {
    /**
     * @var Controller $this
     */
    Layout::breadCrumbs(
        [
            Layout::ahref('Test', ['test', 'index']),
            'DB Query Builders',
        ]
    );
    // all examples inside view
};
