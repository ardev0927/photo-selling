<?php
namespace backend\controllers;
use Yii;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;
use common\models\Audio;
use backend\models\AudioSearch;
use yii\data\ActiveDataProvider;
use yii\imagine\Image;
use yii\web\UploadedFile;
use common\models\Category;
use yii\helpers\ArrayHelper;

/**
 * 
 */
class AudioController extends Controller
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
        
        $searchModel = new AudioSearch();
        $modelCategory = new Category();
        $mainCategoryData = ArrayHelper::map($modelCategory->getMainCategory(),'id','name');
        $dataProvider = $searchModel->search(Yii::$app->request->queryParams);
        return $this->render('index', [
            'searchModel' => $searchModel,
            'dataProvider' => $dataProvider,
            'mainCategoryData'=> $mainCategoryData
        ]);
        
      
    }

    /**
     * Displays 
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
     
     * If creation is successful, the browser will be redirected to the 'view' page.
     * @return mixed
     */
    public function actionCreate()
    {
       
        $model = new Audio();
        $modelCategory = new Category();
        $mainCategoryData = ArrayHelper::map($modelCategory->getMainCategory(),'id','name');
      
        $model->scenario = 'create';

        if ($model->load(Yii::$app->request->post()) ) {
            
            $model->audioFile = UploadedFile::getInstance($model, 'audioFile');
            $model->imageFile = UploadedFile::getInstance($model, 'imageFile');

            
            if($model->validate()){
            
            
                if($model->audioFile){
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    $imageName 			=	$uniqueimage.'.'.$model->audioFile->extension;
                    $model->audio 		= 	$imageName; 
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->audioFile->tempName;
                  //  $result = $s3->upload('./'.Yii::$app->params['pathUploadAudioFolder'].'/'.$imageName, $imagePath);
                  
                }
                if($model->imageFile){
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                    $model->image 		= 	$imageName; 
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->imageFile->tempName;
                    $result = $s3->upload('./'.Yii::$app->params['pathUploadAudioThumbFolder'].'/'.$imageName, $imagePath);
                  
                }
                
                
                if($model->save(false)){
            
                Yii::$app->session->setFlash('success', "Audio created successfully");
                return $this->redirect(['index']);
                }
            }
        }
        return $this->render('create', [
            'model' => $model,
            'mainCategoryData'=>$mainCategoryData
            
        ]);
    }

    /**
     * Updates an existing Countryy model.
     * If update is successful, the browser will be redirected to the 'view' page.
     * @param integer $id
     * @return mixed
     * @throws NotFoundHttpException if the model cannot be found
     */
    public function actionUpdate($id)
    {
        
        $model = $this->findModel($id);
        $modelCategory = new Category();
        $mainCategoryData = ArrayHelper::map($modelCategory->getMainCategory(),'id','name');

        $preAudio = $model->audio;
        $preImage = $model->image;

        if ($model->load(Yii::$app->request->post())) {
            $model->audioFile = UploadedFile::getInstance($model, 'audioFile');
            $model->imageFile = UploadedFile::getInstance($model, 'imageFile');
            
            if($model->validate()){
                if($model->audioFile){
                        
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    
                    $imageName 			=	$uniqueimage.'.'.$model->audioFile->extension;
                    $model->audio 		= 	$imageName; 
                    
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->audioFile->tempName;
                    $result = $s3->upload('./'.Yii::$app->params['pathUploadAudioFolder'].'/'.$imageName, $imagePath);
                    $oldAudioPath =  './'.Yii::$app->params['pathUploadAudioFolder'].'/'.$preAudio;

                     $res = $s3->commands()->delete('./'.Yii::$app->params['pathUploadAudioFolder'].'/'.$preAudio)->execute(); /// delere previous
                    
                  
                    /*$imagePath 			=	Yii::$app->params['pathUploadBanner'] ."/".$model->image;
                    $imagePathThumb 	=	Yii::$app->params['pathUploadBannerThumb'] ."/".$model->image;
                    $model->audioFile->saveAs($imagePath,false);
    
    
                    Image::thumbnail($imagePath, 200, 200)
                        ->save($imagePathThumb, ['quality' => 100]);*/
    
                }
                if($model->imageFile){
                    $microtime 			= 	(microtime(true)*10000);
                    $uniqueimage		=	$microtime.'_'.date("Ymd_His").'_'.substr(md5($microtime),0,10); 
                    $imageName 			=	$uniqueimage.'.'.$model->imageFile->extension;
                    $model->image 		= 	$imageName; 
                    $s3 = Yii::$app->get('s3');
                    $imagePath = $model->imageFile->tempName;
                    $result = $s3->upload('./'.Yii::$app->params['pathUploadAudioThumbFolder'].'/'.$imageName, $imagePath);
                   
                    $oldAudioPath =  './'.Yii::$app->params['pathUploadAudioThumbFolder'].'/'.$preImage;
                    $res = $s3->commands()->delete('./'.Yii::$app->params['pathUploadAudioThumbFolder'].'/'.$preImage)->execute(); /// delere previous
                 
                  
                }
                
            
                if($model->save()){
                    
                    Yii::$app->session->setFlash('success', "Audio updated successfully");
                    return $this->redirect(['index']);
                };
                
            }
        }
    
      
        return $this->render('update', [
            'model' => $model,
            'mainCategoryData'=>$mainCategoryData
    
        ]);
    
    }


   

    /**
     * Deletes an existing Countryy model.
     * If deletion is successful, the browser will be redirected to the 'index' page.
     * @param integer $id
     * @return mixed
     * @throws NotFoundHttpException if the model cannot be found
     */
    public function actionDelete($id)
    {
        $model= $this->findModel($id);
        $model->status =  $model::STATUS_DELETED;
        if($model->save(false)){

            Yii::$app->session->setFlash('success', "Audio deleted successfully");

            return $this->redirect(['index']);
        }
        
    }

    /**
     * Finds the Countryy model based on its primary key value.
     * If the model is not found, a 404 HTTP exception will be thrown.
     * @param integer $id
     * @return Countryy the loaded model
     * @throws NotFoundHttpException if the model cannot be found
     */
    protected function findModel($id)
    {
        if (($model = Audio::findOne($id)) !== null) {
            return $model;
        }

        throw new NotFoundHttpException('The requested page does not exist.');
    }
}
