<?php
namespace api\modules\v1\controllers;
use Yii;
use yii\rest\ActiveController;
use yii\filters\auth\CompositeAuth;
use yii\filters\auth\HttpBearerAuth;
use api\modules\v1\models\FavoriteAd;
use yii\helpers\ArrayHelper;
use yii\data\ActiveDataProvider;
use api\modules\v1\models\Follower;
use api\modules\v1\models\User;
use api\modules\v1\models\Notification;



class FollowerController extends ActiveController
{
    public $modelClass = 'api\modules\v1\models\follower';   
    
    public function actions()
	{
		$actions = parent::actions();

		// disable default actions
		unset($actions['create'], $actions['update'], $actions['index'], $actions['delete'], $actions['view']);                    

		return $actions;
	}    

    public function behaviors()
    {
        $behaviors = parent::behaviors();
        $behaviors['authenticator'] = [
            'class' => CompositeAuth::className(),
            'except'=>[],
            'authMethods' => [
                HttpBearerAuth::className()
            ],
        ];
        return $behaviors;
    }

    

    public function actionCreate()
    {
       
        $model = new Follower();
        $followerId = Yii::$app->user->identity->id;
        
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
        
            return $response;
        }
        $userId   =  @(int) $model->user_id;
        $totalCount = $model->find()->where(['follower_id'=>$followerId, 'user_id'=>$userId])->count();
        if($totalCount>0){
           $response['statusCode']=422;
           $errors['message'][] = "You have already follow this user";
           $response['errors']=$errors;
          
          return $response; 
        }
         if($model->save(false)){

             //// push notification 

            
             $modelUser = new User();
             $userResult = $modelUser->findOne($userId);

             $title                                     =   'New follower';
             $message 					                =   Yii::$app->user->identity->name.' has following you now';
 
             if($userResult->device_token){
                 
                
                 $dataPush['title']	        	        	=	$title;
                 $dataPush['body']		                	=	$message;
                 $dataPush['data']['notification_type']		=	'newFollower';
                 $dataPush['data']['follower_id']		      =	$followerId;
                 $deviceTokens[] 					        =    $userResult->device_token;
                
                 Yii::$app->pushNotification->sendPushNotification($deviceTokens, $dataPush);
                 
             }
            /// add notification to list

               $modelNotification                 = new Notification();
               $modelNotification->user_id        =  $userId;
               $modelNotification->type           =   Notification::TYPE_NEW_FOLLOWER;
               $modelNotification->reference_id   =  $followerId;
               $modelNotification->title          =  $title;
               $modelNotification->message        =   $message;
               $modelNotification->save(false);
             /// end add notification to list
 




             $response['message']='Added in your following list';
             return $response; 
         }else{
             $response['statusCode']=422;
             $errors['message'][] = "Not added successfully in your following list";
             $response['errors']=$errors;
             return $response; 
         }
    }

    public function actionUnfollow()
    {
       
        $model = new Follower();
        $followerId = Yii::$app->user->identity->id;
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
        
            return $response;
        }

        $userId   =  @(int) $model->user_id;
        $result = $model->find()->where(['follower_id'=>$followerId, 'user_id'=>$userId])->one();

        if(isset($result->id)){
            if($result->delete()){
       
                $response['message']='Unfollow successfully';
                return $response; 
            }else{
                $response['statusCode']=422;
                $errors['message'][] = "Unfollwo not successfully done";
                $response['errors']=$errors;
                
                return $response; 
            }

        }else{
            $response['statusCode']=422;
            $errors['message'][] = "Action Failed";
            $response['errors']=$errors;
            return $response; 

        }
    }

}


