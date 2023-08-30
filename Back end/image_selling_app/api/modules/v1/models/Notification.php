<?php
namespace api\modules\v1\models;
use Yii;
use yii\helpers\ArrayHelper;


class Notification extends \yii\db\ActiveRecord
{
    const TYPE_NEW_FOLLOWER=1;
    const TYPE_NEW_COMMENT=2;
    
    
    /**
     * {@inheritdoc}
     */
    public static function tableName()
    {
        return 'notification';
    }

    /**
     * {@inheritdoc}
     */
    public function rules()
    {
        return [
           
            [['id','type','user_id','created_at','reference_id','read_status'], 'integer'],
            [['title','message'], 'string', 'max' => 256]

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
                  
        }
        
        return parent::beforeSave($insert);
    }


    public function fields()
    {
        $fields = parent::fields();

     //  $fields[] = 'userLocation';
        return $fields;
    }
    
    
    

    

}
