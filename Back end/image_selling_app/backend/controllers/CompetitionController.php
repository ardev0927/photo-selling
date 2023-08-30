<?php

namespace backend\controllers;

use Yii;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;
//use common\models\Category;
//use backend\models\CategorySearch;
use common\models\Competition;
use common\models\Post;
use common\models\User;

use common\models\Payment;
use common\models\CompetitionExampleImage;
use yii\data\ActiveDataProvider;
use yii\imagine\Image;
use yii\web\UploadedFile;
use yii\helpers\ArrayHelper;

/**
 * 
 */
class CompetitionController extends Controller
{
    /**
     * {@inheritdoc}
     */
    public function behaviors()
    {
        return [
            'verbs' => [
                'class' => VerbFilter::className(),
                'actions' => [
                    'delete' => ['POST'],
                    'winning' => ['POST'],
                ],
            ],
        ];
    }

    /**
     * Lists all  models.
     * @return mixed
     */
    public function actionIndex()
    {
        
        $model = new Competition();
        $query = $model->find()
        ->where(['<>','status',Competition::STATUS_DELETED]);

        $dataProvider = new ActiveDataProvider([
            'query' => $query,
        ]);


        return $this->render('index', [
            'model' => $model,
            'dataProvider' => $dataProvider,
        ]);
    }

    /**
     * Displays a single Countryy model.
     * @param integer $id
     * @return mixed
     * @throws NotFoundHttpException if the model cannot be found
     */
    public function actionView($id)
    {
        $model  = $this->findModel($id);
        
        return $this->render('view', [
            'model' =>   $model
        ]);
    }

