<?php
/**
 * Example of forms handle
 *
 * @category Application
 *
 * @author   dark
 * @created  13.12.13 18:12
 */
namespace Application;

use Bluz\Controller\Controller;
use Bluz\Proxy\Layout;
use Bluz\Proxy\Request;

return
/**
 * @return void
 */
function ($int, $string, $array, $optional = 0)  {
    /**
     * @var Controller $this
     */
    Layout::breadCrumbs(
        [
            Layout::ahref('Test', ['test', 'index']),
            'Form Example',
        ]
    );
    if (Request::isPost()) {
        ob_start();
        var_dump($int, $string, $array, $optional);
        $inside = ob_get_contents();
        ob_end_clean();
        
        return [
            'inside' => $inside, 
            'params' => Request::getAllParams()
        ];
    }
};
