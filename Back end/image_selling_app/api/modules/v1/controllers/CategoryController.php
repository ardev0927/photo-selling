<?php

namespace api\modules\v1\controllers;
use yii\rest\ActiveController;
use api\modules\v1\models\Category;

use yii\helpers\ArrayHelper;
use yii\data\ActiveDataProvider;


/**
 * Category Controller API
 *
 
 */
class CategoryController extends ActiveController
{
    public $modelClass = 'api\modules\v1\models\category';   
    
    public function actions()
	{
		$actions = parent::actions();

		// disable default actions
		unset($actions['create'], $actions['update'], $actions['index'], $actions['delete'], $actions['view']);                    

		return $actions;
	}    


    public function actionIndex(){
        $model =  new Category();
        $modelRes= $model->find()
        ->select(['category.id','category.name'])
      // ->joinWith('subCategory')
        ->where(['category.status'=>$model::STATUS_ACTIVE,'category.level'=>Category::LEVEL_MAIN])->orderBy(['name'=> SORT_ASC])->all();
       // $modelRes= $model->find()->where(['status'=>1])->orderBy(['id'=> SORT_DESC])->all();
        
       //$modelRes1 = ArrayHelper::toArray($modelRes);

       
       $response['message']='ok';
        $response['category']=$modelRes;
        return $response;
    }


}


