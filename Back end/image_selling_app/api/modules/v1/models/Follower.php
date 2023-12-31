<?php
namespace api\modules\v1\models;
use Yii;
use yii\helpers\ArrayHelper;
use api\modules\v1\models\User;
use api\modules\v1\models\UserLocation;

class Follower extends \yii\db\ActiveRecord
{
    
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'follower';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
            [['id','user_id','follower_id','created_at'], 'integer'],
            [['user_id'], 'required', 'on'=>'create']

        ];
    }

    /**
     * {@inheritdoc}
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'user_id' => Yii::t('app', 'User'),
            'follower_id' => Yii::t('app', 'Follower'),
            'created_at'=> Yii::t('app', 'Reported At'),
            
        ];
    }
   
    public function beforeSave($insert)
    {
        if ($insert) {
            $this->created_at = time();
            $this->follower_id =   Yii::$app->user->identity->id;
          
        }

        
        return parent::beforeSave($insert);
    }

    public function fields()
    {
        $fields = parent::fields();

        // remove fields that contain sensitive information
       /// unset($fields['status'], $fields['template_type'], $fields['category'], $fields['created_at'], $fields['updated_at'], $fields['created_by'], $fields['updated_by']);
        //$fields[] = 'picture';
        //$fields[] = 'userLocation';
        return $fields;
    }

    public function getFollwingUser()
    {
        return $this->hasOne(User::className(), ['id'=>'user_id'])->joinWith('user u ')->select('u.id');
    }

    public function getPicture()
    {
        if($this->follwingUser->image){
            return  Yii::getAlias('@siteUrl').Yii::$app->urlManagerFrontend->baseUrl.'/uploads/user/medium/'. $this->follwingUser->image;
        }else{
            return null;
        }
      
    }


    public function getFollowingUserDetail()
    {
        return $this->hasOne(User::className(), ['id'=>'user_id']);
    }


   public function getFollowerUserDetail()
    {
        
           return $this->hasOne(User::className(), ['id'=>'follower_id']);
    }

    public function getUserLocation()
    {
        return $this->hasOne(UserLocation::className(), ['user_id'=>'id']);
    }




}
