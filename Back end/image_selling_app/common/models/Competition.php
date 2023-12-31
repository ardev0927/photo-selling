<?php
namespace common\models;
//use common\models\User;
use common\models\CompetitionUser;
use common\models\Post;
use common\models\CompetitionExampleImage;
use Yii;

class Competition extends \yii\db\ActiveRecord
{
    const STATUS_DELETED = 0;
    const STATUS_ACTIVE = 1;
    const STATUS_BLOCKED = 9;
    const STATUS_COMPLETED = 10;

    const AWARD_TYPE_PRICE = 1;
    const AWARD_TYPE_COIN = 2;

    public $imageFile;
    public $exampleFile;
    public $deletePhoto;

    public $competition_id;


    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'competition';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['status', 'id',  'award_type', 'coin', 'winner_id', 'joining_fee', 'created_at', 'created_by', 'updated_at', 'updated_by','competition_id'], 'integer'],
            [['price'], 'number'],
            [['description'], 'string'],
            
            [['title', 'image','start_date', 'end_date'], 'string', 'max' => 100],
            
            [['title','start_date', 'end_date','award_type','joining_fee'], 'required','on'=>['create','update']],
            [['exampleFile','imageFile'], 'required','on'=>'create'],

            [['imageFile'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg'],
            [['exampleFile'], 'file', 'skipOnEmpty' => true, 'extensions' => 'png, jpg','maxFiles' => 3],
            [['deletePhoto'], 'safe'],
            [['end_date'], 'checkEndDate', 'on' => ['create']],
           
         //   [['competition_id' ], 'required','on'=>'join'],

        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'title' => Yii::t('app', 'Title'),
            'status' => Yii::t('app', 'Status'),
            'start_date' => Yii::t('app', 'Start date'),
            'end_date' => Yii::t('app', 'End date'),
            'award_type' => Yii::t('app', 'Award Type'),
            'price' => Yii::t('app', 'Award price'),
            'coin' => Yii::t('app', 'Award coin'),
            'joining_fee' => Yii::t('app', 'Joining fee coin'),
            'winner_id' => Yii::t('app', 'Winner post'),
            

            'image' => Yii::t('app', 'Cover image'),
            'imageFile' => Yii::t('app', 'Cover image'),
            
            'exampleFile' => Yii::t('app', 'Example images'),
            
        ];
    }

    public function beforeSave($insert)
    {
        if ($insert) {
            $this->created_at = time();
            $this->created_by = Yii::$app->user->identity->id;

        } else {
            $this->updated_at = time();
            $this->updated_by = Yii::$app->user->identity->id;

        }

        return parent::beforeSave($insert);
    }
    public function checkEndDate($attribute, $params, $validator)
    {
        if(!$this->hasErrors()){
            if($this->start_date > $this->end_date ){
                $this->addError($attribute, Yii::t('app','End date must be greater than start date'));  
            }
        
            
        }
       
    }

    
    public function getStatusString()
    {
       if($this->status==$this::STATUS_BLOCKED){
           return 'Blocked';
       }else if($this->status==$this::STATUS_ACTIVE){
           return 'Active';    
       }else if($this->status==$this::STATUS_COMPLETED){
         return 'Completed';    
       }
    }

    public function getAwardTypeString()
    {
       
        $awardTypes = $this->getAwardTypeData();

        return $awardTypes[$this->award_type];
       
        
    }


    

    public function getStatusButton()
    {
        if($this->status==$this::STATUS_ACTIVE){
         //  return 'Active';   
            $currentTime= time();
            if($this->start_date < $currentTime && $this->end_date > $currentTime ){
                return'<button type="button" class="btn btn-sm active_btn">'.Yii::t('app','Active').'</button>';      
                //return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Inactive').'</button>'; 
            }else if($this->start_date > $currentTime){
                return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Upcoming').'</button>'; 
            }else if($this->end_date < $currentTime){
                
                return'<button type="button" class="btn btn-sm pending_btn">'.Yii::t('app','Pending').'</button>'; 
            }else{
                return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Inactive').'</button>'; 
            }


           
        }else if($this->status==$this::STATUS_DELETED){
            
            return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Deleted').'</button>'; 
        }else if($this->status==$this::STATUS_BLOCKED){
            
            return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Blocked').'</button>'; 
        }else if($this->status==$this::STATUS_COMPLETED){
            
            return'<button type="button" class="btn btn-sm active_btn">'.Yii::t('app','Completed').'</button>';      
        }
        //return'<button type="button" class="btn btn-sm pending_btn">'.Yii::t('app','Pending').'</button>'; 
        //return'<button type="button" class="btn btn-sm expired_btn">'.Yii::t('app','Blocked').'</button>'; 
       
    }


    public function getStatusDropDownData()
    {
        return array(self::STATUS_ACTIVE => 'Active', self::STATUS_BLOCKED => 'Blocked', self::STATUS_COMPLETED => 'Completed');
    
    }


    
    public function getAwardTypeData()
    {
        return array(self::AWARD_TYPE_PRICE => 'Price', self::AWARD_TYPE_COIN => 'Coin');
    }



    public function getImageUrl()
    {

        return Yii::$app->params['pathUploadCompetition'] . "/" . $this->image;
    }
    public function getCompetitionCount()
    {
        return Competition::find()->where(['<>','status',self::STATUS_DELETED])->count();
    }
   
    /**
     * RELEATION START
     */
    public function getExpampleImages()
    {
        return $this->hasMany(CompetitionExampleImage::className(), ['competition_id' => 'id']);

    }



    public function getCompetitionUser()
    {
        return $this->hasMany(CompetitionUser::className(), ['competition_id' => 'id']);

    }


    public function getPost()
    {
        return $this->hasMany(Post::className(), ['competition_id' => 'id']);

    }

    /* winner post */
    public function getWinnerPost()
    {
        return $this->hasOne(Post::className(), ['id' => 'winner_id']);

    }



}