    /**
     * Creates
     * If creation is successful, the browser will be redirected to the 'view' page.
     * @return mixed
     */
    public function actionCreate()
    {
       
        $model = new Competition();
        $model->scenario= 'create';

        $modelCompetitionExampleImage = new CompetitionExampleImage();
        
        if ($model->load(Yii::$app->request->post())  ) {
            $model->imageFile = UploadedFile::getInstance($model, 'imageFile');
            $model->exampleFile = UploadedFile::getInstances($model, 'exampleFile');
            $preImage = $model->image;
            if($model->award_type == Competition::AWARD_TYPE_PRICE){
                $model->coin=null;
            }else{
                $model->price=null;
            }
            if($model->validate()){
                if($model->imageFile){
                        
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    
                    $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                    $model->image 		= 	$imageName; 
                    
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->imageFile->tempName;
                    $result = $s3->upload('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$imageName, $imagePath);
                    $res = $s3->commands()->delete('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$preImage)->execute(); /// delere previous
                    
                }
                $model->start_date              = strtotime($model->start_date);
                $model->end_date                = strtotime($model->end_date.' 23:59:59');

                if( $model->save(false)){
                    
                    $images =[];
                    foreach ($model->exampleFile as $file) {
                        $microtime 			= 	(microtime(true)*10000);
                        $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                        $imageName 			=	$uniqueimage.'.'.$file->extension; 
                        $images[]           =  $imageName;
                       
                        $s3 = Yii::$app->get('s3');
                        $imagePath = $file->tempName;
                        $result = $s3->upload('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$imageName, $imagePath);
                      

                    }
                    if(count($images)>0){
                        $modelCompetitionExampleImage->addPhoto($model->id,$images);
                    }

                    Yii::$app->session->setFlash('success', "Competition created successfully");
                    return $this->redirect(['index']);
                }
            }
           
        }
    
        
        return $this->render('create', [
            'model' => $model,
         
            
        ]);
    }

    public function actionUpdate($id)
    {
        
        
        $model = $this->findModel($id);
        $model->scenario= 'update';

        $modelCompetitionExampleImage = new CompetitionExampleImage();
        
        if ($model->load(Yii::$app->request->post())  ) {
            $model->imageFile = UploadedFile::getInstance($model, 'imageFile');
            $model->exampleFile = UploadedFile::getInstances($model, 'exampleFile');
            $preImage = $model->image;
            if($model->award_type == Competition::AWARD_TYPE_PRICE){
                $model->coin=null;
            }else{
                $model->price=null;
            }
            if($model->validate()){
                if($model->imageFile){
                        
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    
                    $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                    $model->image 		= 	$imageName; 
                    
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->imageFile->tempName;
                    $result = $s3->upload('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$imageName, $imagePath);
                    $res = $s3->commands()->delete('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$preImage)->execute(); /// delere previous
                    
                }
                $model->start_date              = strtotime($model->start_date);
                $model->end_date                = strtotime($model->end_date.' 23:59:59');


                if( $model->save(false)){
                    $s3 = Yii::$app->get('s3');
                    if($model->deletePhoto){

                        $deletePhotoIds=[];
                        foreach($model->deletePhoto as $photoId){
                            if((int)$photoId>0){
                                $resultPhoto = $modelCompetitionExampleImage->findOne($photoId);
                                $s3->commands()->delete('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$resultPhoto->image)->execute(); /// delere previous
                                $deletePhotoIds[]=$photoId;
                            }
                        }    
                        
                        if(count($deletePhotoIds)){
                            $modelCompetitionExampleImage->deleteAll(['IN','id',$deletePhotoIds]);
                        }
                        
                    }


                    $images =[];
                    foreach ($model->exampleFile as $file) {
                        $microtime 			= 	(microtime(true)*10000);
                        $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                        $imageName 			=	$uniqueimage.'.'.$file->extension; 
                        $images[]           =  $imageName;
                       
                        $s3 = Yii::$app->get('s3');
                        $imagePath = $file->tempName;
                        $result = $s3->upload('./'.Yii::$app->params['pathUploadCompetitionFolder'].'/'.$imageName, $imagePath);
                      

                    }
                    if(count($images)>0){
                        $modelCompetitionExampleImage->addPhoto($model->id,$images);
                    }

                    Yii::$app->session->setFlash('success', "Competition updated successfully");
                    return $this->redirect(['index']);
                }
            }
           
        }else{
            //  print_r($model->errors);
            $model->start_date              = date('Y-m-d',$model->start_date);
            $model->end_date                = date('Y-m-d',$model->end_date);
            
        }

        return $this->render('update', [
            'model' => $model,
            
    
        ]);
    
    }

    public function actionWinning($id)
    {
        
        $modelPost = new Post();
        $modelPayment = new Payment();
        $modelUser = new User();
        
        $resultPost = $modelPost->findOne($id);
        $resultUser   = $modelUser->findOne($resultPost->user_id);


        $model= $this->findModel($resultPost->competition_id);


        
        if($model->status !=  $model::STATUS_COMPLETED){
            $model->status =  $model::STATUS_COMPLETED;
            $model->winner_id =  $id;
            if($model->save(false)){

                
                $resultPost->is_winning = $modelPost::IS_WINNING_YES;
                $resultPost->save(false);






                $modelPayment->user_id              =  $resultPost->user_id;
                if($model->award_type==$model::AWARD_TYPE_PRICE){
                    $modelPayment->type                 =  Payment::TYPE_PRICE;
                    $modelPayment->amount               =  $model->price;
                    
                    $resultUser->available_balance      =  $resultUser->available_balance+$model->price;

                }else{
                    $modelPayment->type                 =  Payment::TYPE_COIN;
                    $modelPayment->coin                 =  $model->coin;
                    
                    $resultUser->available_coin      =  $resultUser->available_coin+$model->coin;
                }
                
                $modelPayment->transaction_type     =  Payment::TRANSACTION_TYPE_CREDIT;
                $modelPayment->payment_type         =  Payment::PAYMENT_TYPE_AWARD;
                $modelPayment->payment_mode         =  Payment::PAYMENT_MODE_WALLET;
                $modelPayment->save(false);


                $resultUser->save(false);


                

                Yii::$app->session->setFlash('success', "Competition awareded successfully");

                return $this->redirect(['view','id'=>$model->id]);
            }
        }
      
        
    }


    public function actionDelete($id)
    {
        $model= $this->findModel($id);
        $model->status =  $model::STATUS_DELETED;
        if($model->save(false)){

            Yii::$app->session->setFlash('success', "Package deleted successfully");

            return $this->redirect(['index']);
        }
        
    }

    protected function findModel($id)
    {
        if (($model = Competition::findOne($id)) !== null) {
            return $model;
        }

        throw new NotFoundHttpException('The requested page does not exist.');
    }
}
