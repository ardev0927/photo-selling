<?php

namespace api\modules\v1\controllers;

use yii\rest\ActiveController;
use api\modules\v1\models\Country;

/**
 * Country Controller API
 *
 * @author Budi Irawan <deerawan@gmail.com>
 */
class CountryController extends ActiveController
{
    public $modelClass = 'api\modules\v1\models\country';   
    
    public function actions()
	{
		$actions = parent::actions();

		// disable default actions
		unset($actions['create'], $actions['update'], $actions['index'], $actions['delete'], $actions['view']);                    

		return $actions;
	}    


    public function actionIndex(){
        $model =  new Country();
        $modelRes= $model->find()->where(['status'=>$model::STATUS_ACTIVE])->orderBy(['name'=> SORT_ASC])->all();
       // $modelRes= $model->find()->where(['status'=>1])->orderBy(['id'=> SORT_DESC])->all();
        $response['message']='ok';
        $response['country']=$modelRes;
        return $response;
    }


}


