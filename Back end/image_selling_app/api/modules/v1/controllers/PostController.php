<?php
namespace api\modules\v1\controllers;
use Yii;
use yii\rest\ActiveController;
use yii\filters\auth\CompositeAuth;
use yii\filters\auth\HttpBearerAuth;
use yii\web\UploadedFile;
use yii\imagine\Image;
use yii\data\ActiveDataProvider;
use api\modules\v1\models\User;
use api\modules\v1\models\Setting;
use api\modules\v1\models\Post;
use api\modules\v1\models\PostSearch;
use api\modules\v1\models\HashTag;
use api\modules\v1\models\PostLike;
use api\modules\v1\models\PostView;
use api\modules\v1\models\PostComment;
use api\modules\v1\models\Notification;
use api\modules\v1\models\Competition;
use api\modules\v1\models\CompetitionUser;
use api\modules\v1\models\ReportedPost;


class PostController extends ActiveController
{
    public $modelClass = 'api\modules\v1\models\post';   
    public $serializer = [
        'class' => 'yii\rest\Serializer',
        'collectionEnvelope' => 'items',
    ];
    
    
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
            'except'=>['ad-search'],
            'authMethods' => [
                HttpBearerAuth::className()
            ],
        ];
        return $behaviors;
    }


    public function actionCreate()
    {
        $userId = Yii::$app->user->identity->id;
        $model =   new Post();
       
        $model->scenario ='create';

       
        if (Yii::$app->request->isPost) {
            $model->load(Yii::$app->getRequest()->getBodyParams(), '');
            $model->imageFile = UploadedFile::getInstanceByName('imageFile'); 
           // $model->videoFile = UploadedFile::getInstanceByName('videoFile'); 
            if(!$model->validate()) {
                $response['statusCode']=422;
                $response['errors']=$model->errors;
                return $response;
            }

            if($model->imageFile){
                //print_r($model->imageFile->tempName);
                //die;
                    
                $microtime 			= 	(microtime(true)*10000);
                $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                $model->image 		= 	$imageName; 
                $s3 = Yii::$app->get('s3');
                $imagePath = $model->imageFile->tempName;
                $result = $s3->upload('./'.Yii::$app->params['pathUploadImageFolder'].'/'.$imageName, $imagePath);
                //echo '<pre>';
                //print_r($result);
                //die;
                //$promise = $s3->commands()->upload('./video-thumb/'.$imageName, $imagePath)->async()->execute();
            }
            

            if($model->save()){
                
                if($model->hashtag){
                    $modelHashTag =  new HashTag();
                    $modelHashTag->updateHashTag($model->id,$model->hashtag);
                }
                $response['message']=Yii::$app->params['apiMessage']['post']['postCreateSuccess'];
                $response['post_id']=$model->id;
                //$response['image']=Yii::$app->params['pathUploadVideoThumb'] ."/".$model->image;
                //$response['video']=Yii::$app->params['pathUploadVideo'] ."/".$model->video;
                return $response; 
            }else{

                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['post']['postCreateFailed'];
                $response['errors']=$errors;
                return $response;
            
            

            }

            
        }

       
        
    }

    public function actionCompetitionImage()
    {
        $userId                 = Yii::$app->user->identity->id;
        $model                  =   new Post();
        $modelCompetition       =   new Competition();
        $modelCompetitionUser   =   new CompetitionUser();
       
        $model->scenario ='competitionImage';
        
        if (Yii::$app->request->isPost) {
            $model->load(Yii::$app->getRequest()->getBodyParams(), '');
            $model->imageFile = UploadedFile::getInstanceByName('imageFile'); 
           // $model->videoFile = UploadedFile::getInstanceByName('videoFile'); 
            if(!$model->validate()) {
                $response['statusCode']=422;
                $response['errors']=$model->errors;
                return $response;
            }
            $currentTime=time();
            $competitionId =  @(int) $model->competition_id;
            $resultCompetition     = $modelCompetition->find()->where(['id'=>$competitionId,'status'=>Competition::STATUS_ACTIVE])->one();
            if(!$resultCompetition){
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['competition']['noRecord'];
                $response['errors']=$errors;
                return $response;
            
            }
    
            if($resultCompetition->start_date > $currentTime || $resultCompetition->end_date < $currentTime ){
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['competition']['notAvailable'];
                $response['errors']=$errors;
                return $response;
            
            }

            $resultCompetitionUser     = $modelCompetitionUser->find()->where(['competition_id'=>$competitionId,'user_id'=>$userId])->one();

           
            if(!$resultCompetitionUser){
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['competition']['joinCompetition'];
                $response['errors']=$errors;
                return $response;
            
            }
    
            $countPost     = $model->find()->where(['competition_id'=>$competitionId,'user_id'=>$userId])->count();

            if($countPost){
                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['competition']['alreadyPosted'];
                $response['errors']=$errors;
                return $response;
            
            }
    



            if($model->imageFile){
                //print_r($model->imageFile->tempName);
                //die;
                    
                $microtime 			= 	(microtime(true)*10000);
                $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                $model->image 		= 	$imageName; 
                $s3 = Yii::$app->get('s3');
                $imagePath = $model->imageFile->tempName;
                $result = $s3->upload('./'.Yii::$app->params['pathUploadImageFolder'].'/'.$imageName, $imagePath);
                //echo '<pre>';
                //print_r($result);
                //die;
                //$promise = $s3->commands()->upload('./video-thumb/'.$imageName, $imagePath)->async()->execute();
            }
            
            $model->type= Post::TYPE_COMPETITION;
            if($model->save()){
                
                if($model->hashtag){
                    $modelHashTag =  new HashTag();
                    $modelHashTag->updateHashTag($model->id,$model->hashtag);
                }
                $response['message']=Yii::$app->params['apiMessage']['post']['postCreateSuccess'];
                $response['post_id']=$model->id;
                //$response['image']=Yii::$app->params['pathUploadVideoThumb'] ."/".$model->image;
                //$response['video']=Yii::$app->params['pathUploadVideo'] ."/".$model->video;
                return $response; 
            }else{

                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['post']['postCreateFailed'];
                $response['errors']=$errors;
                return $response;
            
            

            }

            
        }
        
    }




    public function actionMyPost()
    {
        
        $model = new PostSearch();

        $result = $model->searchMyPost(Yii::$app->getRequest()->getBodyParams());
        
        $response['message']=Yii::$app->params['apiMessage']['post']['listFound'];
        $response['post']=$result;
        
        return $response; 
        
    }

    /**
     * search post 
     */
    

    public function actionSearchPost()
    {
        
        $model = new PostSearch();
        $result = $model->search(Yii::$app->request->queryParams);
        $response['message']=Yii::$app->params['apiMessage']['post']['listFound'];
        $response['post']=$result;
        return $response; 
        
    }
    /**
     * Report Post
     */
    public function actionReportPost()
    {
        
        
        $model = new ReportedPost();
        $userId = Yii::$app->user->identity->id;
        
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
        
            return $response;
        }

       $postId =  @(int) $model->post_id;
       
       $totalCount = $model->find()->where(['post_id'=>$postId, 'user_id'=>$userId,'status'=>ReportedPost::STATUS_PENDING])->count();
       if($totalCount>0){
        $response['statusCode']=422;
        $errors['message'][] = Yii::$app->params['apiMessage']['post']['alreadyReported'];
        $response['errors']=$errors;
         return $response; 

       }

       
        $model->status = ReportedPost::STATUS_PENDING;
        if($model->save(false)){
            $response['message']=Yii::$app->params['apiMessage']['post']['reportedSuccess'];
            return $response; 
        }else{

            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['common']['actionFailed'];
            $response['errors']=$errors;
        }
    }



    /**
     * like post
     */

    public function actionLike()
    {
        $model = new PostLike();
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
            return $response;
        }
        $postId =  @(int) $model->post_id;
        $totalCount = $model->find()->where(['post_id'=>$postId, 'user_id'=>$userId])->count();
        if($totalCount>0){
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['post']['postLikeAlready'];
            $response['errors']=$errors;
            return $response;
        
        }
 
         if($model->save(false)){
            $modelPost = new Post();
            $totalLike = $modelPost->updateLikeCounter($postId);
             $response['message']=Yii::$app->params['apiMessage']['post']['postLikeSuccess'];
             $response['total_like']=$totalLike;
             return $response; 
         }else{
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['post']['postLikeFailed'];
            $response['errors']=$errors;
            return $response;
        }
    }
   
    /**
     * unlike post
     */

    public function actionUnlike()
    {
       
        $model = new PostLike();
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
        
            return $response;
        }


        $postId =  @(int) $model->post_id;
       
        $result = $model->find()->where(['post_id'=>$postId, 'user_id'=>$userId])->one();
        if(isset($result->id)){
            if($result->delete()){

                $modelPost = new Post();
                $totalLike = $modelPost->updateLikeCounter($postId,'unlike');
      
                $response['message']=Yii::$app->params['apiMessage']['post']['postUnlikeSuccess'];
                $response['total_like']=$totalLike;
                return $response; 
            }else{

                $response['statusCode']=422;
                $errors['message'][] = Yii::$app->params['apiMessage']['common']['actionFailed'];
                $response['errors']=$errors;
                return $response;
               
            }
        
        }else{
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['post']['postUnlikeFailed'];
            $response['errors']=$errors;
            return $response;
        
        }
 
        
    }

     /**
     * like post
     */

    public function actionViewCounter()
    {
        $model = new PostView();
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
            return $response;
        }
        $postId =  @(int) $model->post_id;
        $totalCount = $model->find()->where(['post_id'=>$postId, 'user_id'=>$userId])->count();
        if($totalCount==0){
            $model->save(false);
            $modelPost = new Post();
            $modelPost->updateViewCounter($postId);
  
        }
         
        $response['message']='ok';
        return $response; 
     
    }


    /**
     * add comment
     */

    public function actionAddComment()
    {
        $model = new PostComment();
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='create';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
            return $response;
        }
        $postId =  @(int) $model->post_id;
        
         if($model->save(false)){
            $modelPost = new Post();
            $totalLike = $modelPost->updateCommentCounter($postId);


             //// push notification 

             $resultPost = Post::findOne($postId);
            
             $modelUser = new User();
             $userResult = $modelUser->findOne($resultPost->user_id);
 
             if($userResult->device_token){
                 $message 					                =   $model->comment;
                 $title                                     =   Yii::$app->user->identity->name.' write new comment on your post';
                 $dataPush['title']	        	        	=	$title;
                 $dataPush['body']		                	=	$message;
                 $dataPush['data']['notification_type']		=	'newComment';
                 $dataPush['data']['post_id']		        =	$postId;
                 
                 $deviceTokens[] 					        =    $userResult->device_token;
                
                 Yii::$app->pushNotification->sendPushNotification($deviceTokens, $dataPush);

             }
             //// end push notification 
             /// add notification to list

              $modelNotification                 = new Notification();
              $modelNotification->user_id        =   $resultPost->user_id;
              $modelNotification->type           =   Notification::TYPE_NEW_COMMENT;
              $modelNotification->reference_id   =  $postId;
              $modelNotification->title          =  $title;
              $modelNotification->message        =   $message;
              $modelNotification->save(false);
            /// end add notification to list

             $response['message']=Yii::$app->params['apiMessage']['post']['commentSuccess'];
             
             return $response; 
         }else{
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['coomon']['actionFailed'];
            $response['errors']=$errors;
            return $response;
        }
    }
   
    /**
     * list comment
     */

    public function actionCommentList()
    {
        $model = new PostComment();
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='list';
        
        $model->load(Yii::$app->request->queryParams, '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
            return $response;
        }
        $postId =  @(int) $model->post_id;
        
        $query = $model->find()
        ->joinWith(['user' => function($query){
            $query->select(['id','name','image']);
        }])

        ->where(['post_comment.post_id'=>$postId])
        ->andWhere(['<>','post_comment.status',PostComment::STATUS_DELETED])
        ->select(['post_comment.id','post_comment.comment','post_comment.user_id','post_comment.created_at'])
        ->orderBy(['post_comment.id'=>SORT_ASC]);
        $result = new ActiveDataProvider([
            'query' => $query,
            'pagination' => [
                'pageSize' => 20,
            ]
        ]);
 
        
        $response['message']='ok';
        $response['comment']=$result;
             
        return $response; 
         
    }

    /**
     * share post
     */

    public function actionShare()
    {
        $model = new Post;
        $userId = Yii::$app->user->identity->id;
        $model->scenario ='share';
        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if(!$model->validate()) {
            $response['statusCode']=422;
            $response['errors']=$model->errors;
            return $response;
        }
        $postId =  @(int) $model->id;
        $result = $model->findOne($postId);
        if(!$result){
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['common']['noRecord'];
            $response['errors']=$errors;
            return $response;
        
        }
        
        $modelPost = new Post;
        $modelPost->user_id             =   $userId;
        $modelPost->title               =     $result->title;
        $modelPost->video               =     $result->video;
        $modelPost->image               =     $result->image;
        $modelPost->audio_id            =     $result->audio_id;
        $modelPost->is_share_post       =     Post::IS_SHARE_POST_YES;
        $modelPost->share_level         =     $result->share_level+1;

        $origin_post_id                 =       $result->id;
        if($result->is_share_post){
            $origin_post_id             =       $result->origin_post_id;
        }
        
        $modelPost->origin_post_id      =     $origin_post_id;
        
        if($modelPost->save(false)){
            $tags = [];
            foreach($result->hashtags as $tag){
                $tags[]=$tag['hashtag'];
            }
            $hashtags = implode(',',$tags);
            $modelHashTag =  new HashTag();
            $modelHashTag->updateHashTag($modelPost->id,$hashtags);

            $modelPost->updateShareCounter($postId);
            if($result->is_share_post){
                $modelPost->updateShareCounter($result->origin_post_id);
            }

            $response['message']=Yii::$app->params['apiMessage']['post']['postShareSuccess'];
            $response['post_id']=$modelPost->id;
            return $response; 


        }else{
            $response['statusCode']=422;
            $errors['message'][] = Yii::$app->params['apiMessage']['common']['actionFailed'];
            $response['errors']=$errors;
            return $response;
        }
    }
   
   



    protected function findModel($id)
    {
        if (($model = Post::findOne($id)) !== null) {
            return $model;
        }

        throw new NotFoundHttpException('The requested page does not exist.');
    }


}


