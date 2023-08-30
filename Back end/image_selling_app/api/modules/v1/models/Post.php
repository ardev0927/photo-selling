<?php
namespace api\modules\v1\models;
use Yii;
use api\modules\v1\models\HashTag;
use api\modules\v1\models\Audio;
use api\modules\v1\models\PostLike;
use api\modules\v1\models\PostView;
use api\modules\v1\models\PostComment;
use api\modules\v1\models\Follower;
use api\modules\v1\models\ReportedPost;

class Post extends \yii\db\ActiveRecord
{
    
    const STATUS_ACTIVE=10;
    const STATUS_DELETED = 0;
    const STATUS_BLOCKED=9;

    const IS_SHARE_POST_YES=1;
    const IS_SHARE_POST_NO=0;


    const TYPE_NORMAL       =1;
    const TYPE_COMPETITION  =2;

    const IS_WINNING_NO=0;
    const IS_WINNING_YES=1;



    public  $imageFile;
    public  $videoFile;
    public  $hashtag;
    
    
  
    
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'post';
    }

    

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [[ 'title','image','hashtag'], 'string'],
            [['id','type','competition_id','status','user_id','total_view','total_like','total_share','total_comment','is_share_post','share_level','origin_post_id', 'created_at','created_by', 'updated_by'], 'integer'],
            [['updated_by', 'updated_at','hashtag','audio_id','is_share_post','share_level','origin_post_id'], 'safe'],
            [['title'], 'string', 'max' => 256],
            ['status', 'in', 'range' => [0,9,10]],
            [['title','imageFile' ], 'required','on'=>'create'],
            [['title','competition_id','imageFile' ], 'required','on'=>'competitionImage'],
            
            //[[ 'title','category_id','currency' ], 'required','on'=>'update'],
            [['imageFile'], 'file', 'skipOnEmpty' => false, 'extensions' => 'png, jpg','on'=>['create','competitionImage']],
            //[['videoFile'], 'file', 'skipOnEmpty' => false,'extensions' => 'mp4','maxSize' => '6048000','on'=>'create'],
            [[ 'id' ], 'required','on'=>'share'],
            [[ 'id' ], 'required','on'=>'reportPost'],
            
            
        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
        
            
        ];
    }

    
    public function beforeSave($insert)
    {
        if ($insert) {
            $this->created_at = time();
            $this->created_by  =   Yii::$app->user->identity->id;
            $this->user_id       =   Yii::$app->user->identity->id;
          
        }else{

           
            $this->updated_at = time();
            $this->updated_by =   Yii::$app->user->identity->id;

        }
        return parent::beforeSave($insert);
    }

    public function fields()
    {
        $fields = parent::fields();
        $fields[] = "imageUrl";
      //  $fields[] = "videoUrl";
        $fields['is_like'] = (function($model){
            return (@$model->isLike) ? 1: 0;
        });
        $fields['is_reported'] = (function($model){
            
            return (@$model->isReported) ? 1: 0;
        });
       
        $fields['hashtags'] = (function($model){
            $resultArr=[];
            foreach($model->hashtags as $tag){
                $resultArr[]=  $tag->hashtag;
            }
            return $resultArr; 
        });
      
      //  $fields[] = "audioDetail";
        

        
       
        return $fields;
    }
    
    public function extraFields()
    {
        return ['user'];
    }
    
   
    public function getStatusString()
    {
        if($this->status==$this::STATUS_ACTIVE){
           return 'Active';    
        }else if($this->status==$this::STATUS_DELETED){
            return 'Deleted';    
        }else if($this->status==$this::STATUS_BLOCKED){
            return 'Blocked';    
        }
       
    }
    public function getImageUrl(){
        if($this->image){
            return Yii::$app->params['pathUploadImage'] ."/".$this->image;
        }
     }

     /*public function getVideoUrl(){
        if($this->video){
            return Yii::$app->params['pathUploadVideo'] ."/".$this->video;
        } 
     }*/
     
     public function updateLikeCounter($postId,$type='like'){

         $result = $this->findOne($postId);
         $modelPostLike = new PostLike();
         $totalCount = $modelPostLike->find()->where(['post_id'=>$postId])->count();
         $result->total_like = $totalCount;
        
        if($type=='like'){
            $result->popular_point   = $result->popular_point + Yii::$app->params['postPopularityPoint']['postLike'];
        }else{
            $result->popular_point   = $result->popular_point - Yii::$app->params['postPopularityPoint']['postLike'];
        }

         if($result->save(false)){
            return  $totalCount;
         }else{
             return false;
         }
               
     }



     public function updateViewCounter($postId){

        $result = $this->findOne($postId);
        $modelPostLike = new PostView();
        $totalCount = $modelPostLike->find()->where(['post_id'=>$postId])->count();
        $result->total_view = $totalCount;
        $result->popular_point   = $result->popular_point + Yii::$app->params['postPopularityPoint']['postView'];

        if($result->save(false)){
           return  $totalCount;
        }else{
            return false;
        }
              
    }

    public function updateShareCounter($postId){

        $result = $this->findOne($postId);
        $result->total_share = $result->total_share +1;
        $result->popular_point   = $result->popular_point + Yii::$app->params['postPopularityPoint']['postShare'];
        return $result->save(false);
              
    }


    public function updateCommentCounter($postId){

        $result = $this->findOne($postId);
        $model = new PostComment();
        $totalCount = $model->find()->where(['post_id'=>$postId,'status'=>$model::STATUS_ACTIVE])->count();
        $result->total_comment = $totalCount;
        if($result->save(false)){
           return  $totalCount;
        }else{
            return false;
        }
              
    }


     public function getIsLike()
     {
         return $this->hasOne(PostLike::className(), ['post_id'=>'id'])->andOnCondition(['post_like.user_id' => Yii::$app->user->identity->id]);
         
     }
 


    

       
    
  
    /**
     * RELEATION START
     */
    public function getUser()
    {
        return $this->hasOne(User::className(), ['id'=>'user_id']);
        
    }

    public function getHashtags()
    {
        return $this->hasMany(HashTag::className(), ['post_id'=>'id']);
        
    }

    public function getAudioDetail()
    {
        return $this->hasOne(Audio::className(), ['id'=>'audio_id']);
        
    }
    public function getFollowers()
    {
        return $this->hasMany(Follower::className(), ['user_id'=>'user_id']);
        
    }
     
    public function getisReported()
    {
        return $this->hasOne(ReportedPost::className(), ['post_id'=>'id'])->andOnCondition(['reported_post.user_id' => Yii::$app->user->identity->id]);
    }
  

    
}
