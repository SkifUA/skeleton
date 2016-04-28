<?php
/**
 * @author   Anton Shevchuk
 * @created  04.09.12 11:21
 */

/**
 * @namespace
 */
namespace Application;

use Application\Roles;
use Bluz\Controller;

return
/**
 * @accept HTML
 * @accept JSON
 * @privilege Management
 *
 * @return mixed
 */
function () {
    /**
     * @var Controller $this
     */
    $crudController = new Controller\Crud();
    $crudController->setCrud(Roles\Crud::getInstance());
    return $crudController();
};
